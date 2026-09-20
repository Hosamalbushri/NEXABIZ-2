import 'dart:convert';

import 'package:cryptography/cryptography.dart';

import '../setup/initialize_nexabiz_core.dart';

/// Framework-neutral verifier for stored Argon2id credentials.
/// Counterpart to candidate password derivation in [InitializeNexaBizCore].
final class VerifyCoreCredential {
  const VerifyCoreCredential();

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
      final salt = base64Decode(storedCredential.salt);
      final expectedVerifier = base64Decode(storedCredential.verifier);
      
      // Parse parameters e.g., 'v=19,m=19456,t=2,p=1,l=32'
      var memory = 19456;
      var iterations = 2;
      var parallelism = 1;
      var hashLength = 32;

      final parts = storedCredential.parameters.split(',');
      for (final part in parts) {
        final kv = part.split('=');
        if (kv.length == 2) {
          final k = kv[0].trim();
          final v = int.tryParse(kv[1].trim());
          if (v != null) {
            if (k == 'm') memory = v;
            if (k == 't') iterations = v;
            if (k == 'p') parallelism = v;
            if (k == 'l') hashLength = v;
          }
        }
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
