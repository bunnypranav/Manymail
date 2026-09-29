// Manymail - Many addresses, one app.
// Copyright (C) 2026 Bunny Pranav
// SPDX-License-Identifier: GPL-3.0-or-later
//
// This file is part of Manymail, distributed under the GNU General Public
// License v3 or later. See the LICENSE file at the root of this repository.

import 'dart:io';
import 'dart:typed_data';

import 'package:enough_mail/enough_mail.dart';
import 'package:uuid/uuid.dart';

import '../core/header_policy.dart';
import '../data/models/message_attachment.dart';
import '../data/models/outgoing_message.dart';

/// A built message, ready for the DATA phase.
class BuiltMessage {
  const BuiltMessage({
    required this.messageId,
    required this.mime,
    required this.envelopeSender,
    required this.recipients,
  });

  /// The `Message-Id` we generated, recorded in the sent log.
  final String messageId;

  /// The fully rendered MIME text.
  final String mime;

  /// What goes in `MAIL FROM` — the free-form address, exactly as typed.
  final String envelopeSender;

  /// Every `RCPT TO`, Bcc included.
  final List<String> recipients;
}

/// Turns an [OutgoingMessage] into MIME.
///
/// The structure depends on what the message actually contains, because a
/// needlessly nested message is a message some clients render badly:
///
/// ```
/// plain only                     text/plain
/// rich                           multipart/alternative
///                                 ├ text/plain
///                                 └ text/html
/// rich + inline images           multipart/related
///                                 ├ multipart/alternative
///                                 └ image/*  (Content-ID, inline)
/// any of the above + files       multipart/mixed
///                                 ├ <the above>
///                                 └ application/*  (attachment)
/// ```
///
/// `enough_mail`'s `MessageBuilder` is used here, and only here, for header
/// encoding and part assembly. Sending is done by `SmtpTransport`.
class MessageComposer {
  const MessageComposer({this.uuid = const Uuid()});

  final Uuid uuid;

  /// Builds the MIME message.
  ///
  /// **Bcc is deliberately never set on the builder.** `MessageBuilder` writes
  /// a `Bcc:` header for any addresses it is given, which would reveal blind
  /// recipients to everyone. Bcc addresses reach the server through
  /// [BuiltMessage.recipients] — the envelope — and nowhere else.
  Future<BuiltMessage> build(
    OutgoingMessage message, {
    List<MessageAttachment> attachments = const [],
  }) async {
    final files = attachments.where((a) => !a.isInline).toList();
    final inlineImages = attachments
        .where((a) => a.isInline && a.isAvailable)
        .toList();

    final hasHtml = message.isHtml && (message.bodyHtml?.isNotEmpty ?? false);

    // An inline image only makes sense when there is HTML to reference it.
    // Without that it would be an invisible part, so it is sent as an ordinary
    // attachment instead of being silently dropped.
    final useRelated = hasHtml && inlineImages.isNotEmpty;
    if (!useRelated) {
      files.addAll(inlineImages);
      inlineImages.clear();
    }

    final builder = MessageBuilder();

    // The outermost type is decided by what the message actually carries, and
    // each wrapper is added only when something needs it.
    if (files.isNotEmpty) {
      builder.setContentType(MediaSubtype.multipartMixed.mediaType);
    } else if (useRelated) {
      builder.setContentType(MediaSubtype.multipartRelated.mediaType);
    } else if (hasHtml) {
      builder.setContentType(MediaSubtype.multipartAlternative.mediaType);
    }
    // With none of those, the message stays a single text/plain part and the
    // body is set directly on it below.

    _applyHeaders(builder, message);

    // Where the body and any inline images belong.
    final bodyHost = files.isNotEmpty && useRelated
        ? builder.addPart(mediaSubtype: MediaSubtype.multipartRelated)
        : builder;

    if (hasHtml) {
      // The root is already the alternative only when nothing wraps it.
      final rootIsAlternative = files.isEmpty && !useRelated;
      final alternative = rootIsAlternative
          ? builder
          : bodyHost.addPart(mediaSubtype: MediaSubtype.multipartAlternative);
      // Least-rich first, so clients pick the best they can render.
      alternative
        ..addTextPlain(message.bodyPlain)
        ..addTextHtml(message.bodyHtml!);
    } else if (files.isEmpty) {
      // Single-part message: the body *is* the message, so it is set directly
      // rather than added as a child part.
      builder
        ..setContentType(
          MediaSubtype.textPlain.mediaType,
          characterSet: CharacterSet.utf8,
        )
        ..text = message.bodyPlain;
    } else {
      bodyHost.addTextPlain(message.bodyPlain);
    }

    if (useRelated) await _addInlineImages(bodyHost, inlineImages);
    if (files.isNotEmpty) await _addFiles(builder, files);

    final mime = builder.buildMimeMessage();
    return BuiltMessage(
      messageId: builder.messageId ?? '',
      mime: mime.renderMessage(),
      envelopeSender: message.fromAddress,
      recipients: message.allRecipients,
    );
  }

  void _applyHeaders(MessageBuilder builder, OutgoingMessage message) {
    builder
      ..from = [
        MailAddress(_nullIfBlank(message.displayName), message.fromAddress),
      ]
      ..subject = message.subject;

    if (message.to.isNotEmpty) {
      builder.to = message.to.map(_address).toList();
    }
    if (message.cc.isNotEmpty) {
      builder.cc = message.cc.map(_address).toList();
    }
    // builder.bcc is intentionally left unset — see build()'s doc comment.

    // Generated from the sending domain so it is plausibly ours. A server may
    // replace it; the sent log records what we chose either way.
    builder.messageId = '<${uuid.v4()}@${message.domainSnapshot}>';

    final replyTo = _nullIfBlank(message.replyTo ?? '');
    if (replyTo != null) {
      builder.setMailAddressHeader('Reply-To', [_address(replyTo)]);
    }

    _applyCustomHeaders(builder, message.customHeaders);
  }

  /// Adds the images the HTML body points at with `cid:`.
  Future<void> _addInlineImages(
    PartBuilder host,
    List<MessageAttachment> images,
  ) async {
    for (final image in images) {
      final bytes = await _read(image);
      if (bytes == null) continue;

      final part = host.addBinary(
        bytes,
        _mediaTypeOf(image.mimeType),
        disposition: ContentDispositionHeader.from(
          ContentDisposition.inline,
          filename: image.fileName,
          size: image.sizeBytes,
        ),
        filename: image.fileName,
      );
      // The angle brackets are required: the body refers to `cid:<value>`
      // without them, but the header carries them.
      part.addHeader('Content-ID', '<${image.contentId}>');
    }
  }

  Future<void> _addFiles(
    MessageBuilder builder,
    List<MessageAttachment> files,
  ) async {
    for (final attachment in files) {
      final bytes = await _read(attachment);
      // A file that has gone missing is skipped rather than failing the whole
      // send; the sent log still records that it was meant to be there.
      if (bytes == null) continue;

      builder.addBinary(
        bytes,
        _mediaTypeOf(attachment.mimeType),
        filename: attachment.fileName,
      );
    }
  }

  Future<Uint8List?> _read(MessageAttachment attachment) async {
    final path = attachment.storedPath;
    if (path == null) return null;
    final file = File(path);
    if (!file.existsSync()) return null;
    try {
      return await file.readAsBytes();
    } catch (_) {
      return null;
    }
  }

  MediaType _mediaTypeOf(String mimeType) =>
      MediaType.fromText(mimeType);

  /// Adds user-supplied headers, skipping any the mailer controls.
  ///
  /// The composer already blocks these, so anything reaching here is either an
  /// imported message or a bug; either way it is dropped rather than allowed
  /// to produce a duplicate or conflicting header.
  void _applyCustomHeaders(
    MessageBuilder builder,
    Map<String, String> headers,
  ) {
    for (final entry in headers.entries) {
      if (checkHeaderName(entry.key) == HeaderVerdict.reserved) continue;
      if (!isValidHeaderValue(entry.value)) continue;
      builder.addHeader(entry.key.trim(), entry.value.trim());
    }
  }

  MailAddress _address(String value) => MailAddress(null, value.trim());

  String? _nullIfBlank(String value) =>
      value.trim().isEmpty ? null : value.trim();
}
