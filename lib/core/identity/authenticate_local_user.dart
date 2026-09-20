// ignore_for_file: prefer_initializing_formals

import '../setup/initialize_nexabiz_core.dart';
import 'verify_core_credential.dart';

enum CoreAuthenticationStatus {
  success,
  invalidCredentials,
  userInactive,
  noActiveMemberships,
  unauthorizedCompanyChoice,
  storageFailure,
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
  });

  final String id;
  final String name;
  final String code;
  final String role;
}

final class CoreAuthMembershipRef {
  const CoreAuthMembershipRef({
    required this.userId,
    required this.companyId,
    required this.role,
    required this.status,
  });

  final String userId;
  final String companyId;
  final String role;
  final String status;
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
  });

  final CoreAuthenticationStatus status;
  final CoreAuthUserRef? user;
  final List<CoreAuthCompanyRef> availableCompanies;
  final CoreAuthCompanyRef? activeCompany;
  final CoreAuthMembershipRef? activeMembership;

  bool get isSuccess => status == CoreAuthenticationStatus.success;
  bool get requiresCompanySelection =>
      isSuccess && activeCompany == null && availableCompanies.length > 1;
}

/// Abstract contract for querying relational user identity records for local authentication.
abstract interface class CoreIdentityQueryStore {
  Future<CoreAuthUserRef?> findUserByIdentifier(String normalizedIdentifier);
  Future<CorePreparedCredential?> readUserCredential(String userId);
  Future<List<CoreAuthCompanyRef>> readActiveUserCompanies(String userId);
  Future<CoreAuthMembershipRef?> readMembership(String userId, String companyId);
}

/// Core application operation for local identity verification and company access resolution.
final class AuthenticateLocalUser {
  const AuthenticateLocalUser({
    required CoreIdentityQueryStore queryStore,
    VerifyCoreCredential verifier = const VerifyCoreCredential(),
  })  : _queryStore = queryStore,
        _verifier = verifier;

  final CoreIdentityQueryStore _queryStore;
  final VerifyCoreCredential _verifier;

  Future<CoreAuthenticationResult> call(CoreAuthenticationInput input) async {
    final normalized = input.identifier.trim().toLowerCase();
    if (normalized.isEmpty || input.password.isEmpty) {
      return const CoreAuthenticationResult(
        status: CoreAuthenticationStatus.invalidCredentials,
      );
    }

    try {
      final user = await _queryStore.findUserByIdentifier(normalized);
      if (user == null) {
        return const CoreAuthenticationResult(
          status: CoreAuthenticationStatus.invalidCredentials,
        );
      }
      if (user.status != 'active') {
        return CoreAuthenticationResult(
          status: CoreAuthenticationStatus.userInactive,
          user: user,
        );
      }

      final credential = await _queryStore.readUserCredential(user.id);
      if (credential == null) {
        return CoreAuthenticationResult(
          status: CoreAuthenticationStatus.invalidCredentials,
          user: user,
        );
      }

      final matched = await _verifier(
        candidatePassword: input.password,
        storedCredential: credential,
      );
      if (!matched) {
        return CoreAuthenticationResult(
          status: CoreAuthenticationStatus.invalidCredentials,
          user: user,
        );
      }

      final availableCompanies = await _queryStore.readActiveUserCompanies(
        user.id,
      );
      if (availableCompanies.isEmpty) {
        return CoreAuthenticationResult(
          status: CoreAuthenticationStatus.noActiveMemberships,
          user: user,
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
            user: user,
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
        activeMembership = await _queryStore.readMembership(
          user.id,
          selectedCompanyId,
        );
      }

      return CoreAuthenticationResult(
        status: CoreAuthenticationStatus.success,
        user: user,
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
