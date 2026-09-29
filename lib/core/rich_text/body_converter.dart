// Manymail - Many addresses, one app.
// Copyright (C) 2026 Bunny Pranav
// SPDX-License-Identifier: GPL-3.0-or-later
//
// This file is part of Manymail, distributed under the GNU General Public
// License v3 or later. See the LICENSE file at the root of this repository.

import 'package:vsc_quill_delta_to_html/vsc_quill_delta_to_html.dart';

/// Converts the editor's document into the two bodies a message carries.
///
/// A rich message is sent as `multipart/alternative`: the HTML for clients
/// that render it, and a plain-text alternative for those that do not. The
/// plain text is derived from the **Delta**, not by stripping tags out of the
/// HTML — going through the source document keeps list markers, quote markers
/// and link targets that tag-stripping would throw away.
abstract final class BodyConverter {
  /// Renders the document as an HTML fragment wrapped in a minimal document.
  ///
  /// Kept deliberately plain: no external CSS, no web fonts, no scripts —
  /// mail clients strip those anyway, and several treat them as a spam signal.
  static String toHtml(List<Map<String, dynamic>> deltaOps) {
    final body = QuillDeltaToHtmlConverter(
      deltaOps,
      ConverterOptions.forEmail(),
    ).convert();

    return '<!DOCTYPE html>\n'
        '<html>\n'
        '<head><meta charset="utf-8"></head>\n'
        '<body>\n'
        '$body\n'
        '</body>\n'
        '</html>';
  }

  /// Renders the document as readable plain text.
  ///
  /// Line-level formatting in Delta lives on the newline that *ends* a line,
  /// so text is buffered until a newline arrives and the attributes on that
  /// newline decide how the finished line is prefixed.
  static String toPlainText(List<Map<String, dynamic>> deltaOps) {
    final lines = <String>[];
    final current = StringBuffer();

    // Ordered lists restart at 1 whenever a non-list line interrupts them.
    var orderedIndex = 0;

    void finishLine(Map<String, dynamic>? attributes) {
      final text = current.toString();
      current.clear();

      final list = attributes?['list'];
      final isBlockquote = attributes?['blockquote'] == true;
      final isCode = attributes?['code-block'] == true;

      if (list == 'ordered') {
        orderedIndex++;
        lines.add('$orderedIndex. $text');
        return;
      }
      orderedIndex = 0;

      if (list == 'bullet') {
        lines.add('- $text');
      } else if (list == 'checked') {
        lines.add('[x] $text');
      } else if (list == 'unchecked') {
        lines.add('[ ] $text');
      } else if (isBlockquote) {
        lines.add('> $text');
      } else if (isCode) {
        lines.add('    $text');
      } else {
        lines.add(text);
      }
    }

    for (final op in deltaOps) {
      final insert = op['insert'];

      // Embeds (images, videos) are objects rather than strings. They have no
      // plain-text form, so they are skipped; the HTML part carries them.
      if (insert is! String) continue;

      final attributes = op['attributes'] as Map<String, dynamic>?;
      final link = attributes?['link'] as String?;

      final segments = insert.split('\n');
      for (var i = 0; i < segments.length; i++) {
        final segment = segments[i];
        if (segment.isNotEmpty) {
          current.write(segment);
          // Show where a link actually goes — a bare label is useless in text.
          if (link != null && link != segment) current.write(' <$link>');
        }
        // Every split point except the last represents a real newline.
        if (i < segments.length - 1) finishLine(attributes);
      }
    }

    // Anything left without a trailing newline is still a line.
    if (current.isNotEmpty) finishLine(null);

    return lines.join('\n').trimRight();
  }

  /// True when the document has no visible content.
  ///
  /// A Quill document is never truly empty — it always holds at least one
  /// newline — so "is it blank" needs asking properly.
  static bool isEmpty(List<Map<String, dynamic>> deltaOps) =>
      toPlainText(deltaOps).trim().isEmpty;
}
