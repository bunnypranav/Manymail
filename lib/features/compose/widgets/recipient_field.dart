// Manymail - Many addresses, one app.
// Copyright (C) 2026 Bunny Pranav
// SPDX-License-Identifier: GPL-3.0-or-later
//
// This file is part of Manymail, distributed under the GNU General Public
// License v3 or later. See the LICENSE file at the root of this repository.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/validation/rfc5322.dart';

/// Chip-style recipient entry.
///
/// Comma, semicolon, space and Enter commit the current text as a chip; a
/// pasted list is split into several. Tapping a chip puts it back in the text
/// field for editing. Addresses that do not look valid are highlighted but
/// never rejected — as everywhere in this app, the server gets the final say.
class RecipientField extends StatefulWidget {
  const RecipientField({
    required this.label,
    required this.addresses,
    required this.onChanged,
    this.autofocus = false,
    this.trailing,
    super.key,
  });

  final String label;
  final List<String> addresses;
  final ValueChanged<List<String>> onChanged;
  final bool autofocus;

  /// Extra control shown beside the label, e.g. the Cc/Bcc toggle.
  final Widget? trailing;

  @override
  State<RecipientField> createState() => _RecipientFieldState();
}

class _RecipientFieldState extends State<RecipientField> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Committing on blur means a half-typed address is not silently lost when
    // the user taps straight into the subject.
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) _commit(_controller.text);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    // A trailing separator means "that address is finished".
    if (value.isEmpty) return;
    final last = value[value.length - 1];
    if (last == ',' || last == ';' || last == ' ' || last == '\n') {
      _commit(value.substring(0, value.length - 1));
      return;
    }
    // A paste can arrive as one change containing several addresses.
    if (value.contains(',') || value.contains(';') || value.contains('\n')) {
      _commit(value);
    }
  }

  void _commit(String value) {
    final parsed = splitAddressList(value);
    if (parsed.isEmpty) {
      if (value.trim().isEmpty) _controller.clear();
      return;
    }
    final next = [...widget.addresses];
    for (final address in parsed) {
      if (!next.contains(address)) next.add(address);
    }
    _controller.clear();
    widget.onChanged(next);
  }

  void _remove(String address) {
    widget.onChanged(
      widget.addresses.where((a) => a != address).toList(),
    );
  }

  /// Moves a chip back into the text field so it can be corrected.
  void _edit(String address) {
    _remove(address);
    _controller.text = address;
    _controller.selection = TextSelection.collapsed(offset: address.length);
    _focusNode.requestFocus();
  }

  /// Backspace on an empty field removes the last chip, as in every other
  /// recipient field people have used.
  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    if (event.logicalKey != LogicalKeyboardKey.backspace) {
      return KeyEventResult.ignored;
    }
    if (_controller.text.isNotEmpty || widget.addresses.isEmpty) {
      return KeyEventResult.ignored;
    }
    _edit(widget.addresses.last);
    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(widget.label, style: theme.textTheme.labelLarge),
            const Spacer(),
            if (widget.trailing != null) widget.trailing!,
          ],
        ),
        const SizedBox(height: 4),
        // The text field is only as wide as its content, so without this the
        // only way to add a second address is to hit the narrow strip after
        // the last chip. Tapping anywhere in the row now focuses the field.
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            if (!_focusNode.hasFocus) _focusNode.requestFocus();
          },
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(minHeight: 44),
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Wrap(
              spacing: 6,
              runSpacing: 2,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                for (final address in widget.addresses)
                  _Chip(
                    address: address,
                    valid: isPlausibleEmail(address),
                    onTap: () => _edit(address),
                    onRemove: () => _remove(address),
                  ),
                ConstrainedBox(
                  constraints: const BoxConstraints(minWidth: 140),
                  child: IntrinsicWidth(
                    child: Focus(
                      onKeyEvent: _onKey,
                      child: TextField(
                        controller: _controller,
                        focusNode: _focusNode,
                        autofocus: widget.autofocus,
                        keyboardType: TextInputType.emailAddress,
                        autocorrect: false,
                        enableSuggestions: false,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          isDense: true,
                          hintText: widget.addresses.isEmpty
                              ? 'name@example.com'
                              : null,
                          hintStyle: TextStyle(color: scheme.outline),
                        ),
                        onChanged: _onChanged,
                        onSubmitted: _commit,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const Divider(height: 12),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.address,
    required this.valid,
    required this.onTap,
    required this.onRemove,
  });

  final String address;
  final bool valid;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InputChip(
      label: Text(address),
      onPressed: onTap,
      onDeleted: onRemove,
      visualDensity: VisualDensity.compact,
      backgroundColor: valid ? null : scheme.errorContainer,
      side: valid ? null : BorderSide(color: scheme.error),
      labelStyle: valid ? null : TextStyle(color: scheme.onErrorContainer),
      tooltip: valid ? null : 'This does not look like a valid address',
    );
  }
}
