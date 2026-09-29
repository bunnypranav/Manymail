// Manymail - Many addresses, one app.
// Copyright (C) 2026 Bunny Pranav
// SPDX-License-Identifier: GPL-3.0-or-later
//
// This file is part of Manymail, distributed under the GNU General Public
// License v3 or later. See the LICENSE file at the root of this repository.

import 'package:flutter_test/flutter_test.dart';
import 'package:manymail/core/rich_text/body_converter.dart';

/// Delta ops as flutter_quill produces them: line formatting lives on the
/// newline that *ends* the line, not on the text itself.
void main() {
  group('plain text', () {
    test('keeps ordinary paragraphs', () {
      expect(
        BodyConverter.toPlainText([
          {'insert': 'First line\nSecond line\n'},
        ]),
        'First line\nSecond line',
      );
    });

    test('marks bullet lists', () {
      expect(
        BodyConverter.toPlainText([
          {'insert': 'Apples'},
          {
            'insert': '\n',
            'attributes': {'list': 'bullet'},
          },
          {'insert': 'Pears'},
          {
            'insert': '\n',
            'attributes': {'list': 'bullet'},
          },
        ]),
        '- Apples\n- Pears',
      );
    });

    test('numbers ordered lists', () {
      expect(
        BodyConverter.toPlainText([
          {'insert': 'First'},
          {
            'insert': '\n',
            'attributes': {'list': 'ordered'},
          },
          {'insert': 'Second'},
          {
            'insert': '\n',
            'attributes': {'list': 'ordered'},
          },
          {'insert': 'Third'},
          {
            'insert': '\n',
            'attributes': {'list': 'ordered'},
          },
        ]),
        '1. First\n2. Second\n3. Third',
      );
    });

    test('restarts numbering after a plain paragraph', () {
      final text = BodyConverter.toPlainText([
        {'insert': 'One'},
        {
          'insert': '\n',
          'attributes': {'list': 'ordered'},
        },
        {'insert': 'Interruption\n'},
        {'insert': 'One again'},
        {
          'insert': '\n',
          'attributes': {'list': 'ordered'},
        },
      ]);

      expect(text, '1. One\nInterruption\n1. One again');
    });

    test('prefixes blockquotes and indents code', () {
      expect(
        BodyConverter.toPlainText([
          {'insert': 'Quoted'},
          {
            'insert': '\n',
            'attributes': {'blockquote': true},
          },
          {'insert': 'code()'},
          {
            'insert': '\n',
            'attributes': {'code-block': true},
          },
        ]),
        '> Quoted\n    code()',
      );
    });

    test('shows where a link actually points', () {
      final text = BodyConverter.toPlainText([
        {'insert': 'See '},
        {
          'insert': 'the docs',
          'attributes': {'link': 'https://example.com/docs'},
        },
        {'insert': ' for more\n'},
      ]);

      // A bare label is useless once the markup is gone.
      expect(text, contains('the docs <https://example.com/docs>'));
    });

    test('skips embeds, which have no textual form', () {
      final text = BodyConverter.toPlainText([
        {'insert': 'Before\n'},
        {
          'insert': {'image': 'cid:abc@manymail'},
        },
        {'insert': 'After\n'},
      ]);

      expect(text, 'Before\nAfter');
    });

    test('handles text with no trailing newline', () {
      expect(
        BodyConverter.toPlainText([
          {'insert': 'No trailing newline'},
        ]),
        'No trailing newline',
      );
    });
  });

  group('isEmpty', () {
    test('an untouched document counts as empty', () {
      // Quill always holds at least one newline.
      expect(
        BodyConverter.isEmpty([
          {'insert': '\n'},
        ]),
        isTrue,
      );
      expect(BodyConverter.isEmpty([]), isTrue);
    });

    test('whitespace alone still counts as empty', () {
      expect(
        BodyConverter.isEmpty([
          {'insert': '   \n\n'},
        ]),
        isTrue,
      );
    });

    test('real text does not', () {
      expect(
        BodyConverter.isEmpty([
          {'insert': 'Hello\n'},
        ]),
        isFalse,
      );
    });
  });

  group('html', () {
    test('wraps the fragment in a minimal document', () {
      final html = BodyConverter.toHtml([
        {'insert': 'Hello\n'},
      ]);

      expect(html, startsWith('<!DOCTYPE html>'));
      expect(html, contains('charset="utf-8"'));
      expect(html, contains('Hello'));
      expect(html, contains('</html>'));
    });

    test('renders formatting as inline styles, not a stylesheet', () {
      final html = BodyConverter.toHtml([
        {
          'insert': 'bold',
          'attributes': {'bold': true},
        },
        {'insert': '\n'},
      ]);

      expect(html, contains('<strong>bold</strong>'));
      // Mail clients strip <style> blocks, and some treat them as spam signal.
      expect(html, isNot(contains('<style')));
      expect(html, isNot(contains('<script')));
    });

    test('renders lists as list markup', () {
      final html = BodyConverter.toHtml([
        {'insert': 'Item'},
        {
          'insert': '\n',
          'attributes': {'list': 'bullet'},
        },
      ]);

      expect(html, contains('<ul>'));
      expect(html, contains('<li>'));
    });

    test('keeps a cid: image reference intact', () {
      final html = BodyConverter.toHtml([
        {
          'insert': {'image': 'cid:abc@manymail'},
        },
        {'insert': '\n'},
      ]);

      // The MIME part is matched by exactly this reference.
      expect(html, contains('cid:abc@manymail'));
    });
  });
}
