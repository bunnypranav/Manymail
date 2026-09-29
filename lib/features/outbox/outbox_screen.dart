// Manymail - Many addresses, one app.
// Copyright (C) 2026 Bunny Pranav
// SPDX-License-Identifier: GPL-3.0-or-later
//
// This file is part of Manymail, distributed under the GNU General Public
// License v3 or later. See the LICENSE file at the root of this repository.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../background/retry_policy.dart';
import '../../data/models/outgoing_message.dart';
import '../../providers.dart';
import '../../routing/app_router.dart';
import '../common/protocol_widgets.dart';

/// Messages waiting to go out, and messages the server refused.
///
/// A send that fails for a retryable reason — no network, a timeout, a 4xx —
/// lands here as `queued` rather than being lost. A 5xx refusal lands here as
/// `failed` and is not retried, because retrying would never help.
class OutboxScreen extends ConsumerWidget {
  const OutboxScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final outbox = ref.watch(outboxProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Outbox')),
      body: outbox.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('$error')),
        data: (items) => items.isEmpty
            ? const _Empty()
            : ListView.separated(
                itemCount: items.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (context, index) =>
                    _OutboxTile(message: items[index]),
              ),
      ),
    );
  }
}

class _OutboxTile extends ConsumerStatefulWidget {
  const _OutboxTile({required this.message});

  final OutgoingMessage message;

  @override
  ConsumerState<_OutboxTile> createState() => _OutboxTileState();
}

class _OutboxTileState extends ConsumerState<_OutboxTile> {
  bool _retrying = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final message = widget.message;
    final failed = message.status == MessageStatus.failed;

    return ExpansionTile(
      leading: Icon(
        failed ? Icons.error_outline : Icons.schedule,
        color: failed ? theme.colorScheme.error : null,
      ),
      title: Text(
        message.subject.isEmpty ? '(no subject)' : message.subject,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            message.fromHeader,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.primary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            '${message.status.label} · to ${message.recipientSummary}'
            '${message.retryCount > 0 ? ' · ${message.retryCount} attempt'
                '${message.retryCount == 1 ? '' : 's'}' : ''}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (_nextAttemptLabel(message) case final label?)
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
        ],
      ),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (message.lastResponseLine != null)
                ResultBanner(
                  icon: Icons.dns_outlined,
                  tone: failed ? ResultTone.error : ResultTone.warning,
                  title: 'The server said',
                  body: message.lastResponseLine!,
                  monospaceBody: true,
                )
              else if (message.lastError != null)
                ResultBanner(
                  icon: Icons.wifi_off,
                  tone: ResultTone.warning,
                  title: 'Last attempt failed',
                  body: message.lastError!,
                ),

              if (message.transcript != null)
                TranscriptExpander(transcript: message.transcript!),

              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => context.go(Routes.editDraft(message.id!)),
                      icon: const Icon(Icons.edit_outlined),
                      label: const Text('Edit'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: _retrying ? null : _retry,
                      icon: _retrying
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.refresh),
                      label: Text(_retrying ? 'Sending…' : 'Retry now'),
                    ),
                  ),
                ],
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: _cancel,
                  icon: const Icon(Icons.close),
                  label: const Text('Cancel and move to drafts'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// When the background worker will try this one again, in words.
  String? _nextAttemptLabel(OutgoingMessage message) {
    if (message.status != MessageStatus.queued) return null;
    final at = message.nextRetryAt;
    if (at == null) {
      return message.retryCount >= RetryPolicy.maxAttempts
          ? 'Automatic retrying has stopped — retry manually'
          : 'Will be sent as soon as there is a connection';
    }
    final wait = at.difference(DateTime.now());
    if (wait.isNegative) return 'Due now';
    return 'Next attempt in ${RetryPolicy.describeDelay(wait)}';
  }

  /// Sends through the same coordinator the composer uses, so a retry behaves
  /// identically to an original send.
  Future<void> _retry() async {
    setState(() => _retrying = true);
    final result = await ref
        .read(sendCoordinatorProvider)
        .send(widget.message);
    if (!mounted) return;
    setState(() => _retrying = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          result.outcome.success
              ? 'Sent'
              : result.outcome.failure?.summary ?? 'Still failing',
        ),
      ),
    );
  }

  /// Puts the message back in drafts so it can be fixed rather than retried
  /// blindly.
  Future<void> _cancel() async {
    await ref.read(messageRepositoryProvider).save(
      widget.message.copyWith(
        status: MessageStatus.draft,
        updatedAt: DateTime.now(),
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty();

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.outbox_outlined, size: 56),
          const SizedBox(height: 16),
          Text(
            'Outbox is empty',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          const Text(
            'Messages that could not be sent wait here instead of being lost.',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );
}
