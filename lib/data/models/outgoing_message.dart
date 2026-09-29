// Manymail - Many addresses, one app.
// Copyright (C) 2026 Bunny Pranav
// SPDX-License-Identifier: GPL-3.0-or-later
//
// This file is part of Manymail, distributed under the GNU General Public
// License v3 or later. See the LICENSE file at the root of this repository.

import '../../core/validation/rfc5322.dart';
import 'enums.dart';
import 'mail_domain.dart';

// A message is always handled together with its status, so callers get both.
export 'enums.dart';

/// A message being written, queued, sent or failed.
///
/// The sender identity is stored as its parts — [localPart], [displayName] and
/// the domain — rather than as one assembled string, because the parts are what
/// the composer edits and what the send path puts on the wire.
///
/// The `*Snapshot` fields record the domain's details at the time of writing,
/// so a sent message stays readable after its domain is deleted or edited.
class OutgoingMessage {
  const OutgoingMessage({
    required this.status,
    required this.localPart,
    required this.displayName,
    required this.domainSnapshot,
    required this.createdAt,
    required this.updatedAt,
    this.id,
    this.domainId,
    this.hostSnapshot = '',
    this.domainLabelSnapshot = '',
    this.replyTo,
    this.to = const [],
    this.cc = const [],
    this.bcc = const [],
    this.subject = '',
    this.bodyHtml,
    this.bodyPlain = '',
    this.bodyDeltaJson,
    this.isHtml = false,
    this.customHeaders = const {},
    this.sentAt,
    this.lastError,
    this.lastResponseLine,
    this.retryCount = 0,
    this.nextRetryAt,
    this.messageId,
    this.transcript,
  });

  /// An empty message for a fresh compose, seeded from [domain]'s defaults.
  factory OutgoingMessage.blank({MailDomain? domain, bool isHtml = false}) {
    final now = DateTime.now();
    return OutgoingMessage(
      status: MessageStatus.draft,
      domainId: domain?.id,
      domainSnapshot: domain?.domain ?? '',
      hostSnapshot: domain?.host ?? '',
      domainLabelSnapshot: domain?.label ?? '',
      localPart: domain?.defaultLocalPart ?? '',
      displayName: domain?.defaultDisplayName ?? '',
      replyTo: domain?.defaultReplyTo,
      isHtml: isHtml,
      createdAt: now,
      updatedAt: now,
    );
  }

  final int? id;
  final MessageStatus status;

  /// Null once the referenced domain has been deleted.
  final int? domainId;

  final String domainSnapshot;
  final String hostSnapshot;
  final String domainLabelSnapshot;

  /// The free-form sender identity, exactly as typed.
  final String localPart;
  final String displayName;

  final String? replyTo;

  final List<String> to;
  final List<String> cc;

  /// Blind recipients. These go into `RCPT TO` and must never be written into
  /// the message headers.
  final List<String> bcc;

  final String subject;

  final String? bodyHtml;
  final String bodyPlain;

  /// Quill document, so a draft reopens in the rich editor without loss.
  final String? bodyDeltaJson;

  final bool isHtml;
  final Map<String, String> customHeaders;

  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? sentAt;

  final String? lastError;
  final String? lastResponseLine;
  final int retryCount;
  final DateTime? nextRetryAt;

  final String? messageId;
  final String? transcript;

  /// The bare address used for both the `From` header and `MAIL FROM`.
  String get fromAddress => '$localPart@$domainSnapshot';

  /// The assembled `From` header, e.g. `Bunny Hopper <hello@example.com>`.
  String get fromHeader => formatMailbox(
    displayName: displayName,
    localPart: localPart,
    domain: domainSnapshot,
  );

  /// Everything that must receive an `RCPT TO`, Bcc included.
  List<String> get allRecipients => [...to, ...cc, ...bcc];

  bool get hasRecipients => allRecipients.isNotEmpty;

  /// A one-line recipient summary for list screens.
  String get recipientSummary {
    final all = allRecipients;
    if (all.isEmpty) return 'No recipients';
    if (all.length == 1) return all.first;
    return '${all.first} +${all.length - 1}';
  }

  /// Whether this is worth keeping as a draft rather than discarding.
  bool get hasContent =>
      subject.trim().isNotEmpty ||
      bodyPlain.trim().isNotEmpty ||
      (bodyHtml?.trim().isNotEmpty ?? false) ||
      allRecipients.isNotEmpty;

  OutgoingMessage copyWith({
    int? id,
    MessageStatus? status,
    Object? domainId = _unset,
    String? domainSnapshot,
    String? hostSnapshot,
    String? domainLabelSnapshot,
    String? localPart,
    String? displayName,
    Object? replyTo = _unset,
    List<String>? to,
    List<String>? cc,
    List<String>? bcc,
    String? subject,
    Object? bodyHtml = _unset,
    String? bodyPlain,
    Object? bodyDeltaJson = _unset,
    bool? isHtml,
    Map<String, String>? customHeaders,
    DateTime? createdAt,
    DateTime? updatedAt,
    Object? sentAt = _unset,
    Object? lastError = _unset,
    Object? lastResponseLine = _unset,
    int? retryCount,
    Object? nextRetryAt = _unset,
    Object? messageId = _unset,
    Object? transcript = _unset,
  }) => OutgoingMessage(
    id: id ?? this.id,
    status: status ?? this.status,
    domainId: domainId == _unset ? this.domainId : domainId as int?,
    domainSnapshot: domainSnapshot ?? this.domainSnapshot,
    hostSnapshot: hostSnapshot ?? this.hostSnapshot,
    domainLabelSnapshot: domainLabelSnapshot ?? this.domainLabelSnapshot,
    localPart: localPart ?? this.localPart,
    displayName: displayName ?? this.displayName,
    replyTo: replyTo == _unset ? this.replyTo : replyTo as String?,
    to: to ?? this.to,
    cc: cc ?? this.cc,
    bcc: bcc ?? this.bcc,
    subject: subject ?? this.subject,
    bodyHtml: bodyHtml == _unset ? this.bodyHtml : bodyHtml as String?,
    bodyPlain: bodyPlain ?? this.bodyPlain,
    bodyDeltaJson: bodyDeltaJson == _unset
        ? this.bodyDeltaJson
        : bodyDeltaJson as String?,
    isHtml: isHtml ?? this.isHtml,
    customHeaders: customHeaders ?? this.customHeaders,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    sentAt: sentAt == _unset ? this.sentAt : sentAt as DateTime?,
    lastError: lastError == _unset ? this.lastError : lastError as String?,
    lastResponseLine: lastResponseLine == _unset
        ? this.lastResponseLine
        : lastResponseLine as String?,
    retryCount: retryCount ?? this.retryCount,
    nextRetryAt: nextRetryAt == _unset
        ? this.nextRetryAt
        : nextRetryAt as DateTime?,
    messageId: messageId == _unset ? this.messageId : messageId as String?,
    transcript: transcript == _unset ? this.transcript : transcript as String?,
  );

  /// Re-points this message at [domain], refreshing the snapshot fields.
  ///
  /// The identity fields are left alone: switching domain keeps whatever local
  /// part and display name you had typed.
  OutgoingMessage withDomain(MailDomain domain) => copyWith(
    domainId: domain.id,
    domainSnapshot: domain.domain,
    hostSnapshot: domain.host,
    domainLabelSnapshot: domain.label,
  );
}

const Object _unset = Object();
