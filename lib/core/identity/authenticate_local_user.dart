// ignore_for_file: prefer_initializing_formals

import '../setup/initialize_nexabiz_core.dart';
import 'verify_core_credential.dart';

enum CoreAuthenticationStatus {
  success,
  invalidCredentials,
  lockedOut,
  userInactive,
  noActiveMemberships,
  unauthorizedCompanyChoice,
  storageFailure,
}

final class CoreLoginLockout {
  const CoreLoginLockout({
    required this.attemptCount,
    required this.lockedUntil,
  });

  final int attemptCount;
  final DateTime lockedUntil;
}

final class CoreAuthUserRef {
  const CoreAuthUserRef({
    required this.id,
    required this.name,
    required this.email,
    required this.status,
  });

  final String id;
  final String name;
  final String email;
  final String status;
}

final class CoreAuthCompanyRef {
  const CoreAuthCompanyRef({
    required this.id,
    required this.name,
    required this.code,
    required this.role,
    this.membershipId,
  });

  final String id;
  final String name;
  final String code;
  final String role;
  final String? membershipId;
}

final class CoreAuthMembershipRef {
  const CoreAuthMembershipRef({
    this.membershipId,
    required this.userId,
    required this.companyId,
    required this.role,
    required this.status,
  });

  final String? membershipId;
  final String userId;
  final String companyId;
  final String role;
  final String status;
}

/// One storage snapshot of a user and companies with active memberships.
final class CoreAuthIdentitySnapshot {
  CoreAuthIdentitySnapshot({
    required this.user,
    required Iterable<CoreAuthCompanyRef> companies,
  }) : companies = List.unmodifiable(companies);

  final CoreAuthUserRef user;
  final List<CoreAuthCompanyRef> companies;
}

final class CoreAuthenticationInput {
  const CoreAuthenticationInput({
    required this.identifier,
    required this.password,
    this.companyId,
  });

  final String identifier;
  final String password;
  final String? companyId;
}

final class CoreAuthenticationResult {
  const CoreAuthenticationResult({
    required this.status,
    this.user,
    this.availableCompanies = const [],
    this.activeCompany,
    this.activeMembership,
    this.lockoutExpiresAt,
  });

  final CoreAuthenticationStatus status;
  final CoreAuthUserRef? user;
  final List<CoreAuthCompanyRef> availableCompanies;
  final CoreAuthCompanyRef? activeCompany;
  final CoreAuthMembershipRef? activeMembership;
  final DateTime? lockoutExpiresAt;

  bool get isSuccess => status == CoreAuthenticationStatus.success;
  bool get isLockedOut => status == CoreAuthenticationStatus.lockedOut;
  bool get requiresCompanySelection =>
      isSuccess && activeCompany == null && availableCompanies.length > 1;
}

/// Abstract contract for querying relational user identity records for local authentication.
abstract interface class CoreIdentityQueryStore {
  Future<CoreAuthUserRef?> findUserByIdentifier(String normalizedIdentifier);
  Future<CorePreparedCredential?> readUserCredential(String userId);

  /// Must read the user, active memberships, and active companies atomically.
  Future<CoreAuthIdentitySnapshot?> readAuthenticationSnapshot(String userId);

  /// Checks if the normalized identifier is currently locked out.
  Future<CoreLoginLockout?> checkLockout(
    String normalizedIdentifier,
    DateTime nowUtc,
  );

  /// Records a failed authentication attempt and returns lockout details if locked.
  Future<CoreLoginLockout?> recordFailedAttempt(
    String normalizedIdentifier,
    DateTime nowUtc,
  );

  /// Clears failed authentication attempts upon successful authentication.
  Future<void> clearFailedAttempts(String normalizedIdentifier);

  /// An active user with an active membership in an active company.
  /// Before company selection, at least one eligible company must remain.
  Future<bool> isSessionEligible(String userId, String? companyId);
  Stream<bool> watchSessionEligibility(String userId, String? companyId);
}

/// Core application operation for local identity verification and company access resolution.
final class AuthenticateLocalUser {
  const AuthenticateLocalUser({
    required CoreIdentityQueryStore queryStore,
    VerifyCoreCredential verifier = const VerifyCoreCredential(),
    DateTime Function()? nowProvider,
  }) : _queryStore = queryStore,
       _verifier = verifier,
       _nowProvider = nowProvider;

  final CoreIdentityQueryStore _queryStore;
  final VerifyCoreCredential _verifier;
  final DateTime Function()? _nowProvider;

  /// Constant, structurally valid dummy credential used exclusively to prevent
  /// timing-based user enumeration.
  /// Uses identical Argon2id algorithm, parameters, salt length, and verifier length
  /// to ensure equal computational cost without exposing any real user credential.
  static const CorePreparedCredential _dummyCredential = CorePreparedCredential(
    algorithm: 'argon2id',
    parameters: 'v=19,m=19456,t=2,p=1,l=32',
    salt: 'TmV4YUJpel9EdW1teV9BcmdvbjJpZF9TYWx0XzMyQiE=',
    verifier: 'TmV4YUJpel9EdW1teV9BcmdvbjJfVmVyaWZpZXIzMkI=',
  );

  Future<CoreAuthenticationResult> call(CoreAuthenticationInput input) async {
    final normalized = input.identifier.trim().toLowerCase();
    if (normalized.isEmpty || input.password.isEmpty) {
      return const CoreAuthenticationResult(
        status: CoreAuthenticationStatus.invalidCredentials,
      );
    }

    final nowUtc = (_nowProvider?.call() ?? DateTime.now()).toUtc();

    try {
      final activeLockout = await _queryStore.checkLockout(normalized, nowUtc);
      if (activeLockout != null) {
        return CoreAuthenticationResult(
          status: CoreAuthenticationStatus.lockedOut,
          lockoutExpiresAt: activeLockout.lockedUntil,
        );
      }

      final user = await _queryStore.findUserByIdentifier(normalized);
      final credential = user != null
          ? await _queryStore.readUserCredential(user.id)
          : null;

      final targetCredential = credential ?? _dummyCredential;
      final matched = await _verifier(
        candidatePassword: input.password,
        storedCredential: targetCredential,
      );

      if (user == null || credential == null || !matched) {
        final lockout = await _queryStore.recordFailedAttempt(
          normalized,
          nowUtc,
        );
        if (lockout != null) {
          return CoreAuthenticationResult(
            status: CoreAuthenticationStatus.lockedOut,
            lockoutExpiresAt: lockout.lockedUntil,
          );
        }
        return const CoreAuthenticationResult(
          status: CoreAuthenticationStatus.invalidCredentials,
        );
      }

      final snapshot = await _queryStore.readAuthenticationSnapshot(user.id);
      if (snapshot == null) {
        return const CoreAuthenticationResult(
          status: CoreAuthenticationStatus.invalidCredentials,
        );
      }

      if (snapshot.user.status != 'active') {
        return CoreAuthenticationResult(
          status: CoreAuthenticationStatus.userInactive,
          user: snapshot.user,
        );
      }

      final availableCompanies = snapshot.companies;
      if (availableCompanies.isEmpty) {
        return CoreAuthenticationResult(
          status: CoreAuthenticationStatus.noActiveMemberships,
          user: snapshot.user,
        );
      }

      String? selectedCompanyId = input.companyId?.trim();
      if (selectedCompanyId != null && selectedCompanyId.isNotEmpty) {
        final authorized = availableCompanies.any(
          (c) => c.id == selectedCompanyId,
        );
        if (!authorized) {
          return CoreAuthenticationResult(
            status: CoreAuthenticationStatus.unauthorizedCompanyChoice,
            user: snapshot.user,
            availableCompanies: availableCompanies,
          );
        }
      } else {
        if (availableCompanies.length == 1) {
          selectedCompanyId = availableCompanies.first.id;
        } else {
          selectedCompanyId = null;
        }
      }

      CoreAuthCompanyRef? activeCompany;
      CoreAuthMembershipRef? activeMembership;

      if (selectedCompanyId != null) {
        activeCompany = availableCompanies.firstWhere(
          (c) => c.id == selectedCompanyId,
        );
        activeMembership = CoreAuthMembershipRef(
          membershipId: activeCompany.membershipId,
          userId: snapshot.user.id,
          companyId: activeCompany.id,
          role: activeCompany.role,
          status: 'active',
        );
      }

      await _queryStore.clearFailedAttempts(normalized);

      return CoreAuthenticationResult(
        status: CoreAuthenticationStatus.success,
        user: snapshot.user,
        availableCompanies: availableCompanies,
        activeCompany: activeCompany,
        activeMembership: activeMembership,
      );
    } catch (_) {
      return const CoreAuthenticationResult(
        status: CoreAuthenticationStatus.storageFailure,
      );
    }
  }
}
