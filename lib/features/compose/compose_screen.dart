// Manymail - Many addresses, one app.
// Copyright (C) 2026 Bunny Pranav
// SPDX-License-Identifier: GPL-3.0-or-later
//
// This file is part of Manymail, distributed under the GNU General Public
// License v3 or later. See the LICENSE file at the root of this repository.

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/rich_text/body_converter.dart';
import '../../data/models/app_settings.dart';
import '../../data/models/mail_domain.dart';
import '../../data/models/message_attachment.dart';
import '../../data/models/outgoing_message.dart';
import '../../data/share_intake.dart';
import '../../providers.dart';
import '../../routing/app_router.dart';
import 'widgets/attachment_list.dart';
import 'widgets/custom_headers_editor.dart';
import 'widgets/from_row.dart';
import 'widgets/recipient_field.dart';
import 'widgets/rich_body_editor.dart';
import 'widgets/send_result_sheet.dart';

/// The composer — the app's home screen.
///
/// Compose state lives here rather than in a provider: it belongs to this
/// screen, and keeping it local makes the autosave lifecycle (debounce, app
/// backgrounding, navigating away) easy to reason about.
class ComposeScreen extends ConsumerStatefulWidget {
  const ComposeScreen({super.key, this.draftId});

  /// Set when reopening an existing draft or outbox entry.
  final int? draftId;

  @override
  ConsumerState<ComposeScreen> createState() => _ComposeScreenState();
}

class _ComposeScreenState extends ConsumerState<ComposeScreen>
    with WidgetsBindingObserver {
  final _localPart = TextEditingController();
  final _displayName = TextEditingController();
  final _subject = TextEditingController();
  final _plainBody = TextEditingController();
  final _replyTo = TextEditingController();

  late final QuillController _quill = QuillController.basic();
  final FocusNode _quillFocus = FocusNode();

  OutgoingMessage? _message;
  List<MessageAttachment> _attachments = const [];

  bool _loading = true;
  bool _sending = false;
  bool _showCcBcc = false;
  bool _showAdvanced = false;

  /// Debounces autosave so every keystroke is not a database write.
  Timer? _autosaveTimer;

  /// Set once the message is sent or explicitly discarded, so the autosave on
  /// dispose does not resurrect it as a draft.
  bool _finished = false;

  /// Live share-sheet intents, while this screen is open.
  StreamSubscription<SharedContent>? _shareSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _quill.addListener(_scheduleAutosave);
    _load();
    _listenForShares();
  }

  /// Accepts content shared from other apps.
  ///
  /// A share that arrived while the app was closed is picked up once; anything
  /// shared afterwards arrives on the stream.
  void _listenForShares() {
    // Only the composer for a brand-new message takes shares, so sharing into
    // the app cannot silently alter a draft being edited.
    if (widget.draftId != null) return;

    final intake = ref.read(shareIntakeProvider);
    _shareSubscription = intake.stream().listen(_acceptShared);
    unawaited(
      intake.initial().then((content) {
        if (content != null && !content.isEmpty) _acceptShared(content);
      }),
    );
  }

  Future<void> _acceptShared(SharedContent content) async {
    if (!mounted || content.isEmpty) return;

    final text = content.text;
    if (text != null && text.trim().isNotEmpty) {
      // Shared text becomes the body, appended so nothing already typed is
      // overwritten.
      if (_message?.isHtml ?? true) {
        _quill.document.insert(_quill.document.length - 1, text);
      } else {
        _plainBody.text = _plainBody.text.isEmpty
            ? text
            : [_plainBody.text, text].join('\n');
      }
    }

    if (content.files.isNotEmpty) {
      final messageId = await _ensureSaved();
      if (messageId != null) {
        final repository = ref.read(attachmentRepositoryProvider);
        for (final file in content.files) {
          await repository.add(messageId: messageId, source: file);
        }
        await _reloadAttachments(messageId);
      }
    }

    await ref.read(shareIntakeProvider).markHandled();
    if (mounted) {
      _snack(
        content.files.isEmpty
            ? 'Shared text added'
            : 'Added ${content.files.length} shared file'
                  '${content.files.length == 1 ? '' : 's'}',
      );
    }
    _scheduleAutosave();
  }

  Future<void> _load() async {
    OutgoingMessage? message;
    if (widget.draftId != null) {
      message = await ref
          .read(messageRepositoryProvider)
          .getById(widget.draftId!);
    }
    final settings = await ref.read(settingsRepositoryProvider).get();
    message ??= _seedNewMessage(
      await ref.read(domainRepositoryProvider).getDefault(),
      settings,
    );

    if (!mounted) return;
    final loaded = message;
    setState(() {
      _message = loaded;
      _localPart.text = loaded.localPart;
      _displayName.text = loaded.displayName;
      _subject.text = loaded.subject;
      _plainBody.text = loaded.bodyPlain;
      _replyTo.text = loaded.replyTo ?? '';
      _showCcBcc = loaded.cc.isNotEmpty || loaded.bcc.isNotEmpty;
      _showAdvanced =
          loaded.customHeaders.isNotEmpty || (loaded.replyTo?.isNotEmpty ?? false);
      _loading = false;
    });

    _restoreRichDocument(loaded);
    if (loaded.id != null) await _reloadAttachments(loaded.id!);
  }

  /// A blank message carrying the configured defaults.
  ///
  /// The signature is placed in the body rather than appended at send time, so
  /// it is visible and editable like any other text.
  OutgoingMessage _seedNewMessage(MailDomain? domain, AppSettings settings) {
    final blank = OutgoingMessage.blank(
      domain: domain,
      isHtml: settings.composeHtmlByDefault,
    );
    final signature = settings.defaultSignature;
    if (signature == null || signature.trim().isEmpty) return blank;

    // Two blank lines above it, the usual convention.
    final spaced = ['', '', signature].join('\n');
    if (!blank.isHtml) return blank.copyWith(bodyPlain: spaced);
    _quill.document.insert(0, spaced);
    return blank;
  }

  /// Rebuilds the editor document from the saved Delta, so reopening a draft
  /// gets its formatting back rather than a flattened copy.
  void _restoreRichDocument(OutgoingMessage message) {
    final json = message.bodyDeltaJson;
    if (json == null || json.isEmpty) return;
    try {
      final decoded = jsonDecode(json);
      if (decoded is! List) return;
      _quill.document = Document.fromJson(decoded);
    } catch (_) {
      // A corrupt document must not block editing; the plain text is still
      // there and the user can carry on.
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _autosaveTimer?.cancel();
    unawaited(_shareSubscription?.cancel());
    _quill.removeListener(_scheduleAutosave);
    // Navigating away must not lose work.
    unawaited(_persistDraft());
    _quill.dispose();
    _quillFocus.dispose();
    for (final c in [
      _localPart,
      _displayName,
      _subject,
      _plainBody,
      _replyTo,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Backgrounding the app is the other way work gets lost.
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      unawaited(_persistDraft());
    }
  }

  // --------------------------------------------------------------- mutation

  void _update(OutgoingMessage Function(OutgoingMessage) change) {
    final current = _message;
    if (current == null) return;
    setState(() => _message = change(current));
    _scheduleAutosave();
  }

  void _scheduleAutosave() {
    _autosaveTimer?.cancel();
    _autosaveTimer = Timer(
      const Duration(milliseconds: 900),
      () => unawaited(_persistDraft()),
    );
  }

  /// Folds the editor's current content into the message.
  ///
  /// In rich mode both bodies are produced: HTML for clients that render it,
  /// and a plain-text alternative derived from the same document. In plain
  /// mode only the plain body exists, and `bodyHtml` is cleared so no
  /// `text/html` part can be built from a stale value.
  OutgoingMessage _withBody(OutgoingMessage message) {
    if (!message.isHtml) {
      return message.copyWith(bodyPlain: _plainBody.text, bodyHtml: null);
    }
    final ops = _quill.document.toDelta().toJson().cast<Map<String, dynamic>>();
    return message.copyWith(
      bodyDeltaJson: jsonEncode(ops),
      bodyHtml: BodyConverter.isEmpty(ops) ? null : BodyConverter.toHtml(ops),
      bodyPlain: BodyConverter.toPlainText(ops),
    );
  }

  /// Writes the in-progress message to the drafts table.
  Future<void> _persistDraft() async {
    final message = _message;
    if (message == null || _finished) return;
    if (message.status != MessageStatus.draft) return;

    final withBody = _withBody(message);
    if (!withBody.hasContent) return;

    final saved = await ref
        .read(messageRepositoryProvider)
        .save(withBody.copyWith(updatedAt: DateTime.now()));
    if (mounted && _message?.id == null) {
      setState(() => _message = withBody.copyWith(id: saved));
    }
  }

  /// Returns the message's row id, saving it first if it does not have one.
  ///
  /// Attachments are stored against a message id, so a brand-new message has
  /// to become a real draft before anything can be attached to it.
  Future<int?> _ensureSaved() async {
    final message = _message;
    if (message == null) return null;
    if (message.id != null) return message.id;

    final id = await ref
        .read(messageRepositoryProvider)
        .save(_withBody(message).copyWith(updatedAt: DateTime.now()));
    if (mounted) setState(() => _message = _message!.copyWith(id: id));
    return id;
  }

  Future<void> _reloadAttachments(int messageId) async {
    final loaded = await ref
        .read(attachmentRepositoryProvider)
        .forMessage(messageId);
    if (mounted) setState(() => _attachments = loaded);
  }

  void _applyPreset(IdentityPreset preset) {
    _localPart.text = preset.localPart;
    _displayName.text = preset.displayName;
    if (preset.replyTo != null) _replyTo.text = preset.replyTo!;
    _update(
      (m) => m.copyWith(
        localPart: preset.localPart,
        displayName: preset.displayName,
        replyTo: preset.replyTo ?? m.replyTo,
      ),
    );
  }

  void _selectDomain(MailDomain domain) {
    // Switching domain keeps whatever identity was typed; it only fills blanks.
    _update((m) {
      var next = m.withDomain(domain);
      if (next.localPart.isEmpty &&
          (domain.defaultLocalPart?.isNotEmpty ?? false)) {
        _localPart.text = domain.defaultLocalPart!;
        next = next.copyWith(localPart: domain.defaultLocalPart);
      }
      if (next.displayName.isEmpty &&
          (domain.defaultDisplayName?.isNotEmpty ?? false)) {
        _displayName.text = domain.defaultDisplayName!;
        next = next.copyWith(displayName: domain.defaultDisplayName);
      }
      return next;
    });
  }

  // ----------------------------------------------------------- body mode

  /// Switches between rich and plain, warning before anything is lost.
  Future<void> _toggleMode(bool rich) async {
    final message = _message;
    if (message == null || message.isHtml == rich) return;

    if (!rich) {
      final ops = _quill.document
          .toDelta()
          .toJson()
          .cast<Map<String, dynamic>>();
      final hasFormatting = ops.any(
        (op) => op['attributes'] != null || op['insert'] is! String,
      );
      if (hasFormatting) {
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Switch to plain text?'),
            content: const Text(
              'Formatting, links and inline images will be dropped. The text '
              'itself is kept.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Switch'),
              ),
            ],
          ),
        );
        if (!(confirmed ?? false)) return;
      }
      // Carry the text across so switching does not start from nothing.
      _plainBody.text = BodyConverter.toPlainText(ops);
    } else if (_plainBody.text.isNotEmpty &&
        _quill.document.toPlainText().trim().isEmpty) {
      _quill.document = Document()..insert(0, _plainBody.text);
    }

    _update((m) => m.copyWith(isHtml: rich));
  }

  // ----------------------------------------------------------- attachments

  Future<void> _pickFiles() async {
    final messageId = await _ensureSaved();
    if (messageId == null) return;

    final picked = await FilePicker.pickFiles(
      dialogTitle: 'Attach files',
    );
    if (picked.isEmpty) return;

    final repository = ref.read(attachmentRepositoryProvider);
    for (final file in picked) {
      final path = file.path;
      if (path == null) continue;
      await repository.add(
        messageId: messageId,
        source: File(path),
        fileName: file.name,
      );
    }
    await _reloadAttachments(messageId);
    _scheduleAutosave();
  }

  /// Attaches an image and drops a `cid:` reference into the body, so it shows
  /// where it was inserted rather than as a trailing attachment.
  Future<void> _insertInlineImage() async {
    final messageId = await _ensureSaved();
    if (messageId == null) return;

    final picked = await FilePicker.pickFile(
      dialogTitle: 'Insert image',
      type: FileType.image,
    );
    final path = picked?.path;
    if (path == null) return;

    final attachment = await ref
        .read(attachmentRepositoryProvider)
        .add(
          messageId: messageId,
          source: File(path),
          fileName: picked!.name,
          inline: true,
        );

    final index = _quill.selection.baseOffset.clamp(
      0,
      _quill.document.length - 1,
    );
    _quill.document.insert(
      index,
      BlockEmbed.image('cid:${attachment.contentId}'),
    );

    await _reloadAttachments(messageId);
    _scheduleAutosave();
  }

  Future<void> _removeAttachment(MessageAttachment attachment) async {
    await ref.read(attachmentRepositoryProvider).remove(attachment);
    final messageId = _message?.id;
    if (messageId != null) await _reloadAttachments(messageId);
  }

  // ------------------------------------------------------------------ actions

  Future<void> _send() async {
    final message = _message;
    if (message == null || _sending) return;

    if (message.domainId == null) {
      _snack('Choose a domain to send from.');
      return;
    }
    if (!message.hasRecipients) {
      _snack('Add at least one recipient.');
      return;
    }

    setState(() => _sending = true);
    final result = await ref
        .read(sendCoordinatorProvider)
        .send(_withBody(message));

    if (!mounted) return;
    setState(() {
      _sending = false;
      _message = result.message;
      _finished = result.outcome.success;
    });

    await showSendResultSheet(
      context: context,
      outcome: result.outcome,
      onDone: () {
        if (!mounted) return;
        if (result.outcome.success) context.go(Routes.sent);
      },
      onKeepInOutbox: result.outcome.isRetryable
          ? () {
              _finished = true;
              if (mounted) context.go(Routes.outbox);
            }
          : null,
    );
  }

  Future<void> _saveDraft() async {
    await _persistDraft();
    if (!mounted) return;
    _finished = true;
    _snack('Saved to drafts');
    context.go(Routes.drafts);
  }

  Future<void> _discard() async {
    final message = _message;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Discard this message?'),
        content: const Text('It will not be saved.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Discard'),
          ),
        ],
      ),
    );
    if (!(confirmed ?? false)) return;

    _finished = true;
    if (message?.id != null) {
      await ref.read(messageRepositoryProvider).delete(message!.id!);
    }
    if (mounted) context.go(Routes.compose);
  }

  void _snack(String text) => ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(text)));

  // -------------------------------------------------------------------- view

  @override
  Widget build(BuildContext context) {
    final domainsAsync = ref.watch(domainsProvider);
    final message = _message;

    if (_loading || message == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final domains = domainsAsync.value ?? const <MailDomain>[];
    final selected = domains
        .where((d) => d.id == message.domainId)
        .firstOrNull;

    return Scaffold(
      appBar: AppBar(
        title: const Text('New message'),
        actions: [
          IconButton(
            tooltip: 'Save as draft',
            icon: const Icon(Icons.save_outlined),
            onPressed: _saveDraft,
          ),
          IconButton(
            tooltip: 'Discard',
            icon: const Icon(Icons.delete_outline),
            onPressed: _discard,
          ),
        ],
      ),
      body: domains.isEmpty
          ? const _NoDomains()
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
              children: [
                FromRow(
                  domains: domains,
                  selectedDomain: selected,
                  localPart: message.localPart,
                  displayName: message.displayName,
                  localPartController: _localPart,
                  displayNameController: _displayName,
                  onDomainChanged: _selectDomain,
                  onLocalPartChanged: (v) =>
                      _update((m) => m.copyWith(localPart: v)),
                  onDisplayNameChanged: (v) =>
                      _update((m) => m.copyWith(displayName: v)),
                  onPresetSelected: _applyPreset,
                ),

                const SizedBox(height: 20),
                RecipientField(
                  label: 'To',
                  addresses: message.to,
                  onChanged: (v) => _update((m) => m.copyWith(to: v)),
                  trailing: TextButton(
                    onPressed: () => setState(() => _showCcBcc = !_showCcBcc),
                    child: Text(_showCcBcc ? 'Hide Cc/Bcc' : 'Cc/Bcc'),
                  ),
                ),
                if (_showCcBcc) ...[
                  RecipientField(
                    label: 'Cc',
                    addresses: message.cc,
                    onChanged: (v) => _update((m) => m.copyWith(cc: v)),
                  ),
                  RecipientField(
                    label: 'Bcc',
                    addresses: message.bcc,
                    onChanged: (v) => _update((m) => m.copyWith(bcc: v)),
                  ),
                ],

                TextField(
                  controller: _subject,
                  decoration: const InputDecoration(
                    labelText: 'Subject',
                    border: InputBorder.none,
                  ),
                  textCapitalization: TextCapitalization.sentences,
                  onChanged: (v) => _update((m) => m.copyWith(subject: v)),
                ),
                const Divider(height: 16),

                RichBodyEditor(
                  isHtml: message.isHtml,
                  quillController: _quill,
                  plainController: _plainBody,
                  quillFocusNode: _quillFocus,
                  onToggleMode: _toggleMode,
                  // Inline images are stored as cid: references; the editor
                  // needs the attachments to resolve them back to files.
                  attachments: _attachments,
                ),

                const SizedBox(height: 16),
                AttachmentList(
                  attachments: _attachments,
                  warnAboveBytes: ref
                          .watch(settingsProvider)
                          .value
                          ?.attachmentWarnBytes ??
                      AppSettings.defaultAttachmentWarnBytes,
                  allowInlineImages: message.isHtml,
                  onAddFiles: _pickFiles,
                  onAddInlineImage: _insertInlineImage,
                  onRemove: _removeAttachment,
                ),

                const SizedBox(height: 8),
                _Advanced(
                  expanded: _showAdvanced,
                  onToggle: () =>
                      setState(() => _showAdvanced = !_showAdvanced),
                  children: [
                    TextField(
                      controller: _replyTo,
                      decoration: const InputDecoration(
                        labelText: 'Reply-To',
                        helperText: 'Where replies should go instead',
                      ),
                      keyboardType: TextInputType.emailAddress,
                      autocorrect: false,
                      onChanged: (v) => _update(
                        (m) => m.copyWith(replyTo: v.trim().isEmpty ? null : v),
                      ),
                    ),
                    const SizedBox(height: 16),
                    CustomHeadersEditor(
                      headers: message.customHeaders,
                      onChanged: (headers) =>
                          _update((m) => m.copyWith(customHeaders: headers)),
                    ),
                  ],
                ),
              ],
            ),
      floatingActionButton: domains.isEmpty
          ? null
          : FloatingActionButton.extended(
              onPressed: _sending ? null : _send,
              icon: _sending
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.send),
              label: Text(_sending ? 'Sending…' : 'Send'),
            ),
    );
  }
}

class _Advanced extends StatelessWidget {
  const _Advanced({
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
        label: const Text('Reply-To and custom headers'),
      ),
      if (expanded) ...children,
    ],
  );
}

class _NoDomains extends StatelessWidget {
  const _NoDomains();

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.dns_outlined, size: 56),
          const SizedBox(height: 16),
          Text(
            'No domains configured',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          const Text(
            'Add a domain and its SMTP server before writing a message.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () => context.go(Routes.domains),
            icon: const Icon(Icons.add),
            label: const Text('Add domain'),
          ),
        ],
      ),
    ),
  );
}
