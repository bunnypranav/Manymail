// Manymail - Many addresses, one app.
// Copyright (C) 2026 Bunny Pranav
// SPDX-License-Identifier: GPL-3.0-or-later
//
// This file is part of Manymail, distributed under the GNU General Public
// License v3 or later. See the LICENSE file at the root of this repository.

import 'dart:math';

import '../../background/outbox_scheduler.dart';
import '../../smtp/send_service.dart';
import '../models/outgoing_message.dart';
import '../outbox_transition.dart';
import 'attachment_repository.dart';
import 'domain_repository.dart';
import 'message_repository.dart';

/// Ties together the pieces a send needs: the message record, the domain, the
/// stored credential, and the status transitions afterwards.
///
/// Both the composer and the outbox go through here, so a message sent from
/// either place follows exactly the same path and ends in the same state.
class SendCoordinator {
  const SendCoordinator({
    required this.messages,
    required this.domains,
    required this.sender,
    required this.attachments,
    this.scheduler = const OutboxScheduler(),
  });

  final MessageRepository messages;
  final DomainRepository domains;
  final SendService sender;
  final AttachmentRepository attachments;

  /// Books the background wake-up for anything left queued. Injectable so
  /// tests do not touch the platform.
  final OutboxScheduler scheduler;

  /// Attempts one send and records the result.
  ///
  /// Returns the outcome alongside the stored message, whose status is now
  /// `sent`, `queued` (retryable failure) or `failed` (refused).
  Future<({SendOutcome outcome, OutgoingMessage message})> send(
    OutgoingMessage message,
  ) async {
    final domain = await domains.getById(message.domainId ?? -1);

    if (domain == null) {
      final failed = message.copyWith(
        status: MessageStatus.failed,
        updatedAt: DateTime.now(),
        lastError:
            'The domain this message was written for no longer exists. '
            'Open it and choose another domain.',
      );
      final id = await messages.save(failed);
      return (
        outcome: const SendOutcome(success: false, transcript: ''),
        message: failed.copyWith(id: id),
      );
    }

    // Mark in flight first, so an interrupted send leaves a recoverable record.
    final id = await messages.save(
      message.copyWith(status: MessageStatus.sending),
    );
    final inFlight = message.copyWith(id: id, status: MessageStatus.sending);

    final password = await domains.passwordFor(domain);
    final outcome = await sender.send(
      message: inFlight,
      domain: domain,
      password: password,
      attachments: await attachments.forMessage(id),
    );

    final settled = OutboxTransition.apply(
      inFlight,
      outcome,
      now: DateTime.now(),
      jitter: Random(),
    );

    await messages.save(settled);

    // Keep the background schedule in step with what is actually waiting.
    // Scheduling is best-effort: on a platform without WorkManager, or when
    // the OS refuses, the message still sits in the outbox for a manual retry.
    try {
      await scheduler.scheduleNextFrom(messages);
    } catch (_) {
      // Ignored deliberately — see above.
    }

    return (outcome: outcome, message: settled);
  }
}
