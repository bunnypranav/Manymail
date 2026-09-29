// Manymail - Many addresses, one app.
// Copyright (C) 2026 Bunny Pranav
// SPDX-License-Identifier: GPL-3.0-or-later
//
// This file is part of Manymail, distributed under the GNU General Public
// License v3 or later. See the LICENSE file at the root of this repository.

@Tags(['integration'])
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:manymail/data/models/enums.dart';
import 'package:manymail/smtp/connection_tester.dart';
import 'package:manymail/smtp/smtp_config.dart';
import 'package:manymail/smtp/smtp_failure.dart';
import 'package:manymail/smtp/smtp_session.dart';

import '../tool/fake_smtp_server.dart';

/// Exercises the SMTP transport against a scripted server, so the paths that
/// matter most — authentication, a 4xx worth retrying, and a 5xx sender
/// rejection that must never be swallowed — are covered without a live host.
///
/// Message bodies below use triple-quoted strings with real line breaks;
/// the transport normalises them to CRLF on the wire.
void main() {
  late FakeSmtpServer server;

  SmtpConfig configFor(
    int port, {
    SmtpAuthMode authMode = SmtpAuthMode.auto,
    String username = 'user',
  }) => SmtpConfig(
    host: '127.0.0.1',
    port: port,
    security: SmtpSecurity.none,
    authMode: authMode,
    username: username,
    clientDomain: 'example.com',
    allowInsecureCertificate: false,
    timeout: const Duration(seconds: 10),
  );

  tearDown(() async => server.stop());

  group('connection test', () {
    test('reports every stage and the advertised capabilities', () async {
      server = FakeSmtpServer();
      await server.start();

      final report = await const ConnectionTester().test(
        configFor(server.port),
        password: 'password',
      );

      expect(report.success, isTrue, reason: report.failure?.summary);
      expect(
        report.steps.map((s) => s.stage),
        containsAll([
          SmtpStage.connect,
          SmtpStage.ehlo,
          SmtpStage.authenticate,
          SmtpStage.quit,
        ]),
      );
      expect(report.banner, contains('220'));
      expect(report.capabilities, contains('8BITMIME'));
      expect(report.capabilities.any((c) => c.startsWith('SIZE')), isTrue);
    });

    test('never leaks the password into the transcript', () async {
      server = FakeSmtpServer();
      await server.start();

      final report = await const ConnectionTester().test(
        configFor(server.port),
        password: 'password',
      );

      expect(report.success, isTrue);
      expect(report.transcript, isNot(contains('password')));
      // Nor the base64 of the AUTH PLAIN payload.
      expect(report.transcript, isNot(contains('AHVzZXIAcGFzc3dvcmQ=')));
      expect(report.transcript, contains('AUTH'));
    });

    test('warns when credentials cross an unencrypted connection', () async {
      // Only PLAIN offered, so there is no safe mechanism to fall back to.
      server = FakeSmtpServer(
        behaviour: const FakeSmtpBehaviour(authMechanisms: ['PLAIN']),
      );
      await server.start();

      final report = await const ConnectionTester().test(
        configFor(server.port),
        password: 'password',
      );

      expect(report.success, isTrue);
      expect(report.cleartextCredentialWarning, isTrue);
    });

    test('surfaces a rejected login verbatim and does not retry', () async {
      server = FakeSmtpServer(
        behaviour: const FakeSmtpBehaviour(rejectAuth: true),
      );
      await server.start();

      final report = await const ConnectionTester().test(
        configFor(server.port),
        password: 'wrong',
      );

      expect(report.success, isFalse);
      expect(report.failure!.stage, SmtpStage.authenticate);
      expect(report.failure!.kind, SmtpFailureKind.permanent);
      expect(report.failure!.isRetryable, isFalse);
      expect(report.failure!.serverResponse, contains('535'));
      expect(report.failure!.hint, contains('credentials'));
    });

    test('classifies an unreachable host as retryable network trouble',
        () async {
      server = FakeSmtpServer();
      await server.start();
      final deadPort = server.port;
      await server.stop();
      server = FakeSmtpServer(); // so tearDown has something to stop

      final report = await const ConnectionTester().test(
        configFor(deadPort),
        password: 'password',
      );

      expect(report.success, isFalse);
      expect(report.failure!.kind, SmtpFailureKind.network);
      expect(report.failure!.isRetryable, isTrue);
    });
  });

  group('auth mechanisms', () {
    for (final (mode, mechanism) in [
      (SmtpAuthMode.plain, 'PLAIN'),
      (SmtpAuthMode.login, 'LOGIN'),
      (SmtpAuthMode.cramMd5, 'CRAM-MD5'),
    ]) {
      test('authenticates with an explicit $mechanism', () async {
        server = FakeSmtpServer(
          behaviour: FakeSmtpBehaviour(authMechanisms: [mechanism]),
        );
        await server.start();

        final report = await const ConnectionTester().test(
          configFor(server.port, authMode: mode),
          password: 'password',
        );

        expect(report.success, isTrue, reason: report.failure?.summary);
        expect(report.transcript, contains('AUTH $mechanism'));
        expect(report.transcript, isNot(contains('password')));
      });
    }

    test('auto-detect prefers CRAM-MD5 on an unencrypted connection', () async {
      server = FakeSmtpServer();
      await server.start();

      final session = await SmtpSession.open(
        configFor(server.port),
        password: 'password',
      );
      addTearDown(() => session.close(graceful: false));

      expect(session.resolveMechanism(), 'CRAM-MD5');
      expect(session.willSendCredentialsInCleartext, isFalse);
    });

    test('auto-detect falls back to PLAIN and flags the cleartext risk',
        () async {
      server = FakeSmtpServer(
        behaviour: const FakeSmtpBehaviour(authMechanisms: ['PLAIN']),
      );
      await server.start();

      final session = await SmtpSession.open(
        configFor(server.port),
        password: 'password',
      );
      addTearDown(() => session.close(graceful: false));

      expect(session.resolveMechanism(), 'PLAIN');
      expect(session.willSendCredentialsInCleartext, isTrue);
    });
  });

  group('sender rejection — the behaviour this app exists to surface', () {
    test('a 5xx on MAIL FROM is reported, never swallowed', () async {
      server = FakeSmtpServer(
        behaviour: const FakeSmtpBehaviour(rejectSender: true),
      );
      await server.start();

      final session = await SmtpSession.open(
        configFor(server.port),
        password: 'password',
      );
      addTearDown(() => session.close(graceful: false));

      // The free-form address goes on the wire exactly as typed.
      final reply = await session.transport.mailFrom('hello@example.com');

      expect(reply.code, 550);
      expect(reply.isPermanent, isTrue);
      expect(reply.text, contains('not owned by user'));

      final failure = SmtpFailure.fromReply(
        reply,
        stage: SmtpStage.envelopeSender,
        rejectedAddress: 'hello@example.com',
      );
      expect(failure.kind, SmtpFailureKind.permanent);
      expect(failure.isRetryable, isFalse);
      expect(failure.isSenderRejection, isTrue);
      expect(failure.serverResponse, contains('5.7.1'));
      expect(failure.hint, contains('exactly as you typed it'));
    });

    test('the envelope carries the typed address, not the SMTP username',
        () async {
      server = FakeSmtpServer();
      await server.start();

      final session = await SmtpSession.open(
        configFor(server.port, username: 'user'),
        password: 'password',
      );
      addTearDown(() => session.close(graceful: false));

      expect(
        (await session.transport.mailFrom('billing@example.com')).isPositive,
        isTrue,
      );
      expect(
        (await session.transport.rcptTo('someone@example.com')).isPositive,
        isTrue,
      );
      expect((await session.transport.data()).code, 354);

      const message = '''
From: Billing <billing@example.com>
To: someone@example.com
Subject: Test

Body text
''';
      final result = await session.transport.sendMessageData(message);
      expect(result.isPositive, isTrue);

      final captured = server.messages.single;
      // The envelope sender is the free-form address, not "user".
      expect(captured.envelopeSender, 'billing@example.com');
      expect(captured.recipients, ['someone@example.com']);
      expect(captured.header('From'), contains('billing@example.com'));
    });

    test('a 4xx on MAIL FROM is transient, so the outbox will retry',
        () async {
      server = FakeSmtpServer(
        behaviour: const FakeSmtpBehaviour(transientFailure: true),
      );
      await server.start();

      final session = await SmtpSession.open(
        configFor(server.port),
        password: 'password',
      );
      addTearDown(() => session.close(graceful: false));

      final reply = await session.transport.mailFrom('hello@example.com');
      expect(reply.code, 451);
      expect(reply.isTransient, isTrue);

      final failure = SmtpFailure.fromReply(
        reply,
        stage: SmtpStage.envelopeSender,
      );
      expect(failure.kind, SmtpFailureKind.transient);
      expect(failure.isRetryable, isTrue);
      // A transient failure is not a sender rejection, so no misleading hint.
      expect(failure.isSenderRejection, isFalse);
    });
  });

  group('message data', () {
    test('a line containing only a dot does not end the message early',
        () async {
      server = FakeSmtpServer();
      await server.start();

      final session = await SmtpSession.open(
        configFor(server.port),
        password: 'password',
      );
      addTearDown(() => session.close(graceful: false));

      await session.transport.mailFrom('hello@example.com');
      await session.transport.rcptTo('someone@example.com');
      await session.transport.data();

      const message = '''
Subject: Dots

before
.
after
''';
      final result = await session.transport.sendMessageData(message);

      expect(result.isPositive, isTrue);
      final captured = server.messages.single;
      expect(captured.data, contains('before'));
      expect(captured.data, contains('after'));
    });

    test('Bcc recipients reach RCPT TO without appearing in the headers',
        () async {
      server = FakeSmtpServer();
      await server.start();

      final session = await SmtpSession.open(
        configFor(server.port),
        password: 'password',
      );
      addTearDown(() => session.close(graceful: false));

      await session.transport.mailFrom('hello@example.com');
      for (final recipient in [
        'visible@example.com',
        'hidden@example.com',
      ]) {
        await session.transport.rcptTo(recipient);
      }
      await session.transport.data();

      // Only To is written into the headers; the Bcc recipient is delivered
      // through the envelope alone.
      const message = '''
From: hello@example.com
To: visible@example.com
Subject: Bcc test

Body
''';
      await session.transport.sendMessageData(message);

      final captured = server.messages.single;
      expect(captured.recipients, [
        'visible@example.com',
        'hidden@example.com',
      ]);
      expect(captured.hasBccHeader, isFalse);
      expect(captured.data, isNot(contains('hidden@example.com')));
    });
  });
}
