// Manymail - Many addresses, one app.
// Copyright (C) 2026 Bunny Pranav
// SPDX-License-Identifier: GPL-3.0-or-later
//
// This file is part of Manymail, distributed under the GNU General Public
// License v3 or later. See the LICENSE file at the root of this repository.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:manymail/features/compose/widgets/recipient_field.dart';

/// The recipient field is where a typo becomes a message sent to the wrong
/// person, so its committing rules are worth pinning down.
void main() {
  late List<String> addresses;

  Future<void> pump(WidgetTester tester) async {
    addresses = [];
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) => RecipientField(
              label: 'To',
              addresses: addresses,
              onChanged: (next) => setState(() => addresses = next),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> type(WidgetTester tester, String text) async {
    await tester.enterText(find.byType(TextField), text);
    await tester.pumpAndSettle();
  }

  group('committing a chip', () {
    testWidgets('a comma commits what was typed', (tester) async {
      await pump(tester);
      await type(tester, 'someone@example.com,');

      expect(addresses, ['someone@example.com']);
      expect(find.text('someone@example.com'), findsOneWidget);
    });

    testWidgets('a semicolon commits too', (tester) async {
      await pump(tester);
      await type(tester, 'someone@example.com;');
      expect(addresses, ['someone@example.com']);
    });

    testWidgets('a space commits too', (tester) async {
      await pump(tester);
      await type(tester, 'someone@example.com ');
      expect(addresses, ['someone@example.com']);
    });

    testWidgets('submitting commits without a separator', (tester) async {
      await pump(tester);
      await tester.enterText(find.byType(TextField), 'someone@example.com');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      expect(addresses, ['someone@example.com']);
    });

    testWidgets('typing alone does not commit', (tester) async {
      await pump(tester);
      await type(tester, 'someone@example.com');
      expect(addresses, isEmpty);
    });
  });

  group('pasting', () {
    testWidgets('a comma-separated list becomes several chips',
        (tester) async {
      await pump(tester);
      await type(tester, 'a@x.com, b@y.com, c@z.com');

      expect(addresses, ['a@x.com', 'b@y.com', 'c@z.com']);
    });

    testWidgets('a Name <addr> form stays one address', (tester) async {
      await pump(tester);
      // The space in the display name must not split it.
      await type(tester, 'Bunny Hopper <p@example.com>,');

      expect(addresses, ['p@example.com']);
    });

    testWidgets('a duplicate is not added twice', (tester) async {
      await pump(tester);
      await type(tester, 'a@x.com,');
      await type(tester, 'a@x.com,');

      expect(addresses, ['a@x.com']);
    });
  });

  group('editing', () {
    testWidgets('an invalid address is flagged but still accepted',
        (tester) async {
      await pump(tester);
      await type(tester, 'not-an-address,');

      // Accepted — only the server gets to refuse an address.
      expect(addresses, ['not-an-address']);

      final chip = tester.widget<InputChip>(find.byType(InputChip));
      expect(chip.tooltip, contains('does not look like a valid address'));
    });

    testWidgets('a valid address carries no warning', (tester) async {
      await pump(tester);
      await type(tester, 'fine@example.com,');

      final chip = tester.widget<InputChip>(find.byType(InputChip));
      expect(chip.tooltip, isNull);
    });

    testWidgets('deleting a chip removes it', (tester) async {
      await pump(tester);
      await type(tester, 'a@x.com,');
      expect(addresses, ['a@x.com']);

      // Invoking the callback rather than tapping a specific icon, so the
      // test does not break when Material changes the chip's delete glyph.
      tester.widget<InputChip>(find.byType(InputChip)).onDeleted!();
      await tester.pumpAndSettle();

      expect(addresses, isEmpty);
    });

    testWidgets('tapping a chip puts it back in the field to fix',
        (tester) async {
      await pump(tester);
      await type(tester, 'typo@exmaple.com,');

      await tester.tap(find.text('typo@exmaple.com'));
      await tester.pumpAndSettle();

      // Removed from the chips, returned to the text field.
      expect(addresses, isEmpty);
      final field = tester.widget<TextField>(find.byType(TextField));
      expect(field.controller?.text, 'typo@exmaple.com');
    });
  });
}
