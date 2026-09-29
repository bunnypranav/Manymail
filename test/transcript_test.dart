// Manymail - Many addresses, one app.
// Copyright (C) 2026 Bunny Pranav
// SPDX-License-Identifier: GPL-3.0-or-later
//
// This file is part of Manymail, distributed under the GNU General Public
// License v3 or later. See the LICENSE file at the root of this repository.

import 'package:flutter_test/flutter_test.dart';
import 'package:manymail/core/transcript.dart';

void main() {
  group('SmtpTranscript redaction', () {
    test('keeps the mechanism but drops an inline AUTH PLAIN response', () {
      final transcript = SmtpTranscript()
        ..add(TranscriptDirection.client, 'AUTH PLAIN AHVzZXIAc2VjcmV0');

      final rendered = transcript.render();
      expect(rendered, contains('AUTH PLAIN'));
      expect(rendered, contains(SmtpTranscript.redacted));
      expect(rendered, isNot(contains('AHVzZXIAc2VjcmV0')));
    });

    test('redacts every client line during an AUTH LOGIN exchange', () {
      final transcript = SmtpTranscript()
        ..add(TranscriptDirection.client, 'AUTH LOGIN')
        ..add(TranscriptDirection.server, '334 VXNlcm5hbWU6')
        ..add(TranscriptDirection.client, 'dXNlcm5hbWU=')
        ..add(TranscriptDirection.server, '334 UGFzc3dvcmQ6')
        ..add(TranscriptDirection.client, 'c3VwZXJzZWNyZXQ=')
        ..add(TranscriptDirection.server, '235 2.7.0 Accepted');

      final rendered = transcript.render();
      expect(rendered, isNot(contains('dXNlcm5hbWU=')));
      expect(rendered, isNot(contains('c3VwZXJzZWNyZXQ=')));
      // The server side of the exchange stays visible — it is diagnostic.
      expect(rendered, contains('334 VXNlcm5hbWU6'));
      expect(rendered, contains('235 2.7.0 Accepted'));
    });

    test('resumes normal logging once authentication completes', () {
      final transcript = SmtpTranscript()
        ..add(TranscriptDirection.client, 'AUTH LOGIN')
        ..add(TranscriptDirection.server, '334 VXNlcm5hbWU6')
        ..add(TranscriptDirection.client, 'dXNlcm5hbWU=')
        ..add(TranscriptDirection.server, '235 2.7.0 Accepted')
        ..add(TranscriptDirection.client, 'MAIL FROM:<hello@example.com>');

      expect(transcript.render(), contains('MAIL FROM:<hello@example.com>'));
    });

    test('scrubs a registered secret wherever it appears', () {
      final transcript = SmtpTranscript()
        ..registerSecret('hunter2000')
        ..add(TranscriptDirection.server, '535 bad password hunter2000');

      final rendered = transcript.render();
      expect(rendered, isNot(contains('hunter2000')));
      expect(rendered, contains(SmtpTranscript.redacted));
    });

    test('ignores secrets too short to scrub safely', () {
      // Scrubbing a 2-character secret would mangle unrelated lines.
      final transcript = SmtpTranscript()
        ..registerSecret('ab')
        ..add(TranscriptDirection.server, '250 abc');

      expect(transcript.render(), contains('250 abc'));
    });

    test('splits a multi-line write into one entry per protocol line', () {
      final transcript = SmtpTranscript()
        ..add(TranscriptDirection.server, '250-SIZE 35882577\r\n250 AUTH LOGIN');

      expect(transcript.entries, hasLength(2));
    });

    test('truncates very long lines instead of storing the whole payload', () {
      final transcript = SmtpTranscript(maxLineLength: 20)
        ..add(TranscriptDirection.client, 'x' * 500);

      final text = transcript.entries.single.text;
      expect(text, contains('truncated'));
      expect(text.length, lessThan(100));
    });

    test('stops accumulating past maxEntries', () {
      final transcript = SmtpTranscript(maxEntries: 3);
      for (var i = 0; i < 10; i++) {
        transcript.add(TranscriptDirection.server, '250 line $i');
      }
      expect(transcript.entries, hasLength(3));
      expect(transcript.isTruncated, isTrue);
    });
  });

  group('responseCodeOf', () {
    test('parses a leading three-digit code', () {
      expect(SmtpTranscript.responseCodeOf('550 sender rejected'), 550);
      expect(SmtpTranscript.responseCodeOf('250-SIZE 100'), 250);
    });

    test('returns null when there is no code', () {
      expect(SmtpTranscript.responseCodeOf('connecting to server'), isNull);
    });
  });
}
