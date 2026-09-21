// ignore_for_file: prefer_initializing_formals

import 'dart:async';

import '../authorization/nexabiz_authorization_session_source.dart';
import '../authorization/nexabiz_membership_id.dart';
import '../company/nexabiz_company_scope.dart';
import '../identity/authenticate_local_user.dart';
import '../identity/core_uuid.dart';
import 'nexabiz_session.dart';

/// Pure Dart controller managing authoritative local session lifecycle and company switching.
final class CoreSessionController implements NexaBizAuthorizationSessionSource {
  CoreSessionController({
    required AuthenticateLocalUser authenticateLocalUser,
    required CoreIdentityQueryStore queryStore,
  }) : _authenticate = authenticateLocalUser,
       _queryStore = queryStore;

  final AuthenticateLocalUser _authenticate;
  final CoreIdentityQueryStore _queryStore;

  NexaBizSession _currentSession = const NexaBizSession.noSession();
  // Logout must invalidate pending logins even when already in noSession.
  int _logoutGeneration = 0;
  final _sessionController = StreamController<NexaBizSession>.broadcast();
  StreamSubscription<bool>? _eligibilitySubscription;

  NexaBizSession get currentSession => _currentSession;
  Stream<NexaBizSession> get onSessionChanged => _sessionController.stream;

  /// Authenticates user against relational authority.
  Future<CoreAuthenticationResult> login(CoreAuthenticationInput input) async {
    final originalSession = _currentSession;
    final logoutGeneration = _logoutGeneration;
    final result = await _authenticate(input);
    // Preserve the authentication result, but never apply stale session effects.
    if (logoutGeneration != _logoutGeneration ||
        !identical(_currentSession, originalSession)) {
      return result;
    }
    if (!result.isSuccess || result.user == null) {
      return result;
    }

    final user = result.user!;
    final userId = NexaBizUserId(user.id);
    final sessionId = generateCoreUuidV7();

    if (result.activeCompany != null && result.activeMembership != null) {
      final company = result.activeCompany!;
      final membershipIdStr =
          result.activeMembership!.membershipId ?? company.membershipId;
      _setSession(
        NexaBizSession.active(
          userId: userId,
          companyId: NexaBizCompanyId(company.id),
          membershipId: membershipIdStr != null
              ? NexaBizMembershipId(membershipIdStr)
              : null,
          userName: user.name,
          userEmail: user.email,
          companyName: company.name,
          companyCode: company.code,
          role: company.role,
          availableCompanies: result.availableCompanies,
          sessionId: sessionId,
        ),
      );
    } else if (result.requiresCompanySelection) {
      _setSession(
        NexaBizSession.active(
          userId: userId,
          companyId: null,
          membershipId: null,
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
    final originalSession = _currentSession;
    if (!originalSession.isActive || originalSession.userId == null) {
      throw StateError(
        'Cannot switch company without an active authenticated session.',
      );
    }

    final logoutGeneration = _logoutGeneration;
    final userId = originalSession.userId!.value;

    final CoreAuthIdentitySnapshot? snapshot;
    try {
      snapshot = await _queryStore.readAuthenticationSnapshot(userId);
    } catch (_) {
      return false;
    }

    // A logout, login, or another completed switch invalidates this operation.
    if (logoutGeneration != _logoutGeneration ||
        !identical(_currentSession, originalSession)) {
      return false;
    }

    // Fail closed: If user was deleted or disabled, terminate session immediately.
    if (snapshot == null || snapshot.user.status != 'active') {
      logout();
      return false;
    }

    final targetId = targetCompanyId.trim();
    final targetCompany = snapshot.companies
        .cast<CoreAuthCompanyRef?>()
        .firstWhere((c) => c?.id == targetId, orElse: () => null);

    if (targetCompany == null) {
      return false;
    }

    // Context Termination & Switch Invariant:
    // Previous company context is terminated by creating a distinct new NexaBizSession.active
    final newSessionId = generateCoreUuidV7();
    _setSession(
      NexaBizSession.active(
        userId: originalSession.userId!,
        companyId: NexaBizCompanyId(targetCompany.id),
        membershipId: targetCompany.membershipId != null
            ? NexaBizMembershipId(targetCompany.membershipId!)
            : null,
        userName: snapshot.user.name.isNotEmpty
            ? snapshot.user.name
            : originalSession.userName,
        userEmail: snapshot.user.email.isNotEmpty
            ? snapshot.user.email
            : originalSession.userEmail,
        companyName: targetCompany.name,
        companyCode: targetCompany.code,
        role: targetCompany.role,
        availableCompanies: snapshot.companies,
        sessionId: newSessionId,
      ),
    );

    return true;
  }

  /// Explicit validation for application boundaries, independent of UI builds.
  Future<bool> validateSession() async {
    final originalSession = _currentSession;
    if (!originalSession.isActive || originalSession.userId == null) {
      return false;
    }

    bool eligible;
    try {
      eligible = await _queryStore.isSessionEligible(
        originalSession.userId!.value,
        originalSession.companyId?.value,
      );
    } catch (_) {
      eligible = false;
    }
    if (!identical(_currentSession, originalSession)) return false;
    if (!eligible) logout();
    return eligible;
  }

  void _watchEligibility(NexaBizSession session) {
    final previous = _eligibilitySubscription;
    _eligibilitySubscription = null;
    if (previous != null) unawaited(previous.cancel());
    if (!session.isActive || session.userId == null) return;

    void invalidate() {
      if (identical(_currentSession, session)) logout();
    }

    _eligibilitySubscription = _queryStore
        .watchSessionEligibility(
          session.userId!.value,
          session.companyId?.value,
        )
        .listen((eligible) {
          if (!eligible) invalidate();
        }, onError: (Object error, StackTrace stack) => invalidate());
  }

  /// Invalidation of active session state.
  /// Clears active user and company context while maintaining relational DB readiness.
  void logout() {
    _logoutGeneration++;
    _setSession(const NexaBizSession.noSession());
  }

  /// Sets session state directly for unit tests without credential verification overhead.
  void setSessionForTesting(NexaBizSession session) {
    _setSession(session);
  }

  void _setSession(NexaBizSession session) {
    if (_currentSession != session) {
      _currentSession = session;
      _watchEligibility(session);
      _sessionController.add(session);
    }
  }

  @override
  bool matchesActiveSession({
    required String sessionId,
    required NexaBizUserId userId,
    NexaBizCompanyId? companyId,
    NexaBizMembershipId? membershipId,
  }) {
    final s = _currentSession;
    if (!s.isActive) return false;
    if (s.sessionId != sessionId) return false;
    if (s.userId != userId) return false;
    if (companyId != null && s.companyId != companyId) return false;
    if (membershipId != null && s.membershipId != membershipId) return false;
    return true;
  }

  Future<void> dispose() async {
    await _eligibilitySubscription?.cancel();
    await _sessionController.close();
  }
}
