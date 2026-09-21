import 'dart:convert';

import 'package:cryptography/cryptography.dart';

import '../setup/initialize_nexabiz_core.dart';

/// Framework-neutral verifier for stored Argon2id credentials.
/// Counterpart to candidate password derivation in [InitializeNexaBizCore].
base class VerifyCoreCredential {
  const VerifyCoreCredential();

  static const int supportedVersion = 19; // Argon2 v1.3 (RFC 9106)
  static const int minMemory = 1024; // 1 MiB in KiB
  static const int maxMemory = 262144; // 256 MiB in KiB
  static const int minIterations = 1;
  static const int maxIterations = 10;
  static const int minParallelism = 1;
  static const int maxParallelism = 8;
  static const int minHashLength = 16;
  static const int maxHashLength = 64;
  static const int minSaltLength = 16;
  static const int maxSaltLength = 64;

  static final _digitRegex = RegExp(r'^[0-9]+$');

  /// Verifies [candidatePassword] against [storedCredential].
  /// Returns `true` if password produces an identical verifier bytes representation.
  Future<bool> call({
    required String candidatePassword,
    required CorePreparedCredential storedCredential,
  }) async {
    if (candidatePassword.isEmpty || storedCredential.verifier.isEmpty) {
      return false;
    }
    if (storedCredential.algorithm != 'argon2id') {
      return false;
    }

    try {
      final paramParts = storedCredential.parameters.split(',');
      if (paramParts.isEmpty) {
        return false;
      }

      final seenKeys = <String>{};
      int? version;
      int? memory;
      int? iterations;
      int? parallelism;
      int? hashLength;

      for (final part in paramParts) {
        if (part.isEmpty) return false;
        final kv = part.split('=');
        if (kv.length != 2) return false;
        final key = kv[0];
        final rawValue = kv[1];

        // Reject unknown keys or whitespace
        if (!const {'v', 'm', 't', 'p', 'l'}.contains(key)) {
          return false;
        }
        // Reject duplicate keys
        if (!seenKeys.add(key)) {
          return false;
        }
        // Strictly non-empty digits only (rejects negative numbers, decimals, letters, whitespace)
        if (!_digitRegex.hasMatch(rawValue)) {
          return false;
        }

        final val = int.tryParse(rawValue);
        if (val == null) return false;

        switch (key) {
          case 'v':
            version = val;
          case 'm':
            memory = val;
          case 't':
            iterations = val;
          case 'p':
            parallelism = val;
          case 'l':
            hashLength = val;
        }
      }

      // Must have all 5 parameters explicitly declared
      if (version == null ||
          memory == null ||
          iterations == null ||
          parallelism == null ||
          hashLength == null) {
        return false;
      }

      // Strict version check
      if (version != supportedVersion) {
        return false;
      }

      // Safe bounds to prevent excessive CPU / memory allocation or invalid parameters
      if (parallelism < minParallelism || parallelism > maxParallelism) {
        return false;
      }
      if (memory < minMemory ||
          memory > maxMemory ||
          memory < 8 * parallelism) {
        return false;
      }
      if (iterations < minIterations || iterations > maxIterations) {
        return false;
      }
      if (hashLength < minHashLength || hashLength > maxHashLength) {
        return false;
      }

      final List<int> salt;
      final List<int> expectedVerifier;
      try {
        salt = base64Decode(storedCredential.salt);
        expectedVerifier = base64Decode(storedCredential.verifier);
      } catch (_) {
        return false;
      }

      if (salt.length < minSaltLength || salt.length > maxSaltLength) {
        return false;
      }
      if (expectedVerifier.length != hashLength) {
        return false;
      }

      final key = await Argon2id(
        memory: memory,
        parallelism: parallelism,
        iterations: iterations,
        hashLength: hashLength,
      ).deriveKeyFromPassword(password: candidatePassword, nonce: salt);

      final derivedBytes = await key.extractBytes();
      if (derivedBytes.length != expectedVerifier.length) {
        return false;
      }

      // Constant-time byte equality check
      var diff = 0;
      for (var i = 0; i < derivedBytes.length; i++) {
        diff |= derivedBytes[i] ^ expectedVerifier[i];
      }
      return diff == 0;
    } catch (_) {
      return false;
    }
  }
}
