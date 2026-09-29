// Manymail - Many addresses, one app.
// Copyright (C) 2026 Bunny Pranav
// SPDX-License-Identifier: GPL-3.0-or-later
//
// This file is part of Manymail, distributed under the GNU General Public
// License v3 or later. See the LICENSE file at the root of this repository.

@Tags(['integration'])
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:manymail/data/models/mail_domain.dart';
import 'package:manymail/data/models/outgoing_message.dart';
import 'package:manymail/smtp/message_composer.dart';
import 'package:manymail/smtp/send_service.dart';
import 'package:manymail/smtp/smtp_failure.dart';

import '../tool/fake_smtp_server.dart';

/// End-to-end checks of the send path against the scripted server.
void main() {
  late FakeSmtpServer server;

  MailDomain domainOn(int port) => MailDomain(
    id: 1,
    label: 'Fake',
    domain: 'example.com',
    host: '127.0.0.1',
    port: port,
    security: SmtpSecurity.none,
    authMode: SmtpAuthMode.auto,
    username: 'user',
    credentialKeyId: 'test-key',
    allowInsecureCertificate: false,
    timeoutSeconds: 10,
    isDefault: true,
    sortOrder: 0,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  OutgoingMessage messageFrom(
    String localPart, {
    List<String> to = const ['someone@example.com'],
    List<String> cc = const [],
    List<String> bcc = const [],
    String displayName = 'Bunny Hopper',
    String subject = 'Hello',
    Map<String, String> headers = const {},
    String? replyTo,
  }) {
    final now = DateTime.now();
    return OutgoingMessage(
      status: MessageStatus.draft,
      domainId: 1,
      domainSnapshot: 'example.com',
      localPart: localPart,
      displayName: displayName,
      to: to,
      cc: cc,
      bcc: bcc,
      subject: subject,
      bodyPlain: 'Body text',
      customHeaders: headers,
      replyTo: replyTo,
      createdAt: now,
      updatedAt: now,
    );
  }

  tearDown(() async => server.stop());

  group('a successful send', () {
    test('puts the free-form address in both From and MAIL FROM', () async {
      server = FakeSmtpServer();
      await server.start();

      final outcome = await const SendService().send(
        message: messageFrom('billing'),
        domain: domainOn(server.port),
        password: 'password',
      );

      expect(outcome.success, isTrue, reason: outcome.failure?.summary);
      expect(outcome.messageId, isNotNull);
      expect(outcome.acceptedResponse, contains('250'));

      final captured = server.messages.single;
      // The SMTP username is "user"; the envelope must still be what was typed.
      expect(captured.envelopeSender, 'billing@example.com');
      expect(captured.header('From'), contains('billing@example.com'));
      expect(captured.header('From'), contains('Bunny Hopper'));
      expect(captured.header('Subject'), 'Hello');
      expect(captured.header('Message-Id'), isNotNull);
    });

    test('accepts a local part the SMTP account has nothing to do with',
        () async {
      server = FakeSmtpServer();
      await server.start();

      for (final localPart in ['hello', 'no-reply', 'pranav+test', 'a.b.c']) {
        final outcome = await const SendService().send(
          message: messageFrom(localPart),
          domain: domainOn(server.port),
          password: 'password',
        );
        expect(outcome.success, isTrue, reason: localPart);
        expect(
          server.messages.last.envelopeSender,
          '$localPart@example.com',
        );
      }
    });

    test('records a Reply-To header when one is set', () async {
      server = FakeSmtpServer();
      await server.start();

      await const SendService().send(
        message: messageFrom('hello', replyTo: 'inbox@example.com'),
        domain: domainOn(server.port),
        password: 'password',
      );

      expect(
        server.messages.single.header('Reply-To'),
        contains('inbox@example.com'),
      );
    });
  });

  group('Bcc', () {
    test('reaches the envelope but never the headers', () async {
      server = FakeSmtpServer();
      await server.start();

      final outcome = await const SendService().send(
        message: messageFrom(
          'hello',
          to: ['visible@example.com'],
          cc: ['copied@example.com'],
          bcc: ['hidden@example.com'],
        ),
        domain: domainOn(server.port),
        password: 'password',
      );

      expect(outcome.success, isTrue);
      final captured = server.messages.single;

      // All three get an RCPT TO...
      expect(captured.recipients, [
        'visible@example.com',
        'copied@example.com',
        'hidden@example.com',
      ]);
      // ...but only two are named in the headers.
      expect(captured.header('To'), contains('visible@example.com'));
      expect(captured.header('Cc'), contains('copied@example.com'));
      expect(captured.hasBccHeader, isFalse);
      expect(captured.data, isNot(contains('hidden@example.com')));
    });
  });

  group('a refused sender', () {
    test('fails with the server text and is not retryable', () async {
      server = FakeSmtpServer(
        behaviour: const FakeSmtpBehaviour(rejectSender: true),
      );
      await server.start();

      final outcome = await const SendService().send(
        message: messageFrom('hello'),
        domain: domainOn(server.port),
        password: 'password',
      );

      expect(outcome.success, isFalse);
      expect(outcome.isRetryable, isFalse);
      expect(outcome.failure!.stage, SmtpStage.envelopeSender);
      expect(outcome.failure!.isSenderRejection, isTrue);
      expect(outcome.failure!.serverResponse, contains('not owned by user'));
      expect(outcome.failure!.hint, contains('exactly as you typed it'));
      // Nothing was delivered.
      expect(server.messages, isEmpty);
    });

    test('a 4xx is retryable and does not mark the message failed', () async {
      server = FakeSmtpServer(
        behaviour: const FakeSmtpBehaviour(transientFailure: true),
      );
      await server.start();

      final outcome = await const SendService().send(
        message: messageFrom('hello'),
        domain: domainOn(server.port),
        password: 'password',
      );

      expect(outcome.success, isFalse);
      expect(outcome.isRetryable, isTrue);
      expect(outcome.failure!.kind, SmtpFailureKind.transient);
    });
  });

  group('custom headers', () {
    test('passes through allowed headers', () async {
      server = FakeSmtpServer();
      await server.start();

      await const SendService().send(
        message: messageFrom(
          'hello',
          headers: {
            'X-Manymail-Test': 'yes',
            'List-Unsubscribe': '<mailto:stop@example.com>',
          },
        ),
        domain: domainOn(server.port),
        password: 'password',
      );

      final captured = server.messages.single;
      expect(captured.header('X-Manymail-Test'), 'yes');
      expect(
        captured.header('List-Unsubscribe'),
        '<mailto:stop@example.com>',
      );
    });

    test('drops headers the mailer controls rather than duplicating them',
        () async {
      server = FakeSmtpServer();
      await server.start();

      await const SendService().send(
        message: messageFrom(
          'hello',
          headers: {'From': 'spoofed@evil.example', 'Subject': 'Overridden'},
        ),
        domain: domainOn(server.port),
        password: 'password',
      );

      final captured = server.messages.single;
      expect(captured.header('From'), contains('hello@example.com'));
      expect(captured.header('Subject'), 'Hello');
      expect(captured.data, isNot(contains('spoofed@evil.example')));
    });
  });

  group('MIME construction', () {
    test('a plain-text message carries no HTML part', () async {
      final built = await const MessageComposer().build(messageFrom('hello'));
      expect(built.mime, contains('Body text'));
      expect(built.mime.toLowerCase(), isNot(contains('text/html')));
    });

    test('the envelope and recipient list include Bcc', () async {
      final built = await const MessageComposer().build(
        messageFrom(
          'hello',
          to: ['a@x.com'],
          bcc: ['b@y.com'],
        ),
      );
      expect(built.envelopeSender, 'hello@example.com');
      expect(built.recipients, ['a@x.com', 'b@y.com']);
      expect(built.mime, isNot(contains('b@y.com')));
    });

    test('the Message-Id is scoped to the sending domain', () async {
      final built = await const MessageComposer().build(messageFrom('hello'));
      expect(built.messageId, endsWith('@example.com>'));
    });
  });
}
