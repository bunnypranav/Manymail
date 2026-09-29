// Manymail - Many addresses, one app.
// Copyright (C) 2026 Bunny Pranav
// SPDX-License-Identifier: GPL-3.0-or-later
//
// This file is part of Manymail, distributed under the GNU General Public
// License v3 or later. See the LICENSE file at the root of this repository.

import 'dart:convert';

import '../../../data/models/enums.dart';
import '../../../data/repositories/domain_repository.dart';
import '../../../data/repositories/settings_repository.dart';
import 'config_crypto.dart';

/// Builds and applies the configuration export.
///
/// Encrypted exports carry SMTP passwords. **Unencrypted exports never do** —
/// see [buildPayload]. There is no option to write passwords in the clear,
/// because a file like that is trivially readable by anything with access to
/// the storage it lands in.
class ConfigExport {
  const ConfigExport({
    required this.domains,
    required this.settings,
  });

  final DomainRepository domains;
  final SettingsRepository settings;

  /// Produces the exportable snapshot.
  ///
  /// [includePasswords] is only ever true for an encrypted export.
  Future<Map<String, dynamic>> buildPayload({
    required bool includePasswords,
  }) async {
    final all = await domains.getAll();
    final exported = <Map<String, dynamic>>[];

    for (final domain in all) {
      final presets = await domains.getPresets(domain.id);
      exported.add({
        'label': domain.label,
        'domain': domain.domain,
        'host': domain.host,
        'port': domain.port,
        'security': domain.security.name,
        'authMode': domain.authMode.name,
        'username': domain.username,
        if (includePasswords)
          'password': await domains.passwordFor(domain) ?? '',
        'allowInsecureCertificate': domain.allowInsecureCertificate,
        'timeoutSeconds': domain.timeoutSeconds,
        'defaultLocalPart': domain.defaultLocalPart,
        'defaultDisplayName': domain.defaultDisplayName,
        'defaultReplyTo': domain.defaultReplyTo,
        'isDefault': domain.isDefault,
        'presets': [
          for (final preset in presets)
            {
              'name': preset.name,
              'localPart': preset.localPart,
              'displayName': preset.displayName,
              'replyTo': preset.replyTo,
              'signature': preset.signature,
            },
        ],
      });
    }

    final current = await settings.get();
    return {
      'exportedAt': DateTime.now().toIso8601String(),
      'domains': exported,
      'settings': {
        'attachmentWarnBytes': current.attachmentWarnBytes,
        'sentLogRetentionDays': current.sentLogRetentionDays,
        'composeHtmlByDefault': current.composeHtmlByDefault,
        'keepSentAttachments': current.keepSentAttachments,
        'defaultSignature': current.defaultSignature,
        // biometricLockEnabled is deliberately not exported: it describes this
        // device's hardware, not the configuration.
      },
    };
  }

  /// The complete encrypted file, ready to write.
  Future<String> encryptedFile(String passphrase) async {
    final payload = await buildPayload(includePasswords: true);
    final envelope = await ConfigCrypto.encrypt(
      payload: payload,
      passphrase: passphrase,
    );
    return const JsonEncoder.withIndent('  ').convert(envelope);
  }

  /// A readable file with **passwords removed**.
  ///
  /// The exclusion is stated in the file itself, so someone opening it later
  /// is not left wondering why importing it fails to connect.
  Future<String> plainFile() async {
    final payload = await buildPayload(includePasswords: false);
    return const JsonEncoder.withIndent('  ').convert({
      'format': ConfigCrypto.formatMarker,
      'version': ConfigCrypto.formatVersion,
      'encrypted': false,
      'passwordsExcluded': true,
      'README':
          'This file is NOT encrypted. SMTP passwords have been excluded from '
          'it deliberately. After importing, open each domain and enter its '
          'password again. For a complete backup, use the encrypted export '
          'instead.',
      'payload': payload,
    });
  }
}

/// What an import found in a file, before anything is changed.
class ImportPreview {
  const ImportPreview({
    required this.domains,
    required this.hasPasswords,
    required this.settings,
  });

  final List<ImportedDomain> domains;

  /// False for a file exported without encryption, whose domains will need
  /// their passwords entered by hand.
  final bool hasPasswords;

  final Map<String, dynamic>? settings;
}

/// One domain read out of an import file.
class ImportedDomain {
  const ImportedDomain({required this.input, this.password, this.presets = const []});

  final DomainInput input;
  final String? password;
  final List<Map<String, dynamic>> presets;
}

/// How an import should treat what is already configured.
enum ImportMode {
  /// Add the imported domains alongside the existing ones.
  merge,

  /// Delete everything configured, then import.
  replace;

  String get label => switch (this) {
    ImportMode.merge => 'Merge',
    ImportMode.replace => 'Replace everything',
  };

  String get description => switch (this) {
    ImportMode.merge =>
      'Keep the domains you already have and add the imported ones.',
    ImportMode.replace =>
      'Delete every configured domain, identity and stored password first.',
  };
}

/// Reads an import file and applies it.
class ConfigImport {
  const ConfigImport({required this.domains, required this.settings});

  final DomainRepository domains;
  final SettingsRepository settings;

  /// Parses a file without changing anything, so the UI can show what would
  /// happen before asking to go ahead.
  Future<ImportPreview> preview({
    required String fileContents,
    String? passphrase,
  }) async {
    final Map<String, dynamic> envelope;
    try {
      final decoded = jsonDecode(fileContents);
      if (decoded is! Map<String, dynamic>) {
        throw const ConfigCryptoException('The file is not valid JSON.');
      }
      envelope = decoded;
    } catch (error) {
      if (error is ConfigCryptoException) rethrow;
      throw const ConfigCryptoException('The file is not valid JSON.');
    }

    if (envelope['format'] != ConfigCrypto.formatMarker) {
      throw const ConfigCryptoException(
        'This is not a Manymail configuration file.',
      );
    }

    final isEncrypted = envelope['encrypted'] == true;
    final Map<String, dynamic> payload;

    if (isEncrypted) {
      if (passphrase == null || passphrase.isEmpty) {
        throw const ConfigCryptoException(
          'This file is encrypted. Enter its passphrase to open it.',
        );
      }
      payload = await ConfigCrypto.decrypt(
        envelope: envelope,
        passphrase: passphrase,
      );
    } else {
      final raw = envelope['payload'];
      if (raw is! Map<String, dynamic>) {
        throw const ConfigCryptoException('The file has no contents.');
      }
      payload = raw;
    }

    final rawDomains = payload['domains'];
    if (rawDomains is! List) {
      throw const ConfigCryptoException('The file contains no domains.');
    }

    return ImportPreview(
      hasPasswords: isEncrypted,
      settings: payload['settings'] as Map<String, dynamic>?,
      domains: rawDomains.whereType<Map<String, dynamic>>().map(_toDomain)
          .toList(),
    );
  }

  /// Writes the previewed configuration.
  Future<int> apply(ImportPreview preview, ImportMode mode) async {
    if (mode == ImportMode.replace) {
      // Deleting through the repository takes each domain's stored password
      // with it, rather than leaving orphaned secrets in the keystore.
      for (final existing in await domains.getAll()) {
        await domains.delete(existing.id);
      }
    }

    for (final imported in preview.domains) {
      final id = await domains.create(
        imported.input,
        password: imported.password,
      );
      for (final preset in imported.presets) {
        await domains.createPreset(
          id,
          name: preset['name'] as String? ?? 'Imported',
          localPart: preset['localPart'] as String? ?? '',
          displayName: preset['displayName'] as String? ?? '',
          replyTo: preset['replyTo'] as String?,
          signature: preset['signature'] as String?,
        );
      }
    }

    final importedSettings = preview.settings;
    if (importedSettings != null) {
      await settings.update(
        (current) => current.copyWith(
          attachmentWarnBytes: importedSettings['attachmentWarnBytes'] as int?,
          sentLogRetentionDays:
              importedSettings['sentLogRetentionDays'] as int?,
          composeHtmlByDefault:
              importedSettings['composeHtmlByDefault'] as bool?,
          keepSentAttachments:
              importedSettings['keepSentAttachments'] as bool?,
          defaultSignature: importedSettings['defaultSignature'] as String?,
        ),
      );
    }

    return preview.domains.length;
  }

  ImportedDomain _toDomain(Map<String, dynamic> json) => ImportedDomain(
    password: json['password'] as String?,
    presets: (json['presets'] as List?)
            ?.whereType<Map<String, dynamic>>()
            .toList() ??
        const [],
    input: DomainInput(
      label: json['label'] as String? ?? 'Imported',
      domain: json['domain'] as String? ?? '',
      host: json['host'] as String? ?? '',
      port: json['port'] as int? ?? 587,
      security: _enumByName(
        SmtpSecurity.values,
        json['security'] as String?,
        SmtpSecurity.starttls,
      ),
      authMode: _enumByName(
        SmtpAuthMode.values,
        json['authMode'] as String?,
        SmtpAuthMode.auto,
      ),
      username: json['username'] as String? ?? '',
      allowInsecureCertificate:
          json['allowInsecureCertificate'] as bool? ?? false,
      timeoutSeconds: json['timeoutSeconds'] as int? ?? 30,
      defaultLocalPart: json['defaultLocalPart'] as String?,
      defaultDisplayName: json['defaultDisplayName'] as String?,
      defaultReplyTo: json['defaultReplyTo'] as String?,
      isDefault: json['isDefault'] as bool? ?? false,
    ),
  );

  /// Enums are stored by name so a reordering of the enum cannot silently
  /// change what an old file means.
  T _enumByName<T extends Enum>(List<T> values, String? name, T fallback) {
    if (name == null) return fallback;
    for (final value in values) {
      if (value.name == name) return value;
    }
    return fallback;
  }
}
