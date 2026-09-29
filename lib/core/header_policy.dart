// Manymail - Many addresses, one app.
// Copyright (C) 2026 Bunny Pranav
// SPDX-License-Identifier: GPL-3.0-or-later
//
// This file is part of Manymail, distributed under the GNU General Public
// License v3 or later. See the LICENSE file at the root of this repository.

/// Which custom headers a message may carry.
///
/// The composer lets you add arbitrary `Name: value` pairs, but a few headers
/// are constructed by the mailer itself. Letting those through would either be
/// silently overwritten or produce a duplicate header, so they are blocked and
/// the reason is shown inline.
library;

/// The outcome of checking a header name.
enum HeaderVerdict {
  /// Safe to add.
  allowed,

  /// The mailer controls this header; it cannot be set here.
  reserved,

  /// Allowed, but there is a dedicated field for it in the composer.
  duplicated,

  /// Not a syntactically valid header name.
  malformed,
}

/// Headers the mailer builds itself, which a custom header must not replace.
const Set<String> reservedHeaders = {
  'from',
  'to',
  'cc',
  'bcc',
  'subject',
  'date',
  'message-id',
  'mime-version',
};

/// Headers with a dedicated composer field. Setting them by hand is allowed
/// but flagged, since the two would conflict.
const Set<String> duplicatedHeaders = {'reply-to'};

/// RFC 5322 `ftext`: printable US-ASCII except colon.
final RegExp _headerNamePattern = RegExp(r'^[\x21-\x39\x3B-\x7E]+$');

/// Checks whether [name] may be added as a custom header.
HeaderVerdict checkHeaderName(String name) {
  final trimmed = name.trim();
  if (trimmed.isEmpty || !_headerNamePattern.hasMatch(trimmed)) {
    return HeaderVerdict.malformed;
  }
  final lower = trimmed.toLowerCase();

  // Content-* describes the body the mailer assembles, so all of it is off
  // limits — Content-Type, Content-Transfer-Encoding, Content-Disposition…
  if (lower.startsWith('content-')) return HeaderVerdict.reserved;

  if (reservedHeaders.contains(lower)) return HeaderVerdict.reserved;
  if (duplicatedHeaders.contains(lower)) return HeaderVerdict.duplicated;
  return HeaderVerdict.allowed;
}

/// A message explaining a verdict, or null when the header is plainly fine.
String? headerVerdictMessage(String name, HeaderVerdict verdict) =>
    switch (verdict) {
      HeaderVerdict.allowed => null,
      HeaderVerdict.malformed =>
        'Not a valid header name. Use letters, digits and hyphens.',
      HeaderVerdict.reserved =>
        '"${name.trim()}" is built by the mailer and cannot be set here.',
      HeaderVerdict.duplicated =>
        '"${name.trim()}" also has its own field above. Setting both would '
            'send the header twice.',
    };

/// Whether a value is safe to put in a header.
///
/// Header injection via embedded CR/LF is the thing to prevent here: a newline
/// in a value could otherwise terminate the header and inject another one.
bool isValidHeaderValue(String value) =>
    !value.contains('\r') && !value.contains('\n');

/// Strips anything that could break out of a header value.
String sanitiseHeaderValue(String value) =>
    value.replaceAll('\r', ' ').replaceAll('\n', ' ').trim();
