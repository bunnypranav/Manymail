// Manymail - Many addresses, one app.
// Copyright (C) 2026 Bunny Pranav
// SPDX-License-Identifier: GPL-3.0-or-later
//
// This file is part of Manymail, distributed under the GNU General Public
// License v3 or later. See the LICENSE file at the root of this repository.

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

import '../../../data/models/message_attachment.dart';
import 'cid_image_embed.dart';

/// The message body, in whichever mode the message is being written.
///
/// Rich mode produces HTML (plus a derived plain-text alternative). Plain mode
/// is a plain text field and produces **no** `text/html` part at all — that is
/// the whole point of the toggle, not a cosmetic difference.
class RichBodyEditor extends StatelessWidget {
  const RichBodyEditor({
    required this.isHtml,
    required this.quillController,
    required this.plainController,
    required this.quillFocusNode,
    required this.onToggleMode,
    this.attachments = const [],
    super.key,
  });

  final bool isHtml;
  final QuillController quillController;
  final TextEditingController plainController;
  final FocusNode quillFocusNode;

  /// Needed to render inline images: the document stores them as
  /// `cid:<contentId>`, which only the attachment list can resolve to a file.
  final List<MessageAttachment> attachments;

  /// Asked to switch modes. The composer confirms first when switching would
  /// lose formatting.
  final ValueChanged<bool> onToggleMode;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Both modes get the same frame. Plain mode previously had no border
    // at all, which left no way to see where the body began or ended.
    final bodyFrame = BoxDecoration(
      border: Border.all(color: theme.colorScheme.outlineVariant),
      borderRadius: BorderRadius.circular(8),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Message', style: theme.textTheme.labelLarge),
            const Spacer(),
            SegmentedButton<bool>(
              segments: const [
                ButtonSegment(
                  value: true,
                  icon: Icon(Icons.text_format, size: 18),
                  label: Text('Rich'),
                ),
                ButtonSegment(
                  value: false,
                  icon: Icon(Icons.notes, size: 18),
                  label: Text('Plain'),
                ),
              ],
              selected: {isHtml},
              showSelectedIcon: false,
              style: const ButtonStyle(
                visualDensity: VisualDensity.compact,
              ),
              onSelectionChanged: (selection) =>
                  onToggleMode(selection.first),
            ),
          ],
        ),
        const SizedBox(height: 8),

        if (isHtml) ...[
          // Only the formatting this app can actually render into email HTML.
          QuillSimpleToolbar(
            controller: quillController,
            config: const QuillSimpleToolbarConfig(
              multiRowsDisplay: false,
              showFontFamily: false,
              showFontSize: false,
              showBackgroundColorButton: false,
              showColorButton: false,
              showSearchButton: false,
              showSubscript: false,
              showSuperscript: false,
              showIndent: false,
              showAlignmentButtons: false,
              showDirection: false,
              showClearFormat: true,
              showCodeBlock: true,
              showInlineCode: true,
              showQuote: true,
              showLink: true,
              showListBullets: true,
              showListNumbers: true,
              showListCheck: false,
              showHeaderStyle: true,
              showStrikeThrough: true,
              showUnderLineButton: true,
              showDividers: false,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            constraints: const BoxConstraints(minHeight: 220),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            decoration: bodyFrame,
            child: QuillEditor.basic(
              controller: quillController,
              focusNode: quillFocusNode,
              config: QuillEditorConfig(
                placeholder: 'Write your message…',
                padding: EdgeInsets.zero,
                expands: false,
                autoFocus: false,
                // The editor lives inside the composer's ListView.
                scrollable: false,
                // Without these an inserted image throws while building the
                // line, and a release build paints the whole editor grey.
                embedBuilders: [CidImageEmbedBuilder(attachments)],
                unknownEmbedBuilder: const UnknownEmbedBuilder(),
              ),
            ),
          ),
        ] else
          Container(
            constraints: const BoxConstraints(minHeight: 220),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: bodyFrame,
            child: TextField(
              controller: plainController,
              decoration: const InputDecoration(
                hintText: 'Write your message…',
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 8),
              ),
              keyboardType: TextInputType.multiline,
              maxLines: null,
              minLines: 9,
              textCapitalization: TextCapitalization.sentences,
            ),
          ),
      ],
    );
  }
}
