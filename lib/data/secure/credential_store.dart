// Manymail - Many addresses, one app.
// Copyright (C) 2026 Bunny Pranav
// SPDX-License-Identifier: GPL-3.0-or-later
//
// This file is part of Manymail, distributed under the GNU General Public
// License v3 or later. See the LICENSE file at the root of this repository.

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uuid/uuid.dart';

/// The only place SMTP passwords are stored or read.
///
/// Passwords never enter the SQLite database, a log, an error message or a
/// transcript. A `Domains` row holds only a [credentialKeyId] — an opaque UUID
/// — and this class exchanges that for the secret when a connection is about to
/// be opened.
///
/// On Android, `flutter_secure_storage` v11 encrypts values with AES-GCM under
/// a key wrapped by the Android Keystore (RSA-OAEP, API 23+), so the ciphertext
/// is useless without the device's hardware-backed key.
class CredentialStore {
  CredentialStore({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  static const Uuid _uuid = Uuid();

  /// Namespaced so Manymail's entries never collide with another app's.
  static const String _keyPrefix = 'manymail.smtp.password.';

  /// Defaults give AES-GCM storage with an RSA-OAEP Keystore-wrapped key.
  static const AndroidOptions _androidOptions = AndroidOptions();

  static const IOSOptions _iosOptions = IOSOptions(
    accessibility: KeychainAccessibility.first_unlock_this_device,
  );

  /// Mints a handle for a newly configured domain.
  static String newKeyId() => _uuid.v4();

  String _storageKey(String credentialKeyId) => '$_keyPrefix$credentialKeyId';

  /// Stores (or replaces) the password for [credentialKeyId].
  ///
  /// Passing an empty password deletes the entry rather than storing a blank,
  /// so "no password" is represented by absence.
  Future<void> write(String credentialKeyId, String? password) async {
    if (password == null || password.isEmpty) {
      await delete(credentialKeyId);
      return;
    }
    await _storage.write(
      key: _storageKey(credentialKeyId),
      value: password,
      aOptions: _androidOptions,
      iOptions: _iosOptions,
    );
  }

  /// Reads the password, or null when none is stored.
  Future<String?> read(String credentialKeyId) => _storage.read(
    key: _storageKey(credentialKeyId),
    aOptions: _androidOptions,
    iOptions: _iosOptions,
  );

  Future<bool> has(String credentialKeyId) async {
    final value = await read(credentialKeyId);
    return value != null && value.isNotEmpty;
  }

  /// Removes the password. Called when a domain is deleted, so no orphaned
  /// secret outlives the configuration that referenced it.
  Future<void> delete(String credentialKeyId) => _storage.delete(
    key: _storageKey(credentialKeyId),
    aOptions: _androidOptions,
    iOptions: _iosOptions,
  );

  /// Deletes every Manymail credential. Used by "replace" on config import.
  Future<void> deleteAll() async {
    final all = await _storage.readAll(
      aOptions: _androidOptions,
      iOptions: _iosOptions,
    );
    for (final key in all.keys) {
      if (key.startsWith(_keyPrefix)) {
        await _storage.delete(
          key: key,
          aOptions: _androidOptions,
          iOptions: _iosOptions,
        );
      }
    }
  }
}
