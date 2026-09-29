// Manymail - Many addresses, one app.
// Copyright (C) 2026 Bunny Pranav
// SPDX-License-Identifier: GPL-3.0-or-later
//
// This file is part of Manymail, distributed under the GNU General Public
// License v3 or later. See the LICENSE file at the root of this repository.

/// SMTP protocol transcript capture with credential redaction.
///
/// Manymail shows the raw SMTP dialogue in the UI so that a server's rejection
/// of a free-form sender address is visible verbatim rather than paraphrased.
/// That means the transcript is written to the database and rendered on screen,
/// so it must never contain credentials.
///
/// Redaction happens here, at the moment a line is appended — not at the UI
/// layer. This is deliberately the only chokepoint: a credential cannot reach
/// the transcript, the database, an error message or a log without passing
/// through [SmtpTranscript.add].
library;

/// Which side of the conversation a transcript line came from.
enum TranscriptDirection {
  /// Sent by us to the server.
  client,

  /// Received from the server.
  server,

  /// Client-side commentary (connection established, TLS upgraded, ...).
  app,
}

/// A single captured line.
class TranscriptEntry {
  TranscriptEntry({
    required this.direction,
    required this.text,
    required this.at,
  });

  final TranscriptDirection direction;
  final String text;
  final DateTime at;

  String get prefix => switch (direction) {
    TranscriptDirection.client => 'C',
    TranscriptDirection.server => 'S',
    TranscriptDirection.app => '*',
  };
}

/// Accumulates an SMTP conversation, redacting credentials as it goes.
class SmtpTranscript {
  SmtpTranscript({this.maxLineLength = 2000, this.maxEntries = 500});

  /// Long lines (notably the DATA payload) are truncated rather than stored in
  /// full — the transcript is a protocol record, not a second copy of the
  /// message body.
  final int maxLineLength;

  /// Hard cap so a pathological session cannot grow without bound.
  final int maxEntries;

  static const String redacted = '***redacted***';

  final List<TranscriptEntry> _entries = <TranscriptEntry>[];

  /// Literal secrets (passwords) scrubbed from every line as a second line of
  /// defence, in case a library ever logs one somewhere unexpected.
  final List<String> _secrets = <String>[];

  /// True while we are inside an AUTH exchange, where client lines are bare
  /// base64 credential material.
  bool _inAuthExchange = false;

  bool _truncated = false;

  List<TranscriptEntry> get entries => List.unmodifiable(_entries);

  /// Whether any content was dropped because [maxEntries] was reached.
  bool get isTruncated => _truncated;

  /// Registers a value that must never appear in the transcript.
  ///
  /// Empty and very short values are ignored: scrubbing a 1-2 character string
  /// would corrupt unrelated lines without protecting anything meaningful.
  void registerSecret(String? secret) {
    if (secret == null || secret.length < 3) return;
    if (!_secrets.contains(secret)) _secrets.add(secret);
  }

  /// Appends a line, applying redaction.
  void add(TranscriptDirection direction, String raw) {
    for (final line in _splitLines(raw)) {
      if (_entries.length >= maxEntries) {
        _truncated = true;
        return;
      }
      _entries.add(
        TranscriptEntry(
          direction: direction,
          text: _sanitise(direction, line),
          at: DateTime.now(),
        ),
      );
    }
  }

  /// Splits on CRLF/LF and drops trailing empties, so one write of a multi-line
  /// response becomes one entry per protocol line.
  Iterable<String> _splitLines(String raw) => raw
      .replaceAll('\r\n', '\n')
      .split('\n')
      .where((l) => l.trim().isNotEmpty);

  String _sanitise(TranscriptDirection direction, String line) {
    var out = line;

    if (direction == TranscriptDirection.client) {
      out = _redactClientLine(out);
    } else if (direction == TranscriptDirection.server) {
      _updateAuthStateFromServer(out);
    }

    for (final secret in _secrets) {
      if (out.contains(secret)) out = out.replaceAll(secret, redacted);
    }

    if (out.length > maxLineLength) {
      out = '${out.substring(0, maxLineLength)}… '
          '[truncated, ${line.length} chars total]';
    }
    return out;
  }

  String _redactClientLine(String line) {
    final trimmed = line.trimLeft();
    final upper = trimmed.toUpperCase();

    if (upper.startsWith('AUTH ')) {
      _inAuthExchange = true;
      // Keep `AUTH <MECHANISM>` visible — which mechanism was negotiated is
      // diagnostically useful — but drop any initial response that follows it.
      final parts = trimmed.split(RegExp(r'\s+'));
      final mechanism = parts.length > 1 ? parts[1] : '';
      final hasInitialResponse = parts.length > 2;
      return hasInitialResponse
          ? 'AUTH $mechanism $redacted'
          : 'AUTH $mechanism';
    }

    if (_inAuthExchange) {
      // Bare base64 continuation: username, password, or CRAM-MD5 digest.
      return redacted;
    }

    return line;
  }

  void _updateAuthStateFromServer(String line) {
    if (!_inAuthExchange) return;
    final code = responseCodeOf(line);
    if (code == null) return;
    // 334 is "continue, send more credential material". Any other final
    // response ends the AUTH exchange.
    if (code != 334) _inAuthExchange = false;
  }

  /// Parses a leading three-digit SMTP response code, if present.
  static int? responseCodeOf(String line) {
    final match = RegExp(r'^(\d{3})').firstMatch(line.trimLeft());
    return match == null ? null : int.tryParse(match.group(1)!);
  }

  /// Renders the transcript for display or storage.
  String render() {
    final buffer = StringBuffer();
    for (final e in _entries) {
      buffer.writeln('${e.prefix}: ${e.text}');
    }
    if (_truncated) {
      buffer.writeln('*: [transcript truncated at $maxEntries lines]');
    }
    return buffer.toString().trimRight();
  }

  @override
  String toString() => render();
}
