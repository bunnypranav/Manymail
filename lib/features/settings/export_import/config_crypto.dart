// Manymail - Many addresses, one app.
// Copyright (C) 2026 Bunny Pranav
// SPDX-License-Identifier: GPL-3.0-or-later
//
// This file is part of Manymail, distributed under the GNU General Public
// License v3 or later. See the LICENSE file at the root of this repository.

import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

/// Encrypts and decrypts the configuration export file.
///
/// The passphrase is stretched with Argon2id and the payload sealed with
/// AES-GCM-256. Every parameter needed to reverse that — salt, nonce, and the
/// KDF cost settings — is written into the file itself, so a file exported
/// today still opens after the defaults here are tuned.
///
/// AES-GCM is authenticated, so a file that has been altered fails to decrypt
/// rather than yielding plausible-looking rubbish.
abstract final class ConfigCrypto {
  /// Identifies our files and guards against opening something else entirely.
  static const String formatMarker = 'manymail.config';
  static const int formatVersion = 1;

  /// OWASP's minimum Argon2id parameters: 19 MiB, 2 iterations, 1 lane.
  ///
  /// Argon2 here is pure Dart, so memory cost is what a phone feels most.
  /// These are the floor rather than the ideal, chosen so an import on a
  /// mid-range phone takes seconds and not a minute.
  static const int defaultMemoryKiB = 19456;
  static const int defaultIterations = 2;
  static const int defaultParallelism = 1;
  static const int keyLengthBytes = 32;

  static const int _saltBytes = 16;
  static const int _nonceBytes = 12;

  /// Seals [payload] under [passphrase], returning the file's JSON.
  static Future<Map<String, dynamic>> encrypt({
    required Map<String, dynamic> payload,
    required String passphrase,
    int memoryKiB = defaultMemoryKiB,
    int iterations = defaultIterations,
    int parallelism = defaultParallelism,
    Random? random,
  }) async {
    if (passphrase.isEmpty) {
      throw ArgumentError('A passphrase is required to encrypt the export.');
    }

    final salt = _randomBytes(_saltBytes, random);
    final nonce = _randomBytes(_nonceBytes, random);

    final key = await _deriveKey(
      passphrase: passphrase,
      salt: salt,
      memoryKiB: memoryKiB,
      iterations: iterations,
      parallelism: parallelism,
    );

    final box = await AesGcm.with256bits().encrypt(
      utf8.encode(jsonEncode(payload)),
      secretKey: key,
      nonce: nonce,
    );

    return {
      'format': formatMarker,
      'version': formatVersion,
      'encrypted': true,
      'kdf': {
        'algorithm': 'argon2id',
        'memoryKiB': memoryKiB,
        'iterations': iterations,
        'parallelism': parallelism,
        'hashLength': keyLengthBytes,
        'salt': base64Encode(salt),
      },
      'cipher': {
        'algorithm': 'aes-gcm-256',
        'nonce': base64Encode(box.nonce),
        'ciphertext': base64Encode(box.cipherText),
        'mac': base64Encode(box.mac.bytes),
      },
    };
  }

  /// Opens a sealed file.
  ///
  /// Throws [ConfigCryptoException] when the file is not ours, is malformed,
  /// or the passphrase is wrong — the last two are indistinguishable by
  /// design, since AES-GCM only reports "this did not authenticate".
  static Future<Map<String, dynamic>> decrypt({
    required Map<String, dynamic> envelope,
    required String passphrase,
  }) async {
    if (envelope['format'] != formatMarker) {
      throw const ConfigCryptoException(
        'This is not a Manymail configuration file.',
      );
    }
    if (envelope['encrypted'] != true) {
      throw const ConfigCryptoException(
        'This file is not encrypted, so it has no passphrase.',
      );
    }

    final kdf = envelope['kdf'];
    final cipher = envelope['cipher'];
    if (kdf is! Map || cipher is! Map) {
      throw const ConfigCryptoException('The file is missing its header.');
    }

    try {
      final key = await _deriveKey(
        passphrase: passphrase,
        salt: base64Decode(kdf['salt'] as String),
        // Read the cost from the file, not from today's defaults, so an older
        // export still opens.
        memoryKiB: kdf['memoryKiB'] as int? ?? defaultMemoryKiB,
        iterations: kdf['iterations'] as int? ?? defaultIterations,
        parallelism: kdf['parallelism'] as int? ?? defaultParallelism,
      );

      final plaintext = await AesGcm.with256bits().decrypt(
        SecretBox(
          base64Decode(cipher['ciphertext'] as String),
          nonce: base64Decode(cipher['nonce'] as String),
          mac: Mac(base64Decode(cipher['mac'] as String)),
        ),
        secretKey: key,
      );

      final decoded = jsonDecode(utf8.decode(plaintext));
      if (decoded is! Map<String, dynamic>) {
        throw const ConfigCryptoException('The file contents are malformed.');
      }
      return decoded;
    } on SecretBoxAuthenticationError {
      throw const ConfigCryptoException(
        'Wrong passphrase, or the file has been altered since it was '
        'exported.',
      );
    } on ConfigCryptoException {
      rethrow;
    } catch (error) {
      throw ConfigCryptoException('The file could not be read: $error');
    }
  }

  static Future<SecretKey> _deriveKey({
    required String passphrase,
    required List<int> salt,
    required int memoryKiB,
    required int iterations,
    required int parallelism,
  }) {
    final argon2 = Argon2id(
      memory: memoryKiB,
      iterations: iterations,
      parallelism: parallelism,
      hashLength: keyLengthBytes,
    );
    return argon2.deriveKey(
      secretKey: SecretKey(utf8.encode(passphrase)),
      nonce: salt,
    );
  }

  static Uint8List _randomBytes(int length, Random? random) {
    // Random.secure() is the right source; an injected Random exists only so
    // tests can be deterministic.
    final source = random ?? Random.secure();
    return Uint8List.fromList(
      List<int>.generate(length, (_) => source.nextInt(256)),
    );
  }
}

/// A configuration file that could not be read.
class ConfigCryptoException implements Exception {
  const ConfigCryptoException(this.message);

  final String message;

  @override
  String toString() => message;
}
