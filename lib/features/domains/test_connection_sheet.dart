// Manymail - Many addresses, one app.
// Copyright (C) 2026 Bunny Pranav
// SPDX-License-Identifier: GPL-3.0-or-later
//
// This file is part of Manymail, distributed under the GNU General Public
// License v3 or later. See the LICENSE file at the root of this repository.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers.dart';
import '../../smtp/connection_tester.dart';
import '../../smtp/smtp_config.dart';
import '../../smtp/smtp_session.dart';
import '../common/protocol_widgets.dart';

/// Opens the connection test as a modal sheet and runs it immediately.
Future<void> showTestConnectionSheet({
  required BuildContext context,
  required WidgetRef ref,
  required SmtpConfig config,
  String? password,
}) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  showDragHandle: true,
  builder: (context) => DraggableScrollableSheet(
    expand: false,
    initialChildSize: 0.75,
    maxChildSize: 0.95,
    builder: (context, scrollController) => _TestConnectionView(
      config: config,
      password: password,
      scrollController: scrollController,
    ),
  ),
);

/// Runs the SMTP handshake and reports every step as it happens.
///
/// No message is sent. The point is to prove the connection, the TLS mode and
/// the credentials independently, and to show exactly what the server said at
/// each stage.
class _TestConnectionView extends ConsumerStatefulWidget {
  const _TestConnectionView({
    required this.config,
    required this.password,
    required this.scrollController,
  });

  final SmtpConfig config;
  final String? password;
  final ScrollController scrollController;

  @override
  ConsumerState<_TestConnectionView> createState() =>
      _TestConnectionViewState();
}

class _TestConnectionViewState extends ConsumerState<_TestConnectionView> {
  final List<SmtpStepResult> _steps = [];
  ConnectionTestReport? _report;
  bool _running = true;

  @override
  void initState() {
    super.initState();
    _run();
  }

  Future<void> _run() async {
    final report = await ref
        .read(connectionTesterProvider)
        .test(
          widget.config,
          password: widget.password,
          onStep: (step) {
            if (mounted) setState(() => _steps.add(step));
          },
        );
    if (mounted) {
      setState(() {
        _report = report;
        _running = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final report = _report;

    return ListView(
      controller: widget.scrollController,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Test connection',
                style: theme.textTheme.titleLarge,
              ),
            ),
            if (_running)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          '${widget.config.host}:${widget.config.port} · '
          '${widget.config.security.label}',
          style: theme.textTheme.bodySmall,
        ),
        const SizedBox(height: 16),

        if (report != null) _Summary(report: report),

        for (final step in _steps) _StepTile(step: step),

        if (report != null && report.cleartextCredentialWarning) ...[
          const SizedBox(height: 12),
          const ResultBanner(
            icon: Icons.lock_open,
            tone: ResultTone.warning,
            title: 'Password sent unencrypted',
            body: 'This server accepted credentials over a connection with no '
                'TLS. Anyone on the network path could read them.',
          ),
        ],

        if (report?.failure?.hint != null) ...[
          const SizedBox(height: 12),
          ResultBanner(
            icon: Icons.info_outline,
            tone: ResultTone.info,
            title: 'What this usually means',
            body: report!.failure!.hint!,
          ),
        ],

        if (report != null && report.capabilities.isNotEmpty) ...[
          const SizedBox(height: 8),
          ExpansionTile(
            tilePadding: EdgeInsets.zero,
            title: const Text('Server capabilities'),
            subtitle: Text('${report.capabilities.length} advertised'),
            children: [
              for (final capability in report.capabilities)
                ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    capability,
                    style: const TextStyle(fontFamily: 'monospace'),
                  ),
                ),
            ],
          ),
        ],

        if (report != null) ...[
          ExpansionTile(
            tilePadding: EdgeInsets.zero,
            title: const Text('Raw SMTP transcript'),
            subtitle: const Text('Credentials are redacted'),
            children: [TranscriptView(text: report.transcript)],
          ),
        ],
      ],
    );
  }
}

class _Summary extends StatelessWidget {
  const _Summary({required this.report});

  final ConnectionTestReport report;

  @override
  Widget build(BuildContext context) {
    if (report.success) {
      return const ResultBanner(
        icon: Icons.check_circle_outline,
        tone: ResultTone.success,
        title: 'Connection succeeded',
        body: 'The server accepted the connection and these credentials. '
            'No message was sent.',
      );
    }
    final failure = report.failure;
    return ResultBanner(
      icon: Icons.error_outline,
      tone: ResultTone.error,
      title: '${failure?.stage.label ?? 'Connection'} failed',
      body: failure?.serverResponse?.isNotEmpty ?? false
          ? failure!.serverResponse!
          : failure?.summary ?? 'Unknown error.',
      monospaceBody: failure?.serverResponse?.isNotEmpty ?? false,
    );
  }
}

class _StepTile extends StatelessWidget {
  const _StepTile({required this.step});

  final SmtpStepResult step;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            step.ok ? Icons.check_circle : Icons.cancel,
            size: 20,
            color: step.ok ? scheme.primary : scheme.error,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        step.stage.label,
                        style: theme.textTheme.titleSmall,
                      ),
                    ),
                    Text(
                      '${step.elapsed.inMilliseconds} ms',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
                if (step.serverResponse != null &&
                    step.serverResponse!.isNotEmpty)
                  Text(
                    step.serverResponse!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontFamily: 'monospace',
                    ),
                  ),
                if (step.detail != null)
                  Text(step.detail!, style: theme.textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
