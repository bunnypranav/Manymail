// Manymail - Many addresses, one app.
// Copyright (C) 2026 Bunny Pranav
// SPDX-License-Identifier: GPL-3.0-or-later
//
// This file is part of Manymail, distributed under the GNU General Public
// License v3 or later. See the LICENSE file at the root of this repository.

/// Application-wide preferences.
///
/// Stored as a single row; defaults here match the column defaults in
/// `tables.dart`.
class AppSettings {
  const AppSettings({
    this.defaultDomainId,
    this.defaultPresetId,
    this.biometricLockEnabled = false,
    this.attachmentWarnBytes = defaultAttachmentWarnBytes,
    this.sentLogRetentionDays = 0,
    this.composeHtmlByDefault = true,
    this.keepSentAttachments = false,
    this.defaultSignature,
  });

  /// 20 MB — below the limit most providers enforce.
  static const int defaultAttachmentWarnBytes = 20 * 1024 * 1024;

  /// Preselected in the composer. Null falls back to the domain marked
  /// default, then to the first one configured.
  final int? defaultDomainId;
  final int? defaultPresetId;

  /// Require biometrics or the device credential to open the app.
  final bool biometricLockEnabled;

  /// Warn once attachments total more than this.
  final int attachmentWarnBytes;

  /// Days of sent history to keep. 0 keeps everything.
  final int sentLogRetentionDays;

  /// Whether a new message starts in rich or plain mode.
  final bool composeHtmlByDefault;

  /// Keep attachment files after sending, not just their names and sizes.
  final bool keepSentAttachments;

  /// Appended to a new message, and freely editable there. An identity preset
  /// can override it.
  final String? defaultSignature;

  bool get keepSentForever => sentLogRetentionDays <= 0;

  AppSettings copyWith({
    Object? defaultDomainId = _unset,
    Object? defaultPresetId = _unset,
    bool? biometricLockEnabled,
    int? attachmentWarnBytes,
    int? sentLogRetentionDays,
    bool? composeHtmlByDefault,
    bool? keepSentAttachments,
    Object? defaultSignature = _unset,
  }) => AppSettings(
    defaultDomainId: defaultDomainId == _unset
        ? this.defaultDomainId
        : defaultDomainId as int?,
    defaultPresetId: defaultPresetId == _unset
        ? this.defaultPresetId
        : defaultPresetId as int?,
    biometricLockEnabled: biometricLockEnabled ?? this.biometricLockEnabled,
    attachmentWarnBytes: attachmentWarnBytes ?? this.attachmentWarnBytes,
    sentLogRetentionDays: sentLogRetentionDays ?? this.sentLogRetentionDays,
    composeHtmlByDefault: composeHtmlByDefault ?? this.composeHtmlByDefault,
    keepSentAttachments: keepSentAttachments ?? this.keepSentAttachments,
    defaultSignature: defaultSignature == _unset
        ? this.defaultSignature
        : defaultSignature as String?,
  );
}

const Object _unset = Object();
