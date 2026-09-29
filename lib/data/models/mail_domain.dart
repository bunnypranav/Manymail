// Manymail - Many addresses, one app.
// Copyright (C) 2026 Bunny Pranav
// SPDX-License-Identifier: GPL-3.0-or-later
//
// This file is part of Manymail, distributed under the GNU General Public
// License v3 or later. See the LICENSE file at the root of this repository.

import 'enums.dart';

/// A configured domain and the SMTP server that sends for it.
///
/// The saved credentials authenticate the *connection*. They place no
/// constraint on the identity a message is sent from — the local part and
/// display name are chosen per message in the composer. That separation is the
/// whole point of the app.
///
/// Note the absence of a password field. The password lives in
/// `flutter_secure_storage` under [credentialKeyId]; it is never held in the
/// database, and this model carries only the opaque key id.
class MailDomain {
  const MailDomain({
    required this.id,
    required this.label,
    required this.domain,
    required this.host,
    required this.port,
    required this.security,
    required this.authMode,
    required this.username,
    required this.credentialKeyId,
    required this.allowInsecureCertificate,
    required this.timeoutSeconds,
    required this.isDefault,
    required this.sortOrder,
    required this.createdAt,
    required this.updatedAt,
    this.defaultLocalPart,
    this.defaultDisplayName,
    this.defaultReplyTo,
  });

  final int id;

  /// Friendly name shown in the composer's domain dropdown, e.g. "example
  /// main".
  final String label;

  /// The domain used to build the From address, e.g. `example.com`.
  final String domain;

  final String host;
  final int port;
  final SmtpSecurity security;
  final SmtpAuthMode authMode;
  final String username;

  /// Opaque handle into secure storage. Never a password itself.
  final String credentialKeyId;

  /// Accept certificates that fail validation. Off by default; the editor warns
  /// when it is turned on.
  final bool allowInsecureCertificate;

  final int timeoutSeconds;

  /// Prefilled into the composer when this domain is selected, and freely
  /// editable there.
  final String? defaultLocalPart;
  final String? defaultDisplayName;
  final String? defaultReplyTo;

  final bool isDefault;
  final int sortOrder;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// Whether a password is expected for this configuration.
  bool get requiresPassword => authMode != SmtpAuthMode.none;

  /// True when credentials would cross an unencrypted link in a recoverable
  /// form. The domain editor and the send path both surface this.
  bool get sendsCredentialsInCleartext =>
      !security.isEncrypted &&
      requiresPassword &&
      (authMode.exposesPasswordInCleartext || authMode == SmtpAuthMode.auto);

  MailDomain copyWith({
    int? id,
    String? label,
    String? domain,
    String? host,
    int? port,
    SmtpSecurity? security,
    SmtpAuthMode? authMode,
    String? username,
    String? credentialKeyId,
    bool? allowInsecureCertificate,
    int? timeoutSeconds,
    Object? defaultLocalPart = _unset,
    Object? defaultDisplayName = _unset,
    Object? defaultReplyTo = _unset,
    bool? isDefault,
    int? sortOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => MailDomain(
    id: id ?? this.id,
    label: label ?? this.label,
    domain: domain ?? this.domain,
    host: host ?? this.host,
    port: port ?? this.port,
    security: security ?? this.security,
    authMode: authMode ?? this.authMode,
    username: username ?? this.username,
    credentialKeyId: credentialKeyId ?? this.credentialKeyId,
    allowInsecureCertificate:
        allowInsecureCertificate ?? this.allowInsecureCertificate,
    timeoutSeconds: timeoutSeconds ?? this.timeoutSeconds,
    defaultLocalPart: defaultLocalPart == _unset
        ? this.defaultLocalPart
        : defaultLocalPart as String?,
    defaultDisplayName: defaultDisplayName == _unset
        ? this.defaultDisplayName
        : defaultDisplayName as String?,
    defaultReplyTo: defaultReplyTo == _unset
        ? this.defaultReplyTo
        : defaultReplyTo as String?,
    isDefault: isDefault ?? this.isDefault,
    sortOrder: sortOrder ?? this.sortOrder,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
}

/// Sentinel allowing [MailDomain.copyWith] to distinguish "leave unchanged"
/// from "set to null".
const Object _unset = Object();

/// A saved `{local part, display name}` pairing for a domain.
///
/// Presets are a convenience over the free-text fields, never a constraint on
/// them: choosing one fills the composer's fields, which remain fully editable.
class IdentityPreset {
  const IdentityPreset({
    required this.id,
    required this.domainId,
    required this.name,
    required this.localPart,
    required this.displayName,
    required this.sortOrder,
    this.replyTo,
    this.signature,
  });

  final int id;
  final int domainId;

  /// What the preset is called in the quick-pick, e.g. "Billing".
  final String name;

  final String localPart;
  final String displayName;
  final String? replyTo;

  /// Overrides the global default signature when set.
  final String? signature;

  final int sortOrder;

  IdentityPreset copyWith({
    int? id,
    int? domainId,
    String? name,
    String? localPart,
    String? displayName,
    Object? replyTo = _unset,
    Object? signature = _unset,
    int? sortOrder,
  }) => IdentityPreset(
    id: id ?? this.id,
    domainId: domainId ?? this.domainId,
    name: name ?? this.name,
    localPart: localPart ?? this.localPart,
    displayName: displayName ?? this.displayName,
    replyTo: replyTo == _unset ? this.replyTo : replyTo as String?,
    signature: signature == _unset ? this.signature : signature as String?,
    sortOrder: sortOrder ?? this.sortOrder,
  );
}
