// Manymail - Many addresses, one app.
// Copyright (C) 2026 Bunny Pranav
// SPDX-License-Identifier: GPL-3.0-or-later
//
// This file is part of Manymail, distributed under the GNU General Public
// License v3 or later. See the LICENSE file at the root of this repository.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/validation/rfc5322.dart';
import '../../data/models/enums.dart';
import '../../data/models/mail_domain.dart';
import '../../data/repositories/domain_repository.dart';
import '../../providers.dart';
import '../../routing/app_router.dart';
import '../../smtp/smtp_config.dart';
import 'test_connection_sheet.dart';

/// Creates or edits a domain.
///
/// "Test connection" works on whatever is currently typed, including unsaved
/// changes, so settings can be proven before they are committed.
class DomainEditorScreen extends ConsumerStatefulWidget {
  const DomainEditorScreen({super.key, this.domainId});

  /// Null when creating a new domain.
  final int? domainId;

  @override
  ConsumerState<DomainEditorScreen> createState() => _DomainEditorScreenState();
}

class _DomainEditorScreenState extends ConsumerState<DomainEditorScreen> {
  final _formKey = GlobalKey<FormState>();

  final _label = TextEditingController();
  final _domain = TextEditingController();
  final _host = TextEditingController();
  final _port = TextEditingController();
  final _username = TextEditingController();
  final _password = TextEditingController();
  final _defaultLocalPart = TextEditingController();
  final _defaultDisplayName = TextEditingController();
  final _defaultReplyTo = TextEditingController();
  final _timeout = TextEditingController(text: '30');

  SmtpSecurity _security = SmtpSecurity.starttls;
  SmtpAuthMode _authMode = SmtpAuthMode.auto;
  bool _allowInsecureCertificate = false;
  bool _isDefault = false;
  bool _showAdvanced = false;

  /// True once the user edits the port themselves, after which changing the
  /// security mode no longer overwrites it.
  bool _portTouched = false;

  /// Existing domain being edited, once loaded.
  MailDomain? _existing;
  bool _loading = true;

  /// Whether the password field should be written on save. Set when the user
  /// types in it, so an untouched field leaves the stored secret alone.
  bool _passwordChanged = false;

  bool get _isNew => widget.domainId == null;

  @override
  void initState() {
    super.initState();
    _port.text = _security.defaultPort.toString();
    _password.addListener(() {
      if (!_passwordChanged) setState(() => _passwordChanged = true);
    });
    _load();
  }

  Future<void> _load() async {
    if (_isNew) {
      setState(() => _loading = false);
      return;
    }
    final domain = await ref
        .read(domainRepositoryProvider)
        .getById(widget.domainId!);
    if (!mounted) return;
    if (domain == null) {
      setState(() => _loading = false);
      return;
    }
    setState(() {
      _existing = domain;
      _label.text = domain.label;
      _domain.text = domain.domain;
      _host.text = domain.host;
      _port.text = domain.port.toString();
      _username.text = domain.username;
      _defaultLocalPart.text = domain.defaultLocalPart ?? '';
      _defaultDisplayName.text = domain.defaultDisplayName ?? '';
      _defaultReplyTo.text = domain.defaultReplyTo ?? '';
      _timeout.text = domain.timeoutSeconds.toString();
      _security = domain.security;
      _authMode = domain.authMode;
      _allowInsecureCertificate = domain.allowInsecureCertificate;
      _isDefault = domain.isDefault;
      _portTouched = domain.port != domain.security.defaultPort;
      _showAdvanced =
          domain.defaultLocalPart != null ||
          domain.defaultDisplayName != null ||
          domain.defaultReplyTo != null ||
          domain.allowInsecureCertificate;
      _passwordChanged = false;
      _loading = false;
    });
  }

  @override
  void dispose() {
    for (final c in [
      _label,
      _domain,
      _host,
      _port,
      _username,
      _password,
      _defaultLocalPart,
      _defaultDisplayName,
      _defaultReplyTo,
      _timeout,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  void _onSecurityChanged(SmtpSecurity? value) {
    if (value == null) return;
    setState(() {
      _security = value;
      // Auto-fill the conventional port unless the user has set their own.
      if (!_portTouched) _port.text = value.defaultPort.toString();
    });
  }

  DomainInput _buildInput() => DomainInput(
    label: _label.text.trim(),
    domain: _domain.text.trim(),
    host: _host.text.trim(),
    port: int.tryParse(_port.text.trim()) ?? _security.defaultPort,
    security: _security,
    authMode: _authMode,
    username: _username.text.trim(),
    allowInsecureCertificate: _allowInsecureCertificate,
    timeoutSeconds: int.tryParse(_timeout.text.trim()) ?? 30,
    defaultLocalPart: _nullIfBlank(_defaultLocalPart.text),
    defaultDisplayName: _nullIfBlank(_defaultDisplayName.text),
    defaultReplyTo: _nullIfBlank(_defaultReplyTo.text),
    isDefault: _isDefault,
  );

  String? _nullIfBlank(String value) =>
      value.trim().isEmpty ? null : value.trim();

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final repository = ref.read(domainRepositoryProvider);
    final input = _buildInput();

    if (_isNew) {
      await repository.create(input, password: _password.text);
    } else {
      await repository.update(
        widget.domainId!,
        input,
        changePassword: _passwordChanged,
        password: _password.text,
      );
    }
    if (mounted) context.pop();
  }

  /// Runs the connection test against the form's current values.
  Future<void> _test() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final input = _buildInput();
    final config = SmtpConfig(
      host: input.host,
      port: input.port,
      security: input.security,
      authMode: input.authMode,
      username: input.username,
      clientDomain: input.domain,
      allowInsecureCertificate: input.allowInsecureCertificate,
      timeout: Duration(seconds: input.timeoutSeconds),
    );

    // Use the typed password when it was entered, otherwise the stored one.
    var password = _password.text;
    if (!_passwordChanged && _existing != null) {
      password =
          await ref.read(domainRepositoryProvider).passwordFor(_existing!) ??
          '';
    }

    if (!mounted) return;
    await showTestConnectionSheet(
      context: context,
      ref: ref,
      config: config,
      password: password,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_isNew ? 'Add domain' : 'Edit domain'),
        actions: [
          if (!_isNew)
            IconButton(
              tooltip: 'Identities',
              icon: const Icon(Icons.badge_outlined),
              onPressed: () => context.push(Routes.presets(widget.domainId!)),
            ),
          TextButton(onPressed: _save, child: const Text('Save')),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
          children: [
            _section('Identity'),
            TextFormField(
              controller: _label,
              decoration: const InputDecoration(
                labelText: 'Label',
                helperText: 'Shown in the composer, e.g. "example main"',
              ),
              textInputAction: TextInputAction.next,
              validator: (v) =>
                  (v ?? '').trim().isEmpty ? 'Give this domain a name' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _domain,
              decoration: const InputDecoration(
                labelText: 'Domain',
                prefixText: '@',
                helperText: 'Used to build the From address',
              ),
              keyboardType: TextInputType.url,
              autocorrect: false,
              textInputAction: TextInputAction.next,
              validator: (v) {
                final value = (v ?? '').trim();
                if (value.isEmpty) return 'Enter a domain';
                if (!isPlausibleDomain(value)) {
                  return 'That does not look like a domain';
                }
                return null;
              },
            ),

            const SizedBox(height: 24),
            _section('SMTP server'),
            TextFormField(
              controller: _host,
              decoration: const InputDecoration(
                labelText: 'Host',
                hintText: 'smtp.example.com',
              ),
              keyboardType: TextInputType.url,
              autocorrect: false,
              textInputAction: TextInputAction.next,
              validator: (v) =>
                  (v ?? '').trim().isEmpty ? 'Enter the SMTP host' : null,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<SmtpSecurity>(
              initialValue: _security,
              decoration: const InputDecoration(labelText: 'Security'),
              items: [
                for (final s in SmtpSecurity.values)
                  DropdownMenuItem(value: s, child: Text(s.label)),
              ],
              onChanged: _onSecurityChanged,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _port,
              decoration: InputDecoration(
                labelText: 'Port',
                helperText: 'Default for ${_security.label}: '
                    '${_security.defaultPort}',
              ),
              keyboardType: TextInputType.number,
              onChanged: (_) => _portTouched = true,
              validator: (v) {
                final port = int.tryParse((v ?? '').trim());
                if (port == null || port < 1 || port > 65535) {
                  return 'Enter a port between 1 and 65535';
                }
                return null;
              },
            ),
            if (_security == SmtpSecurity.none) ...[
              const SizedBox(height: 8),
              const _Warning(
                'This connection is not encrypted. Anything sent over it, '
                'including your password, travels in the clear.',
              ),
            ],

            const SizedBox(height: 24),
            _section('Authentication'),
            Text(
              'These credentials authenticate the connection only. They do not '
              'limit which address you can send from.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<SmtpAuthMode>(
              initialValue: _authMode,
              decoration: const InputDecoration(labelText: 'Method'),
              items: [
                for (final a in SmtpAuthMode.values)
                  DropdownMenuItem(value: a, child: Text(a.label)),
              ],
              onChanged: (v) => setState(() => _authMode = v ?? _authMode),
            ),
            if (_authMode != SmtpAuthMode.none) ...[
              const SizedBox(height: 12),
              TextFormField(
                controller: _username,
                decoration: const InputDecoration(labelText: 'Username'),
                autocorrect: false,
                autofillHints: const [AutofillHints.username],
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _password,
                decoration: InputDecoration(
                  labelText: 'Password',
                  helperText: _isNew
                      ? 'Stored in the Android Keystore, never in the database'
                      : (_passwordChanged
                            ? 'Will be replaced on save'
                            : 'Leave blank to keep the saved password'),
                ),
                obscureText: true,
                autocorrect: false,
                enableSuggestions: false,
              ),
            ],

            const SizedBox(height: 24),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: _isDefault,
              onChanged: (v) => setState(() => _isDefault = v),
              title: const Text('Default domain'),
              subtitle: const Text('Preselected when writing a message'),
            ),

            const SizedBox(height: 8),
            _AdvancedSection(
              expanded: _showAdvanced,
              onToggle: () => setState(() => _showAdvanced = !_showAdvanced),
              children: [
                TextFormField(
                  controller: _defaultLocalPart,
                  decoration: const InputDecoration(
                    labelText: 'Default alias',
                    helperText:
                        'Prefilled into the composer; always editable there',
                  ),
                  autocorrect: false,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _defaultDisplayName,
                  decoration: const InputDecoration(
                    labelText: 'Default display name',
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _defaultReplyTo,
                  decoration: const InputDecoration(
                    labelText: 'Default Reply-To',
                  ),
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: false,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _timeout,
                  decoration: const InputDecoration(
                    labelText: 'Connection timeout (seconds)',
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _allowInsecureCertificate,
                  onChanged: (v) =>
                      setState(() => _allowInsecureCertificate = v),
                  title: const Text('Allow invalid certificates'),
                  subtitle: const Text(
                    'Accepts expired, self-signed or mismatched certificates. '
                    'This removes the protection TLS provides against an '
                    'intercepted connection.',
                  ),
                ),
                if (_allowInsecureCertificate)
                  const _Warning(
                    'With this on, the app cannot tell the real server from '
                    'one impersonating it.',
                  ),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _test,
        icon: const Icon(Icons.network_check),
        label: const Text('Test connection'),
      ),
    );
  }

  Widget _section(String title) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      title,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
        color: Theme.of(context).colorScheme.primary,
      ),
    ),
  );
}

class _AdvancedSection extends StatelessWidget {
  const _AdvancedSection({
    required this.expanded,
    required this.onToggle,
    required this.children,
  });

  final bool expanded;
  final VoidCallback onToggle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      TextButton.icon(
        onPressed: onToggle,
        icon: Icon(expanded ? Icons.expand_less : Icons.expand_more),
        label: const Text('Advanced'),
      ),
      if (expanded) ...children,
    ],
  );
}

class _Warning extends StatelessWidget {
  const _Warning(this.message);

  final String message;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.errorContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.warning_amber, color: scheme.onErrorContainer, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: scheme.onErrorContainer),
            ),
          ),
        ],
      ),
    );
  }
}
