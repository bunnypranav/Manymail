// Manymail - Many addresses, one app.
// Copyright (C) 2026 Bunny Pranav
// SPDX-License-Identifier: GPL-3.0-or-later
//
// This file is part of Manymail, distributed under the GNU General Public
// License v3 or later. See the LICENSE file at the root of this repository.

import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:manymail/data/models/message_attachment.dart';
import 'package:manymail/data/models/outgoing_message.dart';
import 'package:manymail/smtp/message_composer.dart';

/// The MIME tree has to match what the message actually contains: a plain note
/// must not be wrapped in multipart, and a rich note with an inline image must
/// be `related` around `alternative` or clients show the image twice.
void main() {
  late Directory workspace;

  setUp(() async {
    workspace = await Directory.systemTemp.createTemp('manymail_mime');
  });

  tearDown(() async {
    if (workspace.existsSync()) await workspace.delete(recursive: true);
  });

  Future<MessageAttachment> fileAttachment({
    required String name,
    required String mimeType,
    bool inline = false,
    String? contentId,
    List<int>? bytes,
  }) async {
    final file = File('${workspace.path}/$name');
    await file.writeAsBytes(
      Uint8List.fromList(bytes ?? List<int>.filled(64, 65)),
    );
    return MessageAttachment(
      fileName: name,
      mimeType: mimeType,
      sizeBytes: await file.length(),
      storedPath: file.path,
      contentId: contentId,
      isInline: inline,
    );
  }

  OutgoingMessage message({
    bool isHtml = false,
    String? html,
    String plain = 'Plain body',
  }) {
    final now = DateTime.now();
    return OutgoingMessage(
      status: MessageStatus.draft,
      domainId: 1,
      domainSnapshot: 'example.com',
      localPart: 'hello',
      displayName: 'Bunny Hopper',
      to: const ['someone@example.com'],
      subject: 'Structure',
      bodyPlain: plain,
      bodyHtml: html,
      isHtml: isHtml,
      createdAt: now,
      updatedAt: now,
    );
  }

  group('plain text only', () {
    test('is a bare text/plain message with no multipart wrapper', () async {
      final built = await const MessageComposer().build(message());

      expect(built.mime, contains('text/plain'));
      expect(built.mime.toLowerCase(), isNot(contains('multipart/')));
      expect(built.mime.toLowerCase(), isNot(contains('text/html')));
      expect(built.mime, contains('Plain body'));
    });

    test('the plain-text toggle really suppresses the HTML part', () async {
      // An HTML body is present but the message is marked plain: the HTML must
      // not be sent.
      final built = await const MessageComposer().build(
        message(html: '<p>should not be sent</p>'),
      );

      expect(built.mime.toLowerCase(), isNot(contains('text/html')));
      expect(built.mime, isNot(contains('should not be sent')));
    });
  });

  group('rich text', () {
    test('is multipart/alternative with plain first', () async {
      final built = await const MessageComposer().build(
        message(isHtml: true, html: '<p>Rich body</p>'),
      );

      expect(built.mime, contains('multipart/alternative'));
      expect(built.mime, contains('text/plain'));
      expect(built.mime, contains('text/html'));

      // Least-rich first, so a client picks the best it can render.
      expect(
        built.mime.indexOf('text/plain'),
        lessThan(built.mime.indexOf('text/html')),
      );
    });
  });

  group('inline images', () {
    test('wrap the alternative in multipart/related with a Content-ID',
        () async {
      final image = await fileAttachment(
        name: 'logo.png',
        mimeType: 'image/png',
        inline: true,
        contentId: 'abc@manymail',
      );

      final built = await const MessageComposer().build(
        message(
          isHtml: true,
          html: '<p>See <img src="cid:abc@manymail"></p>',
        ),
        attachments: [image],
      );

      expect(built.mime, contains('multipart/related'));
      expect(built.mime, contains('multipart/alternative'));
      expect(built.mime, contains('image/png'));
      // Angle brackets in the header, bare value in the body reference.
      expect(built.mime, contains('<abc@manymail>'));
      expect(built.mime, contains('cid:abc@manymail'));
      expect(built.mime.toLowerCase(), contains('inline'));
    });
  });

  group('attachments', () {
    test('wrap everything in multipart/mixed', () async {
      final file = await fileAttachment(
        name: 'notes.txt',
        mimeType: 'text/plain',
      );

      final built = await const MessageComposer().build(
        message(isHtml: true, html: '<p>Body</p>'),
        attachments: [file],
      );

      expect(built.mime, contains('multipart/mixed'));
      expect(built.mime, contains('multipart/alternative'));
      expect(built.mime, contains('notes.txt'));
      expect(built.mime.toLowerCase(), contains('attachment'));
    });

    test('a plain message with a file is mixed, not alternative', () async {
      final file = await fileAttachment(
        name: 'report.pdf',
        mimeType: 'application/pdf',
      );

      final built = await const MessageComposer().build(
        message(),
        attachments: [file],
      );

      expect(built.mime, contains('multipart/mixed'));
      expect(built.mime, isNot(contains('multipart/alternative')));
      expect(built.mime, contains('application/pdf'));
    });

    test('inline images and files together nest mixed > related > alternative',
        () async {
      final image = await fileAttachment(
        name: 'sig.png',
        mimeType: 'image/png',
        inline: true,
        contentId: 'sig@manymail',
      );
      final file = await fileAttachment(
        name: 'invoice.pdf',
        mimeType: 'application/pdf',
      );

      final built = await const MessageComposer().build(
        message(isHtml: true, html: '<img src="cid:sig@manymail">'),
        attachments: [image, file],
      );

      final mime = built.mime;
      expect(mime, contains('multipart/mixed'));
      expect(mime, contains('multipart/related'));
      expect(mime, contains('multipart/alternative'));
      expect(
        mime.indexOf('multipart/mixed'),
        lessThan(mime.indexOf('multipart/related')),
      );
      expect(
        mime.indexOf('multipart/related'),
        lessThan(mime.indexOf('multipart/alternative')),
      );
    });

    test('a missing file is skipped rather than failing the send', () async {
      final ghost = MessageAttachment(
        fileName: 'gone.pdf',
        mimeType: 'application/pdf',
        sizeBytes: 100,
        storedPath: '${workspace.path}/does-not-exist.pdf',
      );

      final built = await const MessageComposer().build(
        message(),
        attachments: [ghost],
      );

      expect(built.mime, contains('Plain body'));
      expect(built.mime, isNot(contains('gone.pdf')));
    });
  });

  group('regardless of structure', () {
    test('Bcc never appears and the envelope keeps every recipient', () async {
      final file = await fileAttachment(
        name: 'a.txt',
        mimeType: 'text/plain',
      );
      final now = DateTime.now();

      final built = await const MessageComposer().build(
        OutgoingMessage(
          status: MessageStatus.draft,
          domainId: 1,
          domainSnapshot: 'example.com',
          localPart: 'hello',
          displayName: 'Bunny Hopper',
          to: const ['visible@example.com'],
          bcc: const ['hidden@example.com'],
          subject: 'Structure',
          bodyPlain: 'Body',
          createdAt: now,
          updatedAt: now,
        ),
        attachments: [file],
      );

      expect(built.recipients, [
        'visible@example.com',
        'hidden@example.com',
      ]);
      expect(built.mime, isNot(contains('hidden@example.com')));
    });
  });
}
