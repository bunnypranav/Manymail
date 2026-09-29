// Manymail - Many addresses, one app.
// Copyright (C) 2026 Bunny Pranav
// SPDX-License-Identifier: GPL-3.0-or-later
//
// This file is part of Manymail, distributed under the GNU General Public
// License v3 or later. See the LICENSE file at the root of this repository.

/// A scriptable SMTP server for testing Manymail without a real mail host.
///
/// It exists so the behaviours that matter most to this app — a server
/// refusing a sender address it does not own, a transient 4xx, each auth
/// mechanism, STARTTLS — can be exercised deterministically, in tests and by
/// hand against the emulator.
///
/// Run it directly:
///
///     dart run tool/fake_smtp_server.dart --port 2525
///     dart run tool/fake_smtp_server.dart --port 2526 --reject-sender
///     dart run tool/fake_smtp_server.dart --port 2527 --transient
///
/// From the Android emulator the host machine is reachable at `10.0.2.2`, so
/// configure a domain with host `10.0.2.2`, port `2525`, security `None`.
library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

/// How the server should behave, so one implementation covers every scenario.
class FakeSmtpBehaviour {
  const FakeSmtpBehaviour({
    this.greeting = '220 fake.manymail.test ESMTP ready',
    this.authMechanisms = const ['PLAIN', 'LOGIN', 'CRAM-MD5'],
    this.requireAuth = true,
    this.expectedUsername = 'user',
    this.expectedPassword = 'password',
    this.supportStartTls = false,
    this.rejectSender = false,
    this.rejectSenderCode = 550,
    this.rejectSenderText =
        '5.7.1 Sender address rejected: not owned by user',
    this.transientFailure = false,
    this.rejectAuth = false,
  });

  final String greeting;
  final List<String> authMechanisms;
  final bool requireAuth;
  final String expectedUsername;
  final String expectedPassword;
  final bool supportStartTls;

  /// Refuse `MAIL FROM` — the behaviour Manymail is designed to surface.
  final bool rejectSender;
  final int rejectSenderCode;
  final String rejectSenderText;

  /// Answer `MAIL FROM` with a 4xx, which should send the message to the
  /// outbox for retry rather than marking it failed.
  final bool transientFailure;

  final bool rejectAuth;
}

/// One accepted message.
class CapturedMessage {
  CapturedMessage({
    required this.envelopeSender,
    required this.recipients,
    required this.data,
  });

  /// The `MAIL FROM` argument — Manymail sends the free-form address here.
  final String envelopeSender;

  /// Every `RCPT TO`, including Bcc recipients that must not appear in the
  /// headers.
  final List<String> recipients;

  /// The raw message body as received.
  final String data;

  /// Reads a header value from the captured data.
  String? header(String name) {
    final lower = name.toLowerCase();
    for (final line in const LineSplitter().convert(data)) {
      if (line.trim().isEmpty) break; // end of headers
      final colon = line.indexOf(':');
      if (colon <= 0) continue;
      if (line.substring(0, colon).toLowerCase() == lower) {
        return line.substring(colon + 1).trim();
      }
    }
    return null;
  }

  bool get hasBccHeader => header('bcc') != null;
}

/// A minimal ESMTP server that records what it receives.
class FakeSmtpServer {
  FakeSmtpServer({this.behaviour = const FakeSmtpBehaviour(), this.onMessage});

  final FakeSmtpBehaviour behaviour;

  /// Called for each accepted message, so the CLI can print what arrived.
  final void Function(CapturedMessage)? onMessage;

  ServerSocket? _socket;
  final List<CapturedMessage> messages = [];

  int get port => _socket!.port;

  Future<void> start({int port = 0, String host = '0.0.0.0'}) async {
    _socket = await ServerSocket.bind(host, port);
    _socket!.listen(_handleClient);
  }

  Future<void> stop() async {
    await _socket?.close();
    _socket = null;
  }

  Future<void> _handleClient(Socket socket) async {
    final session = _Session(socket, behaviour, (message) {
      messages.add(message);
      onMessage?.call(message);
    });
    await session.run();
  }
}

class _Session {
  _Session(this._socket, this._behaviour, this._onMessage);

  final Socket _socket;
  final FakeSmtpBehaviour _behaviour;
  final void Function(CapturedMessage) _onMessage;

  String _envelopeSender = '';
  final List<String> _recipients = [];
  bool _authenticated = false;

  /// Set while collecting DATA, which ends at a lone ".".
  bool _inData = false;
  final StringBuffer _data = StringBuffer();

  /// Pending multi-step auth ("login-user", "login-pass", "cram", "plain").
  String? _authState;
  String _authUsername = '';

  void _send(String line) => _socket.write('$line\r\n');

  /// Writes a multi-line reply as a single write.
  ///
  /// Real SMTP servers emit a multi-line EHLO reply in one go, and
  /// `enough_mail` relies on that: `SmtpEhloCommand.isCommandDone` only
  /// considers EHLO complete once it sees more than one line in a single read.
  /// Writing the lines separately makes them arrive as separate TCP segments
  /// on loopback and the client waits forever.
  void _sendAll(List<String> lines) =>
      _socket.write('${lines.join('\r\n')}\r\n');

  Future<void> run() async {
    _send(_behaviour.greeting);
    final lines = utf8.decoder
        .bind(_socket)
        .transform(const LineSplitter());
    try {
      await for (final line in lines) {
        if (_inData) {
          _handleDataLine(line);
          continue;
        }
        if (_handleCommand(line)) break;
      }
    } catch (_) {
      // Client vanished; nothing to do.
    }
    await _socket.close();
  }

  void _handleDataLine(String line) {
    if (line == '.') {
      _inData = false;
      _onMessage(
        CapturedMessage(
          envelopeSender: _envelopeSender,
          recipients: List.of(_recipients),
          data: _data.toString(),
        ),
      );
      _data.clear();
      _recipients.clear();
      _send('250 2.0.0 Ok: queued as FAKE123');
      return;
    }
    // Undo dot-stuffing.
    _data.writeln(line.startsWith('..') ? line.substring(1) : line);
  }

  /// Returns true when the connection should close.
  bool _handleCommand(String line) {
    if (_authState != null) {
      _handleAuthContinuation(line);
      return false;
    }

    final upper = line.toUpperCase();

    if (upper.startsWith('EHLO')) {
      _sendAll([
        '250-fake.manymail.test greets you',
        '250-SIZE 35882577',
        '250-8BITMIME',
        if (_behaviour.supportStartTls) '250-STARTTLS',
        if (_behaviour.authMechanisms.isNotEmpty)
          '250-AUTH ${_behaviour.authMechanisms.join(' ')}',
        '250 ENHANCEDSTATUSCODES',
      ]);
      return false;
    }

    if (upper.startsWith('HELO')) {
      _send('250 fake.manymail.test');
      return false;
    }

    if (upper.startsWith('STARTTLS')) {
      // Upgrading would need a certificate; tests that need real TLS should
      // use implicit TLS with a generated cert instead.
      _send('454 4.7.0 TLS not available on this fake server');
      return false;
    }

    if (upper.startsWith('AUTH ')) {
      _handleAuth(line);
      return false;
    }

    if (upper.startsWith('MAIL FROM')) {
      if (_behaviour.requireAuth && !_authenticated) {
        _send('530 5.7.0 Authentication required');
        return false;
      }
      _envelopeSender = _extractAddress(line);
      if (_behaviour.transientFailure) {
        _send('451 4.3.0 Temporary failure, please retry');
        return false;
      }
      if (_behaviour.rejectSender) {
        _send(
          '${_behaviour.rejectSenderCode} ${_behaviour.rejectSenderText}',
        );
        return false;
      }
      _send('250 2.1.0 Ok');
      return false;
    }

    if (upper.startsWith('RCPT TO')) {
      _recipients.add(_extractAddress(line));
      _send('250 2.1.5 Ok');
      return false;
    }

    if (upper.startsWith('DATA')) {
      _inData = true;
      _send('354 End data with <CR><LF>.<CR><LF>');
      return false;
    }

    if (upper.startsWith('RSET')) {
      _envelopeSender = '';
      _recipients.clear();
      _send('250 2.0.0 Ok');
      return false;
    }

    if (upper.startsWith('QUIT')) {
      _send('221 2.0.0 Bye');
      return true;
    }

    if (upper.startsWith('NOOP')) {
      _send('250 2.0.0 Ok');
      return false;
    }

    _send('502 5.5.2 Command not implemented');
    return false;
  }

  void _handleAuth(String line) {
    final parts = line.split(RegExp(r'\s+'));
    final mechanism = parts.length > 1 ? parts[1].toUpperCase() : '';

    if (!_behaviour.authMechanisms.contains(mechanism)) {
      _send('504 5.5.4 Unrecognized authentication type');
      return;
    }

    switch (mechanism) {
      case 'PLAIN':
        if (parts.length > 2) {
          _finishPlain(parts[2]);
        } else {
          _authState = 'plain';
          _send('334 ');
        }
      case 'LOGIN':
        _authState = 'login-user';
        _send('334 ${base64.encode(utf8.encode('Username:'))}');
      case 'CRAM-MD5':
        _authState = 'cram';
        _send('334 ${base64.encode(utf8.encode('<fake.challenge@test>'))}');
    }
  }

  void _handleAuthContinuation(String line) {
    final state = _authState;
    switch (state) {
      case 'plain':
        _authState = null;
        _finishPlain(line);
      case 'login-user':
        _authUsername = _decode(line);
        _authState = 'login-pass';
        _send('334 ${base64.encode(utf8.encode('Password:'))}');
      case 'login-pass':
        _authState = null;
        _completeAuth(
          _authUsername == _behaviour.expectedUsername &&
              _decode(line) == _behaviour.expectedPassword,
        );
      case 'cram':
        _authState = null;
        // The digest cannot be verified without reimplementing HMAC-MD5 here;
        // accepting any well-formed response is enough to exercise the client
        // path, which is what this server is for.
        _completeAuth(_decode(line).contains(' '));
    }
  }

  void _finishPlain(String encoded) {
    final decoded = _decode(encoded);
    // authzid NUL authcid NUL password
    final fields = decoded.split('\u0000');
    final user = fields.length > 1 ? fields[1] : '';
    final password = fields.length > 2 ? fields[2] : '';
    _completeAuth(
      user == _behaviour.expectedUsername &&
          password == _behaviour.expectedPassword,
    );
  }

  void _completeAuth(bool credentialsMatch) {
    if (_behaviour.rejectAuth || !credentialsMatch) {
      _send('535 5.7.8 Authentication credentials invalid');
      return;
    }
    _authenticated = true;
    _send('235 2.7.0 Authentication successful');
  }

  String _decode(String value) {
    try {
      return utf8.decode(base64.decode(value.trim()));
    } catch (_) {
      return '';
    }
  }

  String _extractAddress(String line) {
    final match = RegExp('<([^>]*)>').firstMatch(line);
    return match?.group(1) ?? '';
  }
}

Future<void> main(List<String> args) async {
  var port = 2525;
  var rejectSender = false;
  var transient = false;
  var rejectAuth = false;
  var requireAuth = true;

  for (var i = 0; i < args.length; i++) {
    switch (args[i]) {
      case '--port':
        port = int.parse(args[++i]);
      case '--reject-sender':
        rejectSender = true;
      case '--transient':
        transient = true;
      case '--reject-auth':
        rejectAuth = true;
      case '--no-auth':
        requireAuth = false;
    }
  }

  final server = FakeSmtpServer(
    behaviour: FakeSmtpBehaviour(
      rejectSender: rejectSender,
      transientFailure: transient,
      rejectAuth: rejectAuth,
      requireAuth: requireAuth,
    ),
    onMessage: (message) {
      // ignore: avoid_print
      print(
        [
          '--- message accepted ---',
          'MAIL FROM: ${message.envelopeSender}',
          'RCPT TO:   ${message.recipients.join(', ')}',
          message.data,
          '--- end ---',
        ].join(Platform.lineTerminator),
      );
    },
  );
  await server.start(port: port);

  // ignore: avoid_print
  print(
    'Fake SMTP listening on 0.0.0.0:$port '
    '(emulator host address: 10.0.2.2:$port)\n'
    'username: user  password: password\n'
    'reject-sender=$rejectSender transient=$transient '
    'reject-auth=$rejectAuth require-auth=$requireAuth',
  );
}
