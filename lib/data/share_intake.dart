// Manymail - Many addresses, one app.
// Copyright (C) 2026 Bunny Pranav
// SPDX-License-Identifier: GPL-3.0-or-later
//
// This file is part of Manymail, distributed under the GNU General Public
// License v3 or later. See the LICENSE file at the root of this repository.

import 'dart:async';
import 'dart:io';

import 'package:receive_sharing_intent/receive_sharing_intent.dart';

/// Something shared into Manymail from another app.
class SharedContent {
  const SharedContent({this.files = const [], this.text});

  /// Files to attach.
  final List<File> files;

  /// Text shared instead of (or alongside) files, used as the body.
  final String? text;

  bool get isEmpty => files.isEmpty && (text?.trim().isEmpty ?? true);
}

/// Receives share-sheet intents.
///
/// Android hands shared files over as paths in a temporary cache directory,
/// which it is free to clear. The attachment repository copies them into app
/// storage immediately, so a draft that sits overnight still has its files.
class ShareIntake {
  ShareIntake({ReceiveSharingIntent? intent})
    : _intent = intent ?? ReceiveSharingIntent.instance;

  final ReceiveSharingIntent _intent;

  /// Content shared while the app was not running.
  Future<SharedContent?> initial() async {
    try {
      final media = await _intent.getInitialMedia();
      return _toContent(media);
    } catch (_) {
      // A share that cannot be read is not worth crashing the app over.
      return null;
    }
  }

  /// Content shared while the app is already open.
  Stream<SharedContent> stream() =>
      _intent.getMediaStream().map(_toContent).where((c) => !c.isEmpty);

  /// Tells the platform the share has been consumed, so reopening the app
  /// does not attach the same files again.
  Future<void> markHandled() async {
    try {
      await _intent.reset();
    } catch (_) {
      // Nothing useful to do if the platform refuses.
    }
  }

  SharedContent _toContent(List<SharedMediaFile> media) {
    final files = <File>[];
    final texts = <String>[];

    for (final item in media) {
      if (item.type == SharedMediaType.text ||
          item.type == SharedMediaType.url) {
        // For text and URL shares the "path" is the content itself.
        texts.add(item.path);
        continue;
      }
      final file = File(item.path);
      if (file.existsSync()) files.add(file);
    }

    return SharedContent(
      files: files,
      text: texts.isEmpty ? null : texts.join('\n'),
    );
  }
}
