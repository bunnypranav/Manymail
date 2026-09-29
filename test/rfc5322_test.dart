// Manymail - Many addresses, one app.
// Copyright (C) 2026 Bunny Pranav
// SPDX-License-Identifier: GPL-3.0-or-later
//
// This file is part of Manymail, distributed under the GNU General Public
// License v3 or later. See the LICENSE file at the root of this repository.

import 'package:flutter_test/flutter_test.dart';
import 'package:manymail/core/validation/rfc5322.dart';

void main() {
  group('validateLocalPart', () {
    test('accepts the free-form local parts the app exists to allow', () {
      for (final localPart in [
        'hello',
        'billing',
        'no-reply',
        'pranav+test',
        'a.b.c',
        "o'brien",
        'weird!#\$%&*+-/=?^_`{|}~',
      ]) {
        expect(
          validateLocalPart(localPart).isValid,
          isTrue,
          reason: '"$localPart" should be a valid dot-atom',
        );
      }
    });

    test('flags structural dot problems', () {
      expect(validateLocalPart('.lead').issue, LocalPartIssue.leadingDot);
      expect(validateLocalPart('trail.').issue, LocalPartIssue.trailingDot);
      expect(validateLocalPart('a..b').issue, LocalPartIssue.consecutiveDots);
    });

    test('flags characters that are not atext', () {
      final result = validateLocalPart('has space');
      expect(result.issue, LocalPartIssue.illegalCharacter);
      expect(result.offendingCharacter, ' ');
      expect(validateLocalPart('a@b').issue, LocalPartIssue.illegalCharacter);
    });

    test('enforces the RFC 5321 length limit', () {
      expect(validateLocalPart('a' * 64).isValid, isTrue);
      expect(validateLocalPart('a' * 65).issue, LocalPartIssue.tooLong);
    });

    test('reports empty separately so the hint can be specific', () {
      expect(validateLocalPart('').issue, LocalPartIssue.empty);
    });

    test('every invalid result carries a hint, valid ones carry none', () {
      expect(validateLocalPart('fine').hint, isNull);
      expect(validateLocalPart('a..b').hint, isNotNull);
    });
  });

  group('formatMailbox', () {
    test('renders a plain display name unquoted', () {
      expect(
        formatMailbox(
          displayName: 'Bunny Hopper',
          localPart: 'hello',
          domain: 'example.com',
        ),
        'Bunny Hopper <hello@example.com>',
      );
    });

    test('omits the angle brackets when there is no display name', () {
      expect(
        formatMailbox(
          displayName: '   ',
          localPart: 'billing',
          domain: 'example.com',
        ),
        'billing@example.com',
      );
    });

    test('quotes a display name containing specials', () {
      expect(
        formatMailbox(
          displayName: 'Doe, John',
          localPart: 'j',
          domain: 'example.com',
        ),
        '"Doe, John" <j@example.com>',
      );
    });

    test('escapes quotes inside a display name', () {
      expect(
        formatDisplayName('He said "hi"'),
        r'"He said \"hi\""',
      );
    });
  });

  group('splitAddressList', () {
    test('splits on commas, semicolons and whitespace', () {
      expect(
        splitAddressList('a@x.com, b@y.com; c@z.com  d@w.com'),
        ['a@x.com', 'b@y.com', 'c@z.com', 'd@w.com'],
      );
    });

    test('extracts the address from a Name <addr> form', () {
      expect(
        splitAddressList('Bunny <p@example.com>'),
        ['p@example.com'],
      );
    });

    test('ignores empty fragments', () {
      expect(splitAddressList(' , ; '), isEmpty);
    });

    test('keeps a display name containing a comma intact', () {
      expect(
        splitAddressList('"Doe, John" <j@example.com>, b@y.com'),
        ['j@example.com', 'b@y.com'],
      );
    });

    test('handles a mixed list of bare and named addresses', () {
      expect(
        splitAddressList('a@x.com, Bunny Hopper <p@example.com>; c@z.com'),
        ['a@x.com', 'p@example.com', 'c@z.com'],
      );
    });
  });

  group('isPlausibleDomain', () {
    test('accepts ordinary domains', () {
      expect(isPlausibleDomain('example.com'), isTrue);
      expect(isPlausibleDomain('mail.sub.example.co.uk'), isTrue);
    });

    test('rejects malformed ones', () {
      for (final bad in ['', 'nodot', '.leading.com', 'trailing.', 'a..b.com']) {
        expect(isPlausibleDomain(bad), isFalse, reason: bad);
      }
    });
  });
}
