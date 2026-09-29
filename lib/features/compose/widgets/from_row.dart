// Manymail - Many addresses, one app.
// Copyright (C) 2026 Bunny Pranav
// SPDX-License-Identifier: GPL-3.0-or-later
//
// This file is part of Manymail, distributed under the GNU General Public
// License v3 or later. See the LICENSE file at the root of this repository.

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/validation/rfc5322.dart';
import '../../../data/models/mail_domain.dart';
import '../../../providers.dart';

/// The sender identity editor: domain, saved-identity quick-pick, and the two
/// free-text fields that make this app what it is.
///
/// Nothing here is derived from the SMTP username. The local part and display
/// name are yours to type, every message, and the preview shows exactly what
/// will go on the wire.
class FromRow extends ConsumerWidget {
  const FromRow({
    required this.domains,
    required this.selectedDomain,
    required this.localPart,
    required this.displayName,
    required this.onDomainChanged,
    required this.onLocalPartChanged,
    required this.onDisplayNameChanged,
    required this.onPresetSelected,
    required this.localPartController,
    required this.displayNameController,
    super.key,
  });

  final List<MailDomain> domains;
  final MailDomain? selectedDomain;
  final String localPart;
  final String displayName;
  final ValueChanged<MailDomain> onDomainChanged;
  final ValueChanged<String> onLocalPartChanged;
  final ValueChanged<String> onDisplayNameChanged;
  final ValueChanged<IdentityPreset> onPresetSelected;

  final TextEditingController localPartController;
  final TextEditingController displayNameController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final domain = selectedDomain;
    final validation = validateLocalPart(localPart);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('From', style: theme.textTheme.labelLarge),
        const SizedBox(height: 8),

        DropdownButtonFormField<int>(
          initialValue: domain?.id,
          decoration: const InputDecoration(labelText: 'Domain'),
          items: [
            for (final d in domains)
              DropdownMenuItem(
                value: d.id,
                child: Text('${d.label} · @${d.domain}'),
              ),
          ],
          onChanged: (id) {
            final next = domains.where((d) => d.id == id).firstOrNull;
            if (next != null) onDomainChanged(next);
          },
        ),

        if (domain != null) _PresetChips(
          domainId: domain.id,
          onSelected: onPresetSelected,
        ),

        const SizedBox(height: 12),

        // A long domain used to squeeze the address field down to a few
        // characters, because the `@domain` suffix is drawn inside it. Measure
        // the suffix and give the address room, dropping to a stacked layout
        // and then to a helper line as the domain grows.
        LayoutBuilder(
          builder: (context, constraints) {
            final suffix = domain == null ? '' : '@${domain.domain}';
            final suffixWidth = _textWidth(
              suffix,
              theme.textTheme.bodyLarge,
              constraints.maxWidth,
            );

            // Horizontal content padding of a filled TextField, both sides.
            const fieldPadding = 28.0;
            // Enough of the address field left to actually type into.
            const minTypingRoom = 90.0;
            // Below this the display name field is not worth showing beside it.
            const minDisplayWidth = 110.0;
            const gap = 8.0;

            // What the address field needs: the suffix, its padding, and room
            // to type. Never less than the 4:3 split it used to get.
            final wanted = suffixWidth + fieldPadding + minTypingRoom;
            final addressWidth =
                math.max(wanted, (constraints.maxWidth - gap) * 4 / 7);

            final fitsSideBySide =
                addressWidth + gap + minDisplayWidth <= constraints.maxWidth;

            // Longest domains: the suffix will not leave room to type even at
            // full width, so show it under the field instead of inside it.
            final suffixBelow =
                constraints.maxWidth - suffixWidth - fieldPadding <
                    minTypingRoom;

            final address = TextField(
              controller: localPartController,
              decoration: InputDecoration(
                labelText: 'Address',
                suffixText: suffixBelow || domain == null ? null : suffix,
                helperText: suffixBelow ? suffix : null,
                helperMaxLines: 2,
                // The hint is advisory — typing is never blocked.
                errorText: localPart.isEmpty ? null : validation.hint,
                errorMaxLines: 2,
              ),
              autocorrect: false,
              enableSuggestions: false,
              textCapitalization: TextCapitalization.none,
              onChanged: onLocalPartChanged,
            );

            final displayName = TextField(
              controller: displayNameController,
              decoration: const InputDecoration(labelText: 'Display name'),
              onChanged: onDisplayNameChanged,
            );

            if (!suffixBelow && fitsSideBySide) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(width: addressWidth, child: address),
                  const SizedBox(width: gap),
                  Expanded(child: displayName),
                ],
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                address,
                const SizedBox(height: 12),
                displayName,
              ],
            );
          },
        ),

        const SizedBox(height: 10),
        _Preview(
          text: domain == null
              ? 'Choose a domain'
              : formatMailbox(
                  displayName: displayName,
                  localPart: localPart,
                  domain: domain.domain,
                ),
          muted: domain == null || localPart.isEmpty,
        ),
      ],
    );
  }
}

/// Saved identities for the selected domain, as tappable chips.
class _PresetChips extends ConsumerWidget {
  const _PresetChips({required this.domainId, required this.onSelected});

  final int domainId;
  final ValueChanged<IdentityPreset> onSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final presets = ref.watch(presetsProvider(domainId)).value ?? const [];
    if (presets.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Wrap(
        spacing: 6,
        runSpacing: 4,
        children: [
          for (final preset in presets)
            ActionChip(
              label: Text(preset.name),
              visualDensity: VisualDensity.compact,
              onPressed: () => onSelected(preset),
            ),
        ],
      ),
    );
  }
}

/// Live preview of the assembled From header.
class _Preview extends StatelessWidget {
  const _Preview({required this.text, required this.muted});

  final String text;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recipients will see',
            style: Theme.of(context).textTheme.labelSmall,
          ),
          const SizedBox(height: 2),
          SelectableText(
            text,
            style: TextStyle(
              fontFamily: 'monospace',
              color: muted ? scheme.outline : scheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

/// Width the given text occupies, so the layout can react to a long domain
/// instead of assuming one fits.
double _textWidth(String text, TextStyle? style, double maxWidth) {
  if (text.isEmpty) return 0;
  final painter = TextPainter(
    text: TextSpan(text: text, style: style),
    textDirection: TextDirection.ltr,
    maxLines: 1,
  )..layout(maxWidth: maxWidth);
  return painter.width;
}
