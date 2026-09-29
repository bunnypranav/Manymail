// Manymail - Many addresses, one app.
// Copyright (C) 2026 Bunny Pranav
// SPDX-License-Identifier: GPL-3.0-or-later
//
// This file is part of Manymail, distributed under the GNU General Public
// License v3 or later. See the LICENSE file at the root of this repository.

import '../core/transcript.dart';
import 'smtp_config.dart';
import 'smtp_failure.dart';
import 'smtp_session.dart';

/// The result of testing a domain's SMTP settings.
class ConnectionTestReport {
  ConnectionTestReport({
    required this.success,
    required this.steps,
    required this.transcript,
    required this.capabilities,
    required this.authMechanisms,
    this.banner,
    this.failure,
    this.cleartextCredentialWarning = false,
  });

  final bool success;

  /// One entry per stage attempted, in order.
  final List<SmtpStepResult> steps;

  /// Redacted protocol dialogue.
  final String transcript;

  /// EHLO capabilities as advertised, de-duplicated.
  final List<String> capabilities;

  final Set<String> authMechanisms;

  /// The server's opening banner line.
  final String? banner;

  final SmtpFailure? failure;

  /// True when authentication would have put the password on an unencrypted
  /// connection.
  final bool cleartextCredentialWarning;
}

/// Opens a full SMTP session — greeting, EHLO, TLS, authentication — and
/// reports each step, without sending a message.
///
/// This runs the same code path [SmtpSession.open] uses for a real send, so a
/// passing test means the handshake a send performs actually works.
class ConnectionTester {
  const ConnectionTester();

  /// [onStep] is invoked as each stage completes, so the UI can fill in
  /// progressively rather than waiting for the whole handshake.
  Future<ConnectionTestReport> test(
    SmtpConfig config, {
    String? password,
    SmtpStepCallback? onStep,
  }) async {
    final steps = <SmtpStepResult>[];
    final transcript = SmtpTranscript();
    SmtpSession? session;

    void record(SmtpStepResult step) {
      steps.add(step);
      onStep?.call(step);
    }

    try {
      session = await SmtpSession.open(
        config,
        password: password,
        transcript: transcript,
        onStep: record,
      );

      final cleartext = session.willSendCredentialsInCleartext;
      final capabilities = session.capabilities;
      final mechanisms = session.authMechanisms;

      // Say goodbye properly — a server that refuses QUIT is worth seeing.
      final watch = Stopwatch()..start();
      await session.close();
      record(
        SmtpStepResult(
          stage: SmtpStage.quit,
          ok: true,
          elapsed: watch.elapsed,
          detail: 'Disconnected cleanly. No message was sent.',
        ),
      );

      return ConnectionTestReport(
        success: true,
        steps: steps,
        transcript: transcript.render(),
        capabilities: capabilities,
        authMechanisms: mechanisms,
        banner: _bannerOf(transcript),
        cleartextCredentialWarning: cleartext,
      );
    } catch (error) {
      final failure = classifyError(
        error,
        stage: steps.isEmpty ? SmtpStage.connect : steps.last.stage,
        transcript: transcript.render(),
      );
      await session?.close(graceful: false);
      return ConnectionTestReport(
        success: false,
        steps: steps,
        transcript: transcript.render(),
        capabilities: session?.capabilities ?? const <String>[],
        authMechanisms: session?.authMechanisms ?? const <String>{},
        banner: _bannerOf(transcript),
        failure: failure,
      );
    }
  }

  String? _bannerOf(SmtpTranscript transcript) {
    for (final entry in transcript.entries) {
      if (entry.direction == TranscriptDirection.server) return entry.text;
    }
    return null;
  }
}
