// Manymail - Many addresses, one app.
// Copyright (C) 2026 Bunny Pranav
// SPDX-License-Identifier: GPL-3.0-or-later
//
// This file is part of Manymail, distributed under the GNU General Public
// License v3 or later. See the LICENSE file at the root of this repository.

import 'dart:async';

import '../core/transcript.dart';
import '../data/models/enums.dart';
import 'smtp_config.dart';
import 'smtp_failure.dart';
import 'smtp_transport.dart';

/// The outcome of one step of the SMTP conversation.
///
/// The "Test connection" screen renders these in order, each with whatever the
/// server actually said.
class SmtpStepResult {
  SmtpStepResult({
    required this.stage,
    required this.ok,
    required this.elapsed,
    this.detail,
    this.code,
    this.serverResponse,
    this.failure,
  });

  final SmtpStage stage;
  final bool ok;
  final Duration elapsed;

  /// Extra context worth showing, such as the banner or capability list.
  final String? detail;

  final int? code;
  final String? serverResponse;
  final SmtpFailure? failure;
}

/// Called as each step completes, so a UI can fill in progressively.
typedef SmtpStepCallback = void Function(SmtpStepResult step);

/// An open SMTP session: connected, secured and authenticated.
///
/// Used by both the connection tester and the send path, so a passing test
/// exercises exactly the handshake a real send performs.
class SmtpSession {
  SmtpSession._(this.transport, this.transcript, this.config);

  final SmtpTransport transport;
  final SmtpTranscript transcript;
  final SmtpConfig config;

  List<String> _capabilities = const [];
  Set<String> _authMechanisms = const {};

  /// Capabilities advertised by the most recent EHLO.
  List<String> get capabilities => List.unmodifiable(_capabilities);

  /// SASL mechanisms the server offers.
  Set<String> get authMechanisms => Set.unmodifiable(_authMechanisms);

  /// The mechanism actually used, once authentication has run.
  String? usedMechanism;

  /// Opens a session, running each stage in turn and reporting as it goes.
  ///
  /// Throws [SmtpFailure] on the first stage that fails, after closing the
  /// socket.
  static Future<SmtpSession> open(
    SmtpConfig config, {
    String? password,
    SmtpStepCallback? onStep,
    SmtpTranscript? transcript,
  }) async {
    final log = transcript ?? SmtpTranscript();
    log.registerSecret(password);

    final transport = SmtpTransport(
      transcript: log,
      timeout: config.timeout,
      allowInsecureCertificate: config.allowInsecureCertificate,
    );
    final session = SmtpSession._(transport, log, config);

    var stage = SmtpStage.connect;
    final watch = Stopwatch()..start();

    try {
      // 1. Connect and read the greeting.
      final greeting = await transport.connect(
        config.host,
        config.port,
        secure: config.isImplicitTls,
      );
      onStep?.call(
        SmtpStepResult(
          stage: SmtpStage.connect,
          ok: true,
          elapsed: watch.elapsed,
          code: greeting.code,
          serverResponse: greeting.text,
          detail: config.isImplicitTls
              ? 'Connected over TLS to ${config.host}:${config.port}'
              : 'Connected to ${config.host}:${config.port}',
        ),
      );

      // 2. EHLO.
      stage = SmtpStage.ehlo;
      watch.reset();
      await session._sayHello(stage);
      onStep?.call(
        SmtpStepResult(
          stage: stage,
          ok: true,
          elapsed: watch.elapsed,
          code: 250,
          detail: session._describeCapabilities(),
        ),
      );

      // 3. STARTTLS, then EHLO again — capabilities before TLS are not
      //    binding, and AUTH usually only appears afterwards.
      if (config.needsStartTls) {
        stage = SmtpStage.startTls;
        watch.reset();
        final reply = await transport.startTls(config.host);
        if (!reply.isPositive) {
          throw SmtpFailure.fromReply(
            reply,
            stage: stage,
            transcript: log.render(),
          );
        }
        await session._sayHello(SmtpStage.ehlo);
        onStep?.call(
          SmtpStepResult(
            stage: stage,
            ok: true,
            elapsed: watch.elapsed,
            code: reply.code,
            serverResponse: reply.text,
            detail: 'Connection upgraded to TLS. '
                '${session._describeCapabilities()}',
          ),
        );
      }

      // 4. Authenticate, unless configured not to.
      if (config.needsAuthentication) {
        stage = SmtpStage.authenticate;
        watch.reset();
        final reply = await session._authenticate(password ?? '');
        if (!reply.isPositive) {
          throw SmtpFailure.fromReply(
            reply,
            stage: stage,
            transcript: log.render(),
          );
        }
        onStep?.call(
          SmtpStepResult(
            stage: stage,
            ok: true,
            elapsed: watch.elapsed,
            code: reply.code,
            serverResponse: reply.text,
            detail: 'Authenticated as ${config.username} '
                'using ${session.usedMechanism}',
          ),
        );
      }

      return session;
    } catch (error) {
      final failure = classifyError(
        error,
        stage: stage,
        transcript: log.render(),
      );
      onStep?.call(
        SmtpStepResult(
          stage: stage,
          ok: false,
          elapsed: watch.elapsed,
          code: failure.code,
          serverResponse: failure.serverResponse,
          failure: failure,
        ),
      );
      await transport.close();
      throw failure;
    }
  }

  /// EHLO, falling back to HELO for servers that predate ESMTP.
  Future<void> _sayHello(SmtpStage stage) async {
    final reply = await transport.ehlo(config.clientDomain);
    if (reply.isPositive) {
      _capabilities = parseCapabilities(reply);
      _authMechanisms = parseAuthMechanisms(reply);
      return;
    }

    final fallback = await transport.helo(config.clientDomain);
    if (!fallback.isPositive) {
      throw SmtpFailure.fromReply(
        fallback,
        stage: stage,
        transcript: transcript.render(),
      );
    }
    _capabilities = const [];
    _authMechanisms = const {};
  }

  Future<SmtpReply> _authenticate(String password) {
    final mechanism = resolveMechanism();
    usedMechanism = mechanism;
    return switch (mechanism) {
      'CRAM-MD5' => transport.authCramMd5(config.username, password),
      'LOGIN' => transport.authLogin(config.username, password),
      _ => transport.authPlain(config.username, password),
    };
  }

  /// Chooses the SASL mechanism.
  ///
  /// An explicit choice in the domain editor always wins. On auto-detect we
  /// prefer a mechanism that does not put the password on the wire when the
  /// connection is not encrypted.
  String resolveMechanism() {
    switch (config.authMode) {
      case SmtpAuthMode.plain:
        return 'PLAIN';
      case SmtpAuthMode.login:
        return 'LOGIN';
      case SmtpAuthMode.cramMd5:
        return 'CRAM-MD5';
      case SmtpAuthMode.none:
      case SmtpAuthMode.auto:
        break;
    }

    final preference = config.security.isEncrypted
        ? const ['PLAIN', 'LOGIN', 'CRAM-MD5']
        : const ['CRAM-MD5', 'LOGIN', 'PLAIN'];
    for (final mechanism in preference) {
      if (_authMechanisms.contains(mechanism)) return mechanism;
    }
    // Some servers accept AUTH without advertising it. PLAIN is the most
    // widely supported fallback.
    return 'PLAIN';
  }

  /// True when the chosen mechanism would expose the password on an
  /// unencrypted connection. The UI warns before this happens.
  bool get willSendCredentialsInCleartext {
    if (!config.needsAuthentication) return false;
    if (config.security.isEncrypted) return false;
    final mechanism = resolveMechanism();
    return mechanism == 'PLAIN' || mechanism == 'LOGIN';
  }

  String _describeCapabilities() => _capabilities.isEmpty
      ? 'No capabilities advertised.'
      : 'Capabilities: ${_capabilities.join(', ')}';

  /// Closes the session, sending QUIT when the connection is still usable.
  Future<void> close({bool graceful = true}) async {
    if (graceful && transport.isConnected) {
      try {
        await transport.quit();
      } catch (_) {
        // A failed QUIT is not interesting — we are closing anyway.
      }
    }
    await transport.close();
  }
}
