// Manymail - Many addresses, one app.
// Copyright (C) 2026 Bunny Pranav
// SPDX-License-Identifier: GPL-3.0-or-later
//
// This file is part of Manymail, distributed under the GNU General Public
// License v3 or later. See the LICENSE file at the root of this repository.

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/licensing.dart';
import '../../data/models/app_settings.dart';
import '../../data/models/mail_domain.dart';
import '../../data/models/message_attachment.dart';
import '../../providers.dart';
import 'export_import/config_crypto.dart';
import 'export_import/config_export.dart';

/// Preferences, backup and the about page.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsProvider);
    final domains = ref.watch(domainsProvider).value ?? const <MailDomain>[];

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: settingsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('$error')),
        data: (settings) => ListView(
          padding: const EdgeInsets.only(bottom: 32),
          children: [
            const _Header('Composing'),

            ListTile(
              title: const Text('Default domain'),
              subtitle: Text(
                _defaultDomainLabel(settings, domains),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _chooseDefaultDomain(context, ref, domains),
            ),

            SwitchListTile(
              title: const Text('Start new messages in rich text'),
              subtitle: const Text(
                'Off writes plain text only, with no HTML part',
              ),
              value: settings.composeHtmlByDefault,
              onChanged: (value) => ref
                  .read(settingsRepositoryProvider)
                  .update((s) => s.copyWith(composeHtmlByDefault: value)),
            ),

            ListTile(
              title: const Text('Signature'),
              subtitle: Text(
                settings.defaultSignature?.isNotEmpty ?? false
                    ? settings.defaultSignature!.split('\n').first
                    : 'None',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _editSignature(context, ref, settings),
            ),

            const Divider(),
            const _Header('Attachments and history'),

            ListTile(
              title: const Text('Warn above'),
              subtitle: Text(
                '${formatBytes(settings.attachmentWarnBytes)} of attachments',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _chooseThreshold(context, ref, settings),
            ),

            SwitchListTile(
              title: const Text('Keep attachment files after sending'),
              subtitle: const Text(
                'Off keeps only names, sizes and types in the sent log',
              ),
              value: settings.keepSentAttachments,
              onChanged: (value) => ref
                  .read(settingsRepositoryProvider)
                  .update((s) => s.copyWith(keepSentAttachments: value)),
            ),

            ListTile(
              title: const Text('Keep sent history'),
              subtitle: Text(
                settings.keepSentForever
                    ? 'Forever'
                    : 'For ${settings.sentLogRetentionDays} days',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _chooseRetention(context, ref, settings),
            ),

            const Divider(),
            const _Header('Security'),

            SwitchListTile(
              title: const Text('Lock the app'),
              subtitle: const Text(
                'Ask for biometrics or your device PIN when opening Manymail',
              ),
              value: settings.biometricLockEnabled,
              onChanged: (value) => ref
                  .read(settingsRepositoryProvider)
                  .update((s) => s.copyWith(biometricLockEnabled: value)),
            ),

            const Divider(),
            const _Header('Backup'),

            ListTile(
              leading: const Icon(Icons.lock_outline),
              title: const Text('Export, encrypted'),
              subtitle: const Text(
                'Domains, identities and SMTP passwords, sealed with a '
                'passphrase you choose',
              ),
              onTap: () => _exportEncrypted(context, ref),
            ),
            ListTile(
              leading: const Icon(Icons.lock_open),
              title: const Text('Export, unencrypted'),
              subtitle: const Text(
                'Readable file with passwords left out entirely',
              ),
              onTap: () => _exportPlain(context, ref),
            ),
            ListTile(
              leading: const Icon(Icons.download_outlined),
              title: const Text('Import configuration'),
              onTap: () => _import(context, ref),
            ),

            const Divider(),
            const _Header('About'),
            const ListTile(
              title: Text(Licensing.appName),
              subtitle: Text(
                '${Licensing.tagline} · version ${Licensing.version}',
              ),
            ),
            ListTile(
              leading: const Icon(Icons.balance_outlined),
              title: const Text('Licence'),
              subtitle: const Text(
                '${Licensing.licenseName}\n${Licensing.copyright}\n\n'
                'Manymail comes with ABSOLUTELY NO WARRANTY. It is free '
                'software, and you are welcome to redistribute it under '
                'the terms of the GPL.',
              ),
              isThreeLine: true,
              onTap: () => _showLicences(context),
            ),
            ListTile(
              leading: const Icon(Icons.code),
              title: const Text('Open source licences'),
              subtitle: const Text(
                'The full GPL text, and the licence of every bundled package',
              ),
              onTap: () => _showLicences(context),
            ),
            const ListTile(
              leading: Icon(Icons.folder_open_outlined),
              title: Text('Source code'),
              subtitle: Text(
                '${Licensing.sourceUrl}\n\n'
                'The GPL entitles you to the complete source of the version '
                'you are running. Build it yourself and compare.',
              ),
              isThreeLine: true,
            ),
            const ListTile(
              title: Text('Privacy'),
              subtitle: Text(
                'No analytics, no telemetry, no crash reporting. The app '
                'connects to the SMTP servers you configure and nothing else. '
                'Everything it knows is stored on this device.',
              ),
            ),
            const ListTile(
              title: Text('Passwords'),
              subtitle: Text(
                'SMTP passwords are kept in the Android Keystore, never in the '
                'app database, and are redacted from every protocol transcript.',
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _defaultDomainLabel(AppSettings settings, List<MailDomain> domains) {
    if (domains.isEmpty) return 'No domains configured';
    final marked = domains.where((d) => d.isDefault).firstOrNull;
    return marked == null
        ? '${domains.first.label} (first configured)'
        : '${marked.label} · @${marked.domain}';
  }

  Future<void> _chooseDefaultDomain(
    BuildContext context,
    WidgetRef ref,
    List<MailDomain> domains,
  ) async {
    if (domains.isEmpty) return;
    final chosen = await showDialog<MailDomain>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Default domain'),
        children: [
          for (final domain in domains)
            SimpleDialogOption(
              onPressed: () => Navigator.of(context).pop(domain),
              child: Text('${domain.label} · @${domain.domain}'),
            ),
        ],
      ),
    );
    if (chosen == null) return;
    await ref.read(domainRepositoryProvider).setDefault(chosen.id);
  }

  Future<void> _editSignature(
    BuildContext context,
    WidgetRef ref,
    AppSettings settings,
  ) async {
    final controller = TextEditingController(
      text: settings.defaultSignature ?? '',
    );
    final saved = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Signature'),
        content: TextField(
          controller: controller,
          maxLines: 6,
          decoration: const InputDecoration(
            hintText: '—\nBunny',
            helperText: 'Added to new messages, and editable there',
            helperMaxLines: 2,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(controller.text),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (saved == null) return;
    await ref.read(settingsRepositoryProvider).update(
      (s) => s.copyWith(defaultSignature: saved.trim().isEmpty ? null : saved),
    );
  }

  Future<void> _chooseThreshold(
    BuildContext context,
    WidgetRef ref,
    AppSettings settings,
  ) async {
    const options = [5, 10, 20, 25, 50];
    final chosen = await showDialog<int>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Warn above'),
        children: [
          for (final mb in options)
            SimpleDialogOption(
              onPressed: () => Navigator.of(context).pop(mb),
              child: Text('$mb MB'),
            ),
        ],
      ),
    );
    if (chosen == null) return;
    await ref.read(settingsRepositoryProvider).update(
      (s) => s.copyWith(attachmentWarnBytes: chosen * 1024 * 1024),
    );
  }

  Future<void> _chooseRetention(
    BuildContext context,
    WidgetRef ref,
    AppSettings settings,
  ) async {
    const options = {0: 'Keep forever', 30: '30 days', 90: '90 days',
      365: 'One year'};
    final chosen = await showDialog<int>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Keep sent history'),
        children: [
          for (final entry in options.entries)
            SimpleDialogOption(
              onPressed: () => Navigator.of(context).pop(entry.key),
              child: Text(entry.value),
            ),
        ],
      ),
    );
    if (chosen == null) return;

    await ref
        .read(settingsRepositoryProvider)
        .update((s) => s.copyWith(sentLogRetentionDays: chosen));
    // Apply the new limit immediately rather than at some unclear later point.
    final pruned = await ref
        .read(messageRepositoryProvider)
        .pruneSentOlderThan(chosen);
    if (context.mounted && pruned > 0) {
      _snack(context, 'Removed $pruned older sent message'
          '${pruned == 1 ? '' : 's'}');
    }
  }

  // ------------------------------------------------------------ export

  Future<void> _exportEncrypted(BuildContext context, WidgetRef ref) async {
    final passphrase = await _askForPassphrase(
      context,
      title: 'Choose a passphrase',
      message:
          'The export is encrypted with this passphrase. There is no way to '
          'recover the file without it.',
      confirm: true,
    );
    if (passphrase == null || !context.mounted) return;

    _snack(context, 'Encrypting…');
    try {
      final contents = await ConfigExport(
        domains: ref.read(domainRepositoryProvider),
        settings: ref.read(settingsRepositoryProvider),
      ).encryptedFile(passphrase);

      final uri = await _save(contents, 'manymail-config', '.mmconfig.json');
      if (!context.mounted) return;
      if (uri == null) {
        _snack(context, 'Export cancelled. Nothing was written.');
        return;
      }
      _showWrittenTo(context, uri, encrypted: true);
    } catch (error) {
      if (context.mounted) _snack(context, 'Export failed: $error');
    }
  }

  Future<void> _exportPlain(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export without encryption?'),
        content: const Text(
          'The file will be readable by anything that can reach it, so SMTP '
          'passwords are left out of it entirely. After importing you will '
          'need to enter each password again.\n\n'
          'The file says so too, in case you find it later.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Export without passwords'),
          ),
        ],
      ),
    );
    if (!(confirmed ?? false) || !context.mounted) return;

    try {
      final contents = await ConfigExport(
        domains: ref.read(domainRepositoryProvider),
        settings: ref.read(settingsRepositoryProvider),
      ).plainFile();

      final uri = await _save(contents, 'manymail-config-plain', '.json');
      if (!context.mounted) return;
      if (uri == null) {
        _snack(context, 'Export cancelled. Nothing was written.');
        return;
      }
      _showWrittenTo(context, uri, encrypted: false);
    } catch (error) {
      if (context.mounted) _snack(context, 'Export failed: $error');
    }
  }

  /// The Downloads folder, as the Storage Access Framework addresses it.
  ///
  /// Used as the save sheet's starting point. Honoured on Android 8 and above;
  /// older versions simply open wherever they last were.
  static const String _downloadsUri =
      'content://com.android.externalstorage.documents/document/primary%3ADownload';

  /// Saves an export through the system save sheet, starting in Downloads.
  ///
  /// Exports used to be written to the app's private documents directory,
  /// where nothing else on the device could reach them — which made a backup
  /// you could not actually retrieve.
  ///
  /// The sheet is used rather than writing straight into `/Download` because
  /// doing that needs `WRITE_EXTERNAL_STORAGE` on API 28 and below, or a
  /// MediaStore insert through a platform channel above it. Manymail ships no
  /// runtime permission prompts at all, and a backup file is not worth being
  /// the first. The sheet costs one tap and shows the user exactly where the
  /// file landed.
  ///
  /// Returns the saved file's URI, or null if the user backed out.
  Future<Uri?> _save(String contents, String baseName, String extension) {
    final now = DateTime.now();
    String two(int value) => value.toString().padLeft(2, '0');
    final stamp = '${now.year}${two(now.month)}${two(now.day)}'
        '-${two(now.hour)}${two(now.minute)}';

    return FilePicker.saveFile(
      fileName: '$baseName-$stamp$extension',
      bytes: Uint8List.fromList(utf8.encode(contents)),
      mimeType: 'application/json',
      dialogTitle: 'Save Manymail configuration',
      initialDirectory: _downloadsUri,
    );
  }

  /// Turns what the save sheet hands back into something a person can act on.
  ///
  /// Android returns only the document URI's *path*, not a full `content://`
  /// URI — `/document/primary:Download/manymail-config-….json`. Everything
  /// after the storage volume's colon is the path the user can navigate to,
  /// so that is what gets shown: `Download/manymail-config-….json`.
  String _readableLocation(Uri uri) {
    if (uri.scheme == 'file') return uri.toFilePath();

    final path = Uri.decodeFull(uri.hasScheme ? uri.path : uri.toString());
    final colon = path.indexOf(':');
    if (colon >= 0 && colon < path.length - 1) return path.substring(colon + 1);

    // Providers with opaque document ids, Drive among them, have nothing
    // useful to strip. Show what we were given rather than inventing a path.
    return path;
  }

  void _showWrittenTo(
    BuildContext context,
    Uri uri, {
    required bool encrypted,
  }) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(encrypted ? 'Encrypted export saved' : 'Export saved'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!encrypted)
              const Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: Text('Passwords were not included.'),
              ),
            SelectableText(
              _readableLocation(uri),
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
            ),
          ],
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------ import

  Future<void> _import(BuildContext context, WidgetRef ref) async {
    final picked = await FilePicker.pickFile(dialogTitle: 'Import');
    final path = picked?.path;
    if (path == null || !context.mounted) return;

    final contents = await File(path).readAsString();
    final importer = ConfigImport(
      domains: ref.read(domainRepositoryProvider),
      settings: ref.read(settingsRepositoryProvider),
    );

    ImportPreview preview;
    try {
      preview = await importer.preview(fileContents: contents);
    } on ConfigCryptoException catch (error) {
      // An encrypted file needs its passphrase before it can be read at all.
      if (!error.message.contains('encrypted')) {
        if (context.mounted) _snack(context, error.message);
        return;
      }
      if (!context.mounted) return;
      final passphrase = await _askForPassphrase(
        context,
        title: 'Passphrase',
        message: 'This file is encrypted.',
        confirm: false,
      );
      if (passphrase == null || !context.mounted) return;
      try {
        preview = await importer.preview(
          fileContents: contents,
          passphrase: passphrase,
        );
      } on ConfigCryptoException catch (error) {
        if (context.mounted) _snack(context, error.message);
        return;
      }
    }

    if (!context.mounted) return;
    final mode = await showDialog<ImportMode>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Import ${preview.domains.length} domain'
            '${preview.domains.length == 1 ? '' : 's'}?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!preview.hasPasswords)
              const Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: Text(
                  'This file has no passwords in it. You will need to enter '
                  'each one after importing.',
                ),
              ),
            for (final mode in ImportMode.values)
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(mode.label),
                subtitle: Text(mode.description),
                onTap: () => Navigator.of(context).pop(mode),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
    if (mode == null) return;

    final count = await importer.apply(preview, mode);
    if (context.mounted) {
      _snack(context, 'Imported $count domain${count == 1 ? '' : 's'}');
    }
  }

  /// Asks for a passphrase, optionally twice so a typo cannot lock a backup.
  Future<String?> _askForPassphrase(
    BuildContext context, {
    required String title,
    required String message,
    required bool confirm,
  }) async {
    final first = TextEditingController();
    final second = TextEditingController();
    // Declared outside the builder: a value set inside it would be reset on
    // every rebuild, so the message would never appear.
    String? error;

    final result = await showDialog<String>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(title),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(message),
                const SizedBox(height: 12),
                TextField(
                  controller: first,
                  obscureText: true,
                  autofocus: true,
                  decoration: const InputDecoration(labelText: 'Passphrase'),
                ),
                if (confirm) ...[
                  const SizedBox(height: 8),
                  TextField(
                    controller: second,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Repeat passphrase',
                    ),
                  ),
                ],
                if (error != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      error!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () {
                  if (first.text.isEmpty) {
                    setState(() => error = 'Enter a passphrase.');
                    return;
                  }
                  if (confirm && first.text != second.text) {
                    setState(() => error = 'The two do not match.');
                    return;
                  }
                  Navigator.of(context).pop(first.text);
                },
                child: const Text('Continue'),
              ),
            ],
          );
        },
      ),
    );
    first.dispose();
    second.dispose();
    return result;
  }

  void _snack(BuildContext context, String text) =>
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(text)),
      );
}

class _Header extends StatelessWidget {
  const _Header(this.title);

  final String title;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
    child: Text(
      title,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
        color: Theme.of(context).colorScheme.primary,
      ),
    ),
  );
}

/// Flutter's built-in licences page, seeded with Manymail's own identity so
/// the GPL notice appears above the bundled packages' licences.
void _showLicences(BuildContext context) {
  showLicensePage(
    context: context,
    applicationName: Licensing.appName,
    applicationVersion: 'Version ${Licensing.version}',
    applicationLegalese: Licensing.legalese,
    applicationIcon: const Padding(
      padding: EdgeInsets.symmetric(vertical: 12),
      child: Icon(Icons.mail_outline, size: 48),
    ),
  );
}
