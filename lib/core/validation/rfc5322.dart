// Manymail - Many addresses, one app.
// Copyright (C) 2026 Bunny Pranav
// SPDX-License-Identifier: GPL-3.0-or-later
//
// This file is part of Manymail, distributed under the GNU General Public
// License v3 or later. See the LICENSE file at the root of this repository.

/// Address validation for free-form sender identities.
///
/// Manymail lets you type any local part you like. Validation here is advisory:
/// it produces a *hint*, never a block. The composer shows the hint inline and
/// still lets you send, because only the server can decide which senders it
/// accepts — and surfacing that decision verbatim is the point of the app.
library;

/// RFC 5322 `atext`: the characters permitted in an unquoted local part.
///
///     atext = ALPHA / DIGIT / "!" / "#" / "$" / "%" / "&" / "'" / "*"
///           / "+" / "-" / "/" / "=" / "?" / "^" / "_" / "`" / "{" / "|"
///           / "}" / "~"
const String _atext =
    'abcdefghijklmnopqrstuvwxyz'
    'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
    '0123456789'
    "!#\$%&'*+-/=?^_`{|}~";

/// RFC 5321 §4.5.3.1.1: local part is limited to 64 octets.
const int maxLocalPartLength = 64;

/// RFC 5321 §4.5.3.1.2: domain is limited to 255 octets.
const int maxDomainLength = 255;

/// Why a local part was rejected, or [LocalPartIssue.none] if it is a valid
/// `dot-atom`.
enum LocalPartIssue {
  none,
  empty,
  tooLong,
  leadingDot,
  trailingDot,
  consecutiveDots,
  illegalCharacter,
}

/// Result of checking a local part.
class LocalPartResult {
  const LocalPartResult(this.issue, {this.offendingCharacter});

  final LocalPartIssue issue;

  /// The first character that is not `atext`, when [issue] is
  /// [LocalPartIssue.illegalCharacter].
  final String? offendingCharacter;

  bool get isValid => issue == LocalPartIssue.none;

  /// A short, human-readable hint suitable for inline display, or `null` when
  /// the local part is valid.
  String? get hint => switch (issue) {
    LocalPartIssue.none => null,
    LocalPartIssue.empty => 'Alias is empty',
    LocalPartIssue.tooLong =>
      'Alias is longer than $maxLocalPartLength characters',
    LocalPartIssue.leadingDot => 'Cannot start with a dot',
    LocalPartIssue.trailingDot => 'Cannot end with a dot',
    LocalPartIssue.consecutiveDots => 'Cannot contain two dots in a row',
    LocalPartIssue.illegalCharacter =>
      '"${offendingCharacter ?? '?'}" is not allowed unquoted',
  };
}

/// Validates a local part against the RFC 5322 `dot-atom` form.
///
/// Quoted local parts (`"odd name"@example.com`) are legal but vanishingly
/// rare and awkward to type on a phone; they are reported as invalid so the
/// hint appears, and — as everywhere here — sending is still permitted.
LocalPartResult validateLocalPart(String localPart) {
  if (localPart.isEmpty) {
    return const LocalPartResult(LocalPartIssue.empty);
  }
  if (localPart.length > maxLocalPartLength) {
    return const LocalPartResult(LocalPartIssue.tooLong);
  }
  if (localPart.startsWith('.')) {
    return const LocalPartResult(LocalPartIssue.leadingDot);
  }
  if (localPart.endsWith('.')) {
    return const LocalPartResult(LocalPartIssue.trailingDot);
  }
  if (localPart.contains('..')) {
    return const LocalPartResult(LocalPartIssue.consecutiveDots);
  }
  for (final rune in localPart.runes) {
    final char = String.fromCharCode(rune);
    if (char == '.') continue;
    if (!_atext.contains(char)) {
      return LocalPartResult(
        LocalPartIssue.illegalCharacter,
        offendingCharacter: char,
      );
    }
  }
  return const LocalPartResult(LocalPartIssue.none);
}

/// Loose domain check: labels of `let-dig` plus hyphen, separated by dots.
///
/// Intentionally permissive — it exists to catch typos, not to enforce DNS.
bool isPlausibleDomain(String domain) {
  if (domain.isEmpty || domain.length > maxDomainLength) return false;
  if (domain.startsWith('.') || domain.endsWith('.')) return false;
  if (domain.contains('..')) return false;
  if (!domain.contains('.')) return false;
  return RegExp(
    r'^[A-Za-z0-9]([A-Za-z0-9-]*[A-Za-z0-9])?'
    r'(\.[A-Za-z0-9]([A-Za-z0-9-]*[A-Za-z0-9])?)+$',
  ).hasMatch(domain);
}

/// Whether a whole address looks well-formed.
bool isPlausibleEmail(String address) {
  final at = address.lastIndexOf('@');
  if (at <= 0 || at == address.length - 1) return false;
  return validateLocalPart(address.substring(0, at)).isValid &&
      isPlausibleDomain(address.substring(at + 1));
}

/// RFC 5322 `specials` — their presence forces a quoted display name.
const String _specials = r'()<>[]:;@\,."';

/// Renders a display name for use in a `From`/`To` header, quoting it when the
/// grammar requires it.
String formatDisplayName(String displayName) {
  final trimmed = displayName.trim();
  if (trimmed.isEmpty) return '';
  final needsQuoting = trimmed.runes.any(
    (r) => _specials.contains(String.fromCharCode(r)),
  );
  if (!needsQuoting) return trimmed;
  final escaped = trimmed.replaceAll(r'\', r'\\').replaceAll('"', r'\"');
  return '"$escaped"';
}

/// Assembles the address that will appear in the `From` header.
///
/// This is the live preview shown in the composer, and it is the same string
/// the mailer will use, so what you see is what is sent.
String formatMailbox({
  required String displayName,
  required String localPart,
  required String domain,
}) {
  final address = '$localPart@$domain';
  final name = formatDisplayName(displayName);
  return name.isEmpty ? address : '$name <$address>';
}

/// Splits a pasted string into individual addresses.
///
/// Separators are comma, semicolon and newline. Whitespace only separates
/// addresses within a fragment that has no angle brackets, so a pasted
/// `Bunny Hopper <hello@example.com>` stays a single address instead of being torn
/// apart at the space in its display name.
///
/// Commas inside angle brackets or inside a quoted display name
/// (`"Doe, John" <j@example.com>`) are not treated as separators.
List<String> splitAddressList(String input) {
  final results = <String>[];
  final buffer = StringBuffer();
  var inAngle = false;
  var inQuote = false;

  void flush() {
    final chunk = buffer.toString().trim();
    buffer.clear();
    if (chunk.isEmpty) return;
    if (chunk.contains('<')) {
      results.add(extractAddress(chunk));
      return;
    }
    // Nothing but bare addresses here, so whitespace separates them too.
    for (final part in chunk.split(RegExp(r'\s+'))) {
      final address = part.trim();
      if (address.isNotEmpty) results.add(address);
    }
  }

  for (final rune in input.runes) {
    final char = String.fromCharCode(rune);
    if (char == '"') {
      inQuote = !inQuote;
    } else if (!inQuote && char == '<') {
      inAngle = true;
    } else if (!inQuote && char == '>') {
      inAngle = false;
    } else if (!inQuote &&
        !inAngle &&
        (char == ',' || char == ';' || char == '\n' || char == '\r')) {
      flush();
      continue;
    }
    buffer.write(char);
  }
  flush();
  return results;
}

/// Pulls the bare address out of `Display Name <user@example.com>`, or returns
/// the input unchanged when there are no angle brackets.
String extractAddress(String input) {
  final match = RegExp(r'<([^>]*)>').firstMatch(input);
  return (match?.group(1) ?? input).trim();
}
