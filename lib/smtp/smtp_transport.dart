// Manymail - Many addresses, one app.
// Copyright (C) 2026 Bunny Pranav
// SPDX-License-Identifier: GPL-3.0-or-later
//
// This file is part of Manymail, distributed under the GNU General Public
// License v3 or later. See the LICENSE file at the root of this repository.

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';

import '../core/transcript.dart';

/// One complete SMTP reply, which may span several lines.
///
/// RFC 5321 §4.2: continuation lines carry `<code>-`, the final line carries
/// `<code><SP>`. Replies are assembled by that rule rather than by how the
/// bytes happen to be split across TCP reads.
class SmtpReply {
  SmtpReply(this.code, this.lines);

  /// The reply code from the final line.
  final int code;

  /// Every line of the reply, verbatim, including the leading code.
  final List<String> lines;

  /// 2xx/3xx — the command was accepted.
  bool get isPositive => code >= 200 && code < 400;

  /// 4xx — the server could not comply now but might later.
  bool get isTransient => code >= 400 && code < 500;

  /// 5xx — the server refuses. Retrying will not help.
  bool get isPermanent => code >= 500;

  /// The reply exactly as the server wrote it. This is what the UI shows: the
  /// server's own words, never a paraphrase.
  String get text => lines.join('\n');

  /// Just the human-readable part of the final line.
  String get message {
    if (lines.isEmpty) return '';
    final last = lines.last;
    return last.length > 4 ? last.substring(4) : '';
  }

  @override
  String toString() => text;
}

/// Raised when the transport itself fails (socket, TLS, timeout, protocol).
class SmtpTransportException implements Exception {
  SmtpTransportException(this.message, {this.cause});

  final String message;
  final Object? cause;

  @override
  String toString() => message;
}

/// A direct SMTP client.
///
/// Manymail speaks SMTP itself rather than through `enough_mail`'s
/// `SmtpClient`, for one decisive reason: that client's send sequence moves
/// from `MAIL FROM` to `RCPT TO` without inspecting the reply, so a
/// `550 Sender address rejected` is never surfaced and the send is reported as
/// successful. This app exists to show that rejection verbatim, so every reply
/// here is checked and returned to the caller.
///
/// `enough_mail` is still used to *build* the MIME message, which is a separate
/// and well-tested part of that package.
///
/// Every byte in both directions is written to [transcript], which redacts
/// credentials as it records.
class SmtpTransport {
  SmtpTransport({
    required this.transcript,
    required this.timeout,
    this.allowInsecureCertificate = false,
  });

  final SmtpTranscript transcript;
  final Duration timeout;
  final bool allowInsecureCertificate;

  Socket? _socket;

  // Cancelled in close() and, on STARTTLS, when the socket is replaced.
  // ignore: cancel_subscriptions
  StreamSubscription<List<int>>? _subscription;

  /// Bytes received but not yet consumed as a complete reply.
  final StringBuffer _buffer = StringBuffer();

  /// Completer for the reply currently being awaited.
  Completer<SmtpReply>? _pending;

  /// Set when the socket fails or closes unexpectedly.
  Object? _fatalError;

  bool get isConnected => _socket != null;

  // ------------------------------------------------------------- connection

  /// Opens the connection and returns the server's greeting.
  ///
  /// [secure] selects implicit TLS (SMTPS, usually port 465).
  Future<SmtpReply> connect(
    String host,
    int port, {
    required bool secure,
  }) async {
    transcript.add(
      TranscriptDirection.app,
      'connecting to $host:$port (${secure ? 'implicit TLS' : 'plain'}), '
      'timeout ${timeout.inSeconds}s',
    );

    try {
      final socket = secure
          ? await SecureSocket.connect(
              host,
              port,
              onBadCertificate: _certificateCallback,
              timeout: timeout,
            )
          : await Socket.connect(host, port, timeout: timeout);
      _attach(socket);
    } on SocketException catch (error) {
      throw SmtpTransportException(_describeSocketError(error), cause: error);
    } on HandshakeException catch (error) {
      throw SmtpTransportException(
        'TLS handshake failed: ${error.message}',
        cause: error,
      );
    }

    final greeting = await _readReply();
    if (!greeting.isPositive) {
      throw SmtpTransportException(
        'The server refused the connection: ${greeting.text}',
      );
    }
    return greeting;
  }

  void _attach(Socket socket) {
    _socket = socket;
    _subscription = socket.listen(
      _onData,
      onError: _onError,
      onDone: _onDone,
      cancelOnError: false,
    );
  }

  bool _certificateCallback(X509Certificate certificate) {
    if (allowInsecureCertificate) {
      transcript.add(
        TranscriptDirection.app,
        'accepting untrusted certificate for ${certificate.subject} '
        '(allow-insecure-certificate is on)',
      );
      return true;
    }
    return false;
  }

  // ------------------------------------------------------------------ verbs

  /// Sends EHLO and returns the reply, whose lines carry the capability list.
  Future<SmtpReply> ehlo(String clientDomain) =>
      _command('EHLO $clientDomain');

  /// Falls back to HELO for servers that do not speak ESMTP.
  Future<SmtpReply> helo(String clientDomain) => _command('HELO $clientDomain');

  /// Issues STARTTLS and upgrades the socket in place.
  ///
  /// The caller must re-issue EHLO afterwards: the capability list a server
  /// advertises before TLS is not binding, and AUTH usually only appears
  /// after the upgrade.
  Future<SmtpReply> startTls(String host) async {
    final reply = await _command('STARTTLS');
    if (!reply.isPositive) return reply;

    final socket = _socket;
    if (socket == null) {
      throw SmtpTransportException('Connection closed before STARTTLS.');
    }

    // Pause before handing the socket to SecureSocket.secure, so no plaintext
    // byte is consumed by our listener during the upgrade.
    final subscription = _subscription;
    subscription?.pause();
    try {
      final secured = await SecureSocket.secure(
        socket,
        host: host,
        onBadCertificate: _certificateCallback,
      );
      await subscription?.cancel();
      _subscription = null;
      _buffer.clear();
      _attach(secured);
      transcript.add(
        TranscriptDirection.app,
        'connection upgraded to TLS',
      );
    } on HandshakeException catch (error) {
      throw SmtpTransportException(
        'TLS handshake failed after STARTTLS: ${error.message}',
        cause: error,
      );
    } on TlsException catch (error) {
      throw SmtpTransportException(
        'TLS upgrade failed: ${error.message}',
        cause: error,
      );
    }
    return reply;
  }

  /// AUTH PLAIN, sent as a single command with the initial response.
  Future<SmtpReply> authPlain(String username, String password) {
    final token = base64.encode(
      utf8.encode('\u0000$username\u0000$password'),
    );
    return _command('AUTH PLAIN $token');
  }

  /// AUTH LOGIN, a two-step base64 exchange.
  Future<SmtpReply> authLogin(String username, String password) async {
    final start = await _command('AUTH LOGIN');
    if (start.code != 334) return start;

    final userReply = await _command(base64.encode(utf8.encode(username)));
    if (userReply.code != 334) return userReply;

    return _command(base64.encode(utf8.encode(password)));
  }

  /// AUTH CRAM-MD5: the server sends a challenge, we answer with
  /// `username HMAC-MD5(password, challenge)` so the password never travels.
  Future<SmtpReply> authCramMd5(String username, String password) async {
    final start = await _command('AUTH CRAM-MD5');
    if (start.code != 334) return start;

    final challenge = utf8.decode(
      base64.decode(start.message.trim()),
      allowMalformed: true,
    );
    final digest = Hmac(
      md5,
      utf8.encode(password),
    ).convert(utf8.encode(challenge));
    final response = base64.encode(utf8.encode('$username $digest'));
    return _command(response);
  }

  /// `MAIL FROM` — the envelope sender.
  ///
  /// Manymail puts the free-form address here, the same one shown in the From
  /// header. Servers that restrict senders reject it at this step, and this
  /// method hands that reply straight back rather than pressing on.
  Future<SmtpReply> mailFrom(String address, {bool use8BitMime = false}) =>
      _command(
        use8BitMime
            ? 'MAIL FROM:<$address> BODY=8BITMIME'
            : 'MAIL FROM:<$address>',
      );

  Future<SmtpReply> rcptTo(String address) => _command('RCPT TO:<$address>');

  /// Opens the DATA phase. A 354 means the server is ready for the message.
  Future<SmtpReply> data() => _command('DATA');

  /// Sends the message body and the terminating `.`.
  ///
  /// Lines beginning with `.` are dot-stuffed per RFC 5321 §4.5.2.
  Future<SmtpReply> sendMessageData(String mime) async {
    final normalised = _normaliseLineEndings(mime);
    final stuffed = _dotStuff(normalised);

    _write('$stuffed\r\n.\r\n', logAs: '[message data, ${mime.length} bytes]');
    return _readReply();
  }

  Future<SmtpReply> rset() => _command('RSET');

  Future<SmtpReply> quit() => _command('QUIT');

  /// Closes the socket. Safe to call more than once.
  Future<void> close() async {
    final subscription = _subscription;
    final socket = _socket;
    _subscription = null;
    _socket = null;
    try {
      await subscription?.cancel();
    } catch (_) {
      // Already gone.
    }
    try {
      socket?.destroy();
    } catch (_) {
      // Already gone.
    }
  }

  // ------------------------------------------------------------- plumbing

  Future<SmtpReply> _command(String line) {
    _write('$line\r\n', logAs: line);
    return _readReply();
  }

  void _write(String data, {required String logAs}) {
    final socket = _socket;
    if (socket == null) {
      throw SmtpTransportException('Not connected.');
    }
    transcript.add(TranscriptDirection.client, logAs);
    socket.write(data);
  }

  Future<SmtpReply> _readReply() {
    if (_fatalError != null) {
      return Future.error(
        SmtpTransportException(
          'Connection lost: $_fatalError',
          cause: _fatalError,
        ),
      );
    }
    if (_pending != null) {
      throw StateError('A reply is already being awaited.');
    }
    final completer = Completer<SmtpReply>();
    _pending = completer;
    // Something may already be buffered from a previous read.
    _drain();
    return completer.future.timeout(
      timeout,
      onTimeout: () {
        _pending = null;
        throw SmtpTransportException(
          'The server did not reply within ${timeout.inSeconds}s.',
        );
      },
    );
  }

  void _onData(List<int> data) {
    _buffer.write(utf8.decode(data, allowMalformed: true));
    _drain();
  }

  /// Pulls one complete reply out of the buffer, if there is one.
  void _drain() {
    final pending = _pending;
    if (pending == null || pending.isCompleted) return;

    final content = _buffer.toString();
    final terminator = _findReplyEnd(content);
    if (terminator == null) return;

    final replyText = content.substring(0, terminator);
    final remainder = content.substring(terminator);
    _buffer
      ..clear()
      ..write(remainder);

    final lines = const LineSplitter()
        .convert(replyText)
        .where((l) => l.isNotEmpty)
        .toList();
    if (lines.isEmpty) return;

    for (final line in lines) {
      transcript.add(TranscriptDirection.server, line);
    }

    final code = int.tryParse(
      lines.last.length >= 3 ? lines.last.substring(0, 3) : '',
    );
    _pending = null;
    if (code == null) {
      pending.completeError(
        SmtpTransportException('Unreadable reply from server: ${lines.last}'),
      );
      return;
    }
    pending.complete(SmtpReply(code, lines));
  }

  /// Returns the index just past the final line of a complete reply, or null
  /// when more data is needed.
  ///
  /// A line is final when its fourth character is not `-`; continuation lines
  /// carry `<code>-`.
  int? _findReplyEnd(String content) {
    var index = 0;
    while (true) {
      final breakIndex = content.indexOf('\n', index);
      if (breakIndex < 0) return null;
      final line = content
          .substring(index, breakIndex)
          .replaceAll('\r', '');
      if (line.length >= 3) {
        final isContinuation = line.length > 3 && line[3] == '-';
        if (!isContinuation) return breakIndex + 1;
      }
      index = breakIndex + 1;
    }
  }

  void _onError(Object error) {
    _fatalError = error;
    final pending = _pending;
    _pending = null;
    pending?.completeError(
      SmtpTransportException('Connection error: $error', cause: error),
    );
  }

  void _onDone() {
    final pending = _pending;
    _pending = null;
    pending?.completeError(
      SmtpTransportException('The server closed the connection.'),
    );
  }

  static String _normaliseLineEndings(String value) =>
      value.replaceAll('\r\n', '\n').replaceAll('\n', '\r\n');

  static String _dotStuff(String value) {
    final stuffed = value.replaceAll('\r\n.', '\r\n..');
    return stuffed.startsWith('.') ? '.$stuffed' : stuffed;
  }

  static String _describeSocketError(SocketException error) {
    final os = error.osError;
    final target = error.address?.host ?? error.message;
    if (os == null) return 'Network error: ${error.message}';
    return 'Could not reach $target: ${os.message}';
  }
}

/// Parses the capability names out of an EHLO reply.
///
/// The first line is the greeting text, not a capability.
List<String> parseCapabilities(SmtpReply ehlo) {
  if (ehlo.lines.length <= 1) return const [];
  return ehlo.lines
      .skip(1)
      .map((line) => line.length > 4 ? line.substring(4).trim() : '')
      .where((line) => line.isNotEmpty)
      .toList();
}

/// Extracts the SASL mechanism names from an EHLO reply's `AUTH` line.
Set<String> parseAuthMechanisms(SmtpReply ehlo) {
  final mechanisms = <String>{};
  for (final capability in parseCapabilities(ehlo)) {
    final upper = capability.toUpperCase();
    if (upper == 'AUTH' || upper.startsWith('AUTH ')) {
      // Both `AUTH PLAIN LOGIN` and the older `AUTH=PLAIN LOGIN` occur.
      for (final name in upper.split(RegExp(r'[\s=]+')).skip(1)) {
        if (name.isNotEmpty) mechanisms.add(name);
      }
    }
  }
  return mechanisms;
}
