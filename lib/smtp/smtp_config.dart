// Manymail - Many addresses, one app.
// Copyright (C) 2026 Bunny Pranav
// SPDX-License-Identifier: GPL-3.0-or-later
//
// This file is part of Manymail, distributed under the GNU General Public
// License v3 or later. See the LICENSE file at the root of this repository.

import '../data/models/enums.dart';
import '../data/models/mail_domain.dart';

/// Everything needed to open an SMTP session, resolved from a [MailDomain].
///
/// The password is deliberately *not* a field here. It is fetched from secure
/// storage at the moment of use and passed as a separate argument, so a config
/// object can be logged, compared or held in state without ever carrying a
/// credential.
class SmtpConfig {
  const SmtpConfig({
    required this.host,
    required this.port,
    required this.security,
    required this.authMode,
    required this.username,
    required this.clientDomain,
    required this.allowInsecureCertificate,
    required this.timeout,
  });

  /// Builds a config from a saved domain.
  factory SmtpConfig.fromDomain(MailDomain domain) => SmtpConfig(
    host: domain.host,
    port: domain.port,
    security: domain.security,
    authMode: domain.authMode,
    username: domain.username,
    clientDomain: domain.domain,
    allowInsecureCertificate: domain.allowInsecureCertificate,
    timeout: Duration(seconds: domain.timeoutSeconds),
  );

  final String host;
  final int port;
  final SmtpSecurity security;
  final SmtpAuthMode authMode;
  final String username;

  /// The domain announced in EHLO. We use the configured sending domain, which
  /// is what a server is most likely to expect from us.
  final String clientDomain;

  final bool allowInsecureCertificate;
  final Duration timeout;

  /// Whether the socket is encrypted from the very first byte.
  bool get isImplicitTls => security == SmtpSecurity.implicitTls;

  bool get needsStartTls => security == SmtpSecurity.starttls;

  bool get needsAuthentication => authMode != SmtpAuthMode.none;
}

/// Default connection timeout when a domain does not specify one.
const int defaultTimeoutSeconds = 30;
