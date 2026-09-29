// Manymail - Many addresses, one app.
// Copyright (C) 2026 Bunny Pranav
// SPDX-License-Identifier: GPL-3.0-or-later
//
// This file is part of Manymail, distributed under the GNU General Public
// License v3 or later. See the LICENSE file at the root of this repository.

import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:manymail/features/settings/export_import/config_crypto.dart';

/// The export file is the one artefact that leaves the device carrying SMTP
/// passwords, so these checks matter more than most.
void main() {
  // Argon2 in pure Dart is deliberately slow; give these room.
  const generous = Timeout(Duration(minutes: 3));

  // Cheap parameters keep the suite quick. The real defaults are exercised
  // separately, once.
  const fastMemory = 256;
  const fastIterations = 1;

  Future<Map<String, dynamic>> seal(
    Map<String, dynamic> payload,
    String passphrase,
  ) => ConfigCrypto.encrypt(
    payload: payload,
    passphrase: passphrase,
    memoryKiB: fastMemory,
    iterations: fastIterations,
  );

  final payload = {
    'domains': [
      {
        'label': 'example main',
        'domain': 'example.com',
        'host': 'smtp.example.com',
        'password': 'hunter2000',
      },
    ],
  };

  group('round trip', () {
    test('what goes in comes back out', () async {
      final envelope = await seal(payload, 'correct horse battery staple');
      final opened = await ConfigCrypto.decrypt(
        envelope: envelope,
        passphrase: 'correct horse battery staple',
      );

      expect(opened, equals(payload));
    }, timeout: generous);

    test('survives a trip through a real file', () async {
      final envelope = await seal(payload, 'passphrase');
      // What actually gets written to disk and read back.
      final onDisk = jsonEncode(envelope);
      final reloaded = jsonDecode(onDisk) as Map<String, dynamic>;

      final opened = await ConfigCrypto.decrypt(
        envelope: reloaded,
        passphrase: 'passphrase',
      );
      expect(opened['domains'], isA<List<dynamic>>());
    }, timeout: generous);
  });

  group('the file itself', () {
    test('never contains the plaintext', () async {
      final envelope = await seal(payload, 'passphrase');
      final text = jsonEncode(envelope);

      expect(text, isNot(contains('hunter2000')));
      expect(text, isNot(contains('example.com')));
      expect(text, isNot(contains('smtp')));
    }, timeout: generous);

    test('carries everything needed to reverse the KDF', () async {
      final envelope = await seal(payload, 'passphrase');
      final kdf = envelope['kdf'] as Map<String, dynamic>;

      expect(kdf['algorithm'], 'argon2id');
      expect(kdf['salt'], isNotEmpty);
      expect(kdf['memoryKiB'], fastMemory);
      expect(kdf['iterations'], fastIterations);
      expect(kdf['parallelism'], isNotNull);

      final cipher = envelope['cipher'] as Map<String, dynamic>;
      expect(cipher['algorithm'], 'aes-gcm-256');
      expect(cipher['nonce'], isNotEmpty);
      expect(cipher['mac'], isNotEmpty);
    }, timeout: generous);

    test('uses a fresh salt and nonce every time', () async {
      final first = await seal(payload, 'passphrase');
      final second = await seal(payload, 'passphrase');

      // Identical input and passphrase must not produce identical output.
      expect(
        (first['kdf'] as Map)['salt'],
        isNot((second['kdf'] as Map)['salt']),
      );
      expect(
        (first['cipher'] as Map)['nonce'],
        isNot((second['cipher'] as Map)['nonce']),
      );
      expect(
        (first['cipher'] as Map)['ciphertext'],
        isNot((second['cipher'] as Map)['ciphertext']),
      );
    }, timeout: generous);
  });

  group('refusing bad input', () {
    test('a wrong passphrase is rejected, not guessed at', () async {
      final envelope = await seal(payload, 'right');

      await expectLater(
        ConfigCrypto.decrypt(envelope: envelope, passphrase: 'wrong'),
        throwsA(
          isA<ConfigCryptoException>().having(
            (e) => e.message,
            'message',
            contains('Wrong passphrase'),
          ),
        ),
      );
    }, timeout: generous);

    test('a tampered ciphertext fails to authenticate', () async {
      final envelope = await seal(payload, 'passphrase');
      final cipher = Map<String, dynamic>.from(
        envelope['cipher'] as Map<String, dynamic>,
      );

      // Flip the payload while leaving the MAC alone.
      final bytes = base64Decode(cipher['ciphertext'] as String);
      bytes[0] = bytes[0] ^ 0xFF;
      cipher['ciphertext'] = base64Encode(bytes);

      await expectLater(
        ConfigCrypto.decrypt(
          envelope: {...envelope, 'cipher': cipher},
          passphrase: 'passphrase',
        ),
        throwsA(isA<ConfigCryptoException>()),
      );
    }, timeout: generous);

    test('a file from somewhere else is refused by name', () async {
      await expectLater(
        ConfigCrypto.decrypt(
          envelope: const {'format': 'something.else', 'encrypted': true},
          passphrase: 'passphrase',
        ),
        throwsA(
          isA<ConfigCryptoException>().having(
            (e) => e.message,
            'message',
            contains('not a Manymail configuration file'),
          ),
        ),
      );
    });

    test('an unencrypted file is not treated as encrypted', () async {
      await expectLater(
        ConfigCrypto.decrypt(
          envelope: const {
            'format': ConfigCrypto.formatMarker,
            'encrypted': false,
          },
          passphrase: 'passphrase',
        ),
        throwsA(
          isA<ConfigCryptoException>().having(
            (e) => e.message,
            'message',
            contains('not encrypted'),
          ),
        ),
      );
    });

    test('an empty passphrase is refused up front', () async {
      await expectLater(
        ConfigCrypto.encrypt(payload: payload, passphrase: ''),
        throwsA(isA<ArgumentError>()),
      );
    });
  });

  group('the shipped defaults', () {
    test('OWASP minimum parameters complete in reasonable time', () async {
      final started = DateTime.now();
      final envelope = await ConfigCrypto.encrypt(
        payload: payload,
        passphrase: 'passphrase',
      );
      final opened = await ConfigCrypto.decrypt(
        envelope: envelope,
        passphrase: 'passphrase',
      );
      final elapsed = DateTime.now().difference(started);

      expect(opened, equals(payload));
      expect(ConfigCrypto.defaultMemoryKiB, 19456); // 19 MiB, OWASP floor
      expect(ConfigCrypto.defaultIterations, 2);

      // Not a benchmark — a guard against a change that makes the real
      // defaults unusably slow on a phone.
      // ignore: avoid_print
      print('Argon2id at shipped defaults: ${elapsed.inMilliseconds} ms '
          '(x2 — one derive to seal, one to open)');
    }, timeout: generous);
  });
}
