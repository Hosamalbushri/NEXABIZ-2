// ignore_for_file: prefer_initializing_formals

import 'dart:async';

import '../company/nexabiz_company_scope.dart';
import '../identity/authenticate_local_user.dart';

import '../identity/core_uuid.dart';
import 'nexabiz_session.dart';

/// Pure Dart controller managing authoritative local session lifecycle and company switching.
final class CoreSessionController {
  CoreSessionController({
    required AuthenticateLocalUser authenticateLocalUser,
    required CoreIdentityQueryStore queryStore,
  })  : _authenticate = authenticateLocalUser,
        _queryStore = queryStore;

  final AuthenticateLocalUser _authenticate;
  final CoreIdentityQueryStore _queryStore;

  NexaBizSession _currentSession = const NexaBizSession.noSession();
  final _sessionController = StreamController<NexaBizSession>.broadcast();

  NexaBizSession get currentSession => _currentSession;
  Stream<NexaBizSession> get onSessionChanged => _sessionController.stream;

  /// Authenticates user against relational authority.
  Future<CoreAuthenticationResult> login(CoreAuthenticationInput input) async {
    final result = await _authenticate(input);
    if (!result.isSuccess || result.user == null) {
      _setSession(const NexaBizSession.noSession());
      return result;
    }

    final user = result.user!;
    final userId = NexaBizUserId(user.id);
    final sessionId = generateCoreUuidV7();

    if (result.activeCompany != null && result.activeMembership != null) {
      final company = result.activeCompany!;
      _setSession(
        NexaBizSession.active(
          userId: userId,
          companyId: NexaBizCompanyId(company.id),
          userName: user.name,
          userEmail: user.email,
          companyName: company.name,
          companyCode: company.code,
          role: company.role,
          availableCompanies: result.availableCompanies,
          sessionId: sessionId,
        ),
      );
    } else {
      _setSession(
        NexaBizSession.active(
          userId: userId,
          companyId: null,
          userName: user.name,
          userEmail: user.email,
          availableCompanies: result.availableCompanies,
          sessionId: sessionId,
        ),
      );
    }

    return result;
  }

  /// Selects or switches active company context for an authenticated user session.
  /// Enforces: Re-validates target company membership and terminates previous context.
  Future<bool> selectOrSwitchCompany(String targetCompanyId) async {
    if (!_currentSession.isActive || _currentSession.userId == null) {
      throw StateError('Cannot switch company without an active authenticated session.');
    }

    final userId = _currentSession.userId!.value;
    final membership = await _queryStore.readMembership(userId, targetCompanyId);
    if (membership == null || membership.status != 'active') {
      return false;
    }

    final available = await _queryStore.readActiveUserCompanies(userId);
    final targetCompany = available.cast<CoreAuthCompanyRef?>().firstWhere(
      (c) => c?.id == targetCompanyId,
      orElse: () => null,
    );

    if (targetCompany == null) {
      return false;
    }

    // Context Termination & Switch Invariant:
    // Previous company context is terminated by creating a distinct new NexaBizSession.active
    final newSessionId = generateCoreUuidV7();
    _setSession(
      NexaBizSession.active(
        userId: _currentSession.userId!,
        companyId: NexaBizCompanyId(targetCompany.id),
        userName: _currentSession.userName,
        userEmail: _currentSession.userEmail,
        companyName: targetCompany.name,
        companyCode: targetCompany.code,
        role: targetCompany.role,
        availableCompanies: available,
        sessionId: newSessionId,
      ),
    );

    return true;
  }

  /// Invalidation of active session state.
  /// Clears active user and company context while maintaining relational DB readiness.
  void logout() {
    _setSession(const NexaBizSession.noSession());
  }

  void _setSession(NexaBizSession session) {
    if (_currentSession != session) {
      _currentSession = session;
      _sessionController.add(session);
    }
  }

  Future<void> dispose() async {
    await _sessionController.close();
  }
}
