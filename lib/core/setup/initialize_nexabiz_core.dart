import 'dart:convert';
import 'dart:math';

import 'package:cryptography/cryptography.dart';

import '../identity/core_uuid.dart';
import 'nexabiz_core_installation_store.dart';
import 'nexabiz_setup_readiness.dart';

enum CoreInitializationFailure {
  invalidInput,
  alreadyInitialized,
  recoveryRequired,
  credentialFailure,
  storageFailure,
}

/// Deliberately excludes raw input and underlying storage errors.
final class CoreInitializationException implements Exception {
  const CoreInitializationException(this.failure);
  final CoreInitializationFailure failure;

  @override
  String toString() => 'CoreInitializationException($failure)';
}

final class CoreInitializationInput {
  const CoreInitializationInput({
    required this.companyCode,
    required this.companyName,
    required this.adminName,
    required this.adminEmail,
    required this.password,
  });

  final String companyCode;
  final String companyName;
  final String adminName;
  final String adminEmail;
  final String password;
}

/// Versioned, non-reversible credential material. The raw password is absent.
final class CorePreparedCredential {
  const CorePreparedCredential({
    required this.algorithm,
    required this.parameters,
    required this.salt,
    required this.verifier,
  });

  final String algorithm;
  final String parameters;
  final String salt;
  final String verifier;
}

final class CoreInitializationRecords {
  const CoreInitializationRecords({
    required this.companyId,
    required this.companyCode,
    required this.companyName,
    required this.userId,
    required this.adminName,
    required this.adminEmail,
    required this.membershipId,
    required this.createdAt,
    required this.credential,
  });

  final String companyId;
  final String companyCode;
  final String companyName;
  final String userId;
  final String adminName;
  final String adminEmail;
  final String membershipId;
  final DateTime createdAt;
  final CorePreparedCredential credential;
}

/// Adapts the legacy tenant/admin creation workflow to one Core authority.
final class InitializeNexaBizCore {
  const InitializeNexaBizCore(this._store);
  final NexaBizCoreInstallationStore _store;

  Future<NexaBizSetupReadiness> call(CoreInitializationInput input) async {
    final companyCode = input.companyCode.trim().toUpperCase();
    final companyName = input.companyName.trim();
    final adminName = input.adminName.trim();
    final adminEmail = input.adminEmail.trim().toLowerCase();
    if (companyCode.isEmpty ||
        companyCode.length > 32 ||
        !RegExp(r'^[A-Z0-9_\-]+$').hasMatch(companyCode) ||
        companyName.isEmpty ||
        adminName.isEmpty ||
        !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(adminEmail) ||
        input.password.length < 12) {
      throw const CoreInitializationException(
        CoreInitializationFailure.invalidInput,
      );
    }

    late final NexaBizSetupReadiness before;
    try {
      before = await _store.readReadiness();
    } catch (_) {
      throw const CoreInitializationException(
        CoreInitializationFailure.storageFailure,
      );
    }
    if (before.isReady) {
      throw const CoreInitializationException(
        CoreInitializationFailure.alreadyInitialized,
      );
    }
    if (before.state != NexaBizSetupState.uninitialized) {
      throw const CoreInitializationException(
        CoreInitializationFailure.recoveryRequired,
      );
    }

    late final CorePreparedCredential credential;
    try {
      final random = Random.secure();
      final salt = List<int>.generate(16, (_) => random.nextInt(256));
      final key = await Argon2id(
        memory: 19456,
        parallelism: 1,
        iterations: 2,
        hashLength: 32,
      ).deriveKeyFromPassword(password: input.password, nonce: salt);
      credential = CorePreparedCredential(
        algorithm: 'argon2id',
        parameters: 'v=19,m=19456,t=2,p=1,l=32',
        salt: base64Encode(salt),
        verifier: base64Encode(await key.extractBytes()),
      );
    } catch (_) {
      throw const CoreInitializationException(
        CoreInitializationFailure.credentialFailure,
      );
    }

    final now = DateTime.now().toUtc();
    return _store.initialize(
      CoreInitializationRecords(
        companyId: generateCoreUuidV7(),
        companyCode: companyCode,
        companyName: companyName,
        userId: generateCoreUuidV7(),
        adminName: adminName,
        adminEmail: adminEmail,
        membershipId: generateCoreUuidV7(),
        createdAt: now,
        credential: credential,
      ),
    );
  }
}
