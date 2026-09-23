// ignore_for_file: prefer_initializing_formals

import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../app/authorization/nexabiz_authorization_administration.dart';
import '../../../../app/authorization/nexabiz_authorization_invalidation_signal.dart';
import '../../../../core/authorization/administration/nexabiz_authorization_administration_models.dart';
import '../../../../core/authorization/nexabiz_authorization_context.dart';
import '../../../../core/authorization/nexabiz_membership_id.dart';
import '../../../../core/permissions/nexabiz_permission_intent.dart';
import '../../../../core/roles/nexabiz_role_id.dart';
import '../../../../core/session/core_session_controller.dart';
import '../../../../core/session/nexabiz_session.dart';
import '../metadata/nexabiz_permission_presentation_resolver.dart';
import 'roles_administration_state.dart';

/// Single presentation authority & state controller for Roles Administration.
///
/// Ensures future UI widgets strictly adhere to:
/// `Render State → Send Intent`
///
/// Responsible for:
/// - Orchestrating `NexaBizAuthorizationAdministration` usecases.
/// - Epoch-based company-switch & logout invalidation.
/// - Generation-based search, pagination, and selection race safety.
/// - Commit-confirmed mutation states with per-action pending guards.
/// - Locale-neutral state management.
///
/// NOTE: This controller is NOT an authorization security authority; the authoritative
/// `NexaBizPermissionGuard` inside each UseCase remains the sole security gate.
final class RolesAdministrationController extends ChangeNotifier {
  RolesAdministrationController({
    required NexaBizAuthorizationAdministration administration,
    NexaBizPermissionPresentationResolver metadataResolver =
        const NexaBizPermissionPresentationResolver(),
    NexaBizCompanyAuthorizationContext? initialContext,
    CoreSessionController? sessionController,
    NexaBizAuthorizationInvalidationSignal? invalidationSignal,
    int pageSize = 20,
  }) : _administration = administration,
       _metadataResolver = metadataResolver,
       _sessionController = sessionController,
       _invalidationSignal = invalidationSignal,
       _pageSize = pageSize,
       _state = RolesAdministrationState.initial(
         companyId: initialContext?.companyId,
       ) {
    if (initialContext != null) {
      _currentContext = initialContext;
    } else if (sessionController != null &&
        sessionController.currentSession.isActive) {
      _currentContext = NexaBizCompanyAuthorizationContext.fromSession(
        sessionController.currentSession,
      );
      _state = RolesAdministrationState.initial(
        companyId: _currentContext!.companyId,
      );
    }

    if (_sessionController != null) {
      _sessionSubscription = _sessionController.onSessionChanged.listen(
        _handleSessionChanged,
      );
    }

    if (_invalidationSignal != null) {
      _invalidationSignal.addListener(_handleInvalidationSignal);
    }
  }

  final NexaBizAuthorizationAdministration _administration;
  final NexaBizPermissionPresentationResolver _metadataResolver;
  final CoreSessionController? _sessionController;
  final NexaBizAuthorizationInvalidationSignal? _invalidationSignal;
  final int _pageSize;

  StreamSubscription<NexaBizSession>? _sessionSubscription;

  NexaBizCompanyAuthorizationContext? _currentContext;
  NexaBizCompanyAuthorizationContext? get currentContext => _currentContext;

  RolesAdministrationState _state;
  RolesAdministrationState get state => _state;

  // Race safety & epoch tracking
  int _epoch = 0;
  int _roleListGeneration = 0;
  int _roleDetailsGeneration = 0;
  int _assignableMembersGeneration = 0;
  bool _isRefreshing = false;
  bool _refreshRequestedWhileActive = false;
  bool _isDisposed = false;

  void _safeNotifyListeners() {
    if (!_isDisposed) {
      notifyListeners();
    }
  }

  // =========================================================================
  // Context & Session Lifecycle
  // =========================================================================

  void _handleSessionChanged(NexaBizSession session) {
    if (_isDisposed) return;
    if (!session.isActive) {
      handleLogout();
      return;
    }

    final newCompanyId = session.companyId;
    if (newCompanyId != null &&
        (_currentContext == null ||
            _currentContext!.companyId != newCompanyId)) {
      final newContext = NexaBizCompanyAuthorizationContext.fromSession(
        session,
      );
      updateContext(newContext);
    }
  }

  /// Authoritatively updates the active company context.
  ///
  /// Increments [_epoch] to drop any pending in-flight requests from the previous context,
  /// resets the state, and triggers an initial load if [newContext] is present.
  Future<void> updateContext(
    NexaBizCompanyAuthorizationContext? newContext,
  ) async {
    if (_isDisposed) return;
    _epoch++;

    if (newContext == null) {
      _currentContext = null;
      _state = RolesAdministrationState.initial();
      _safeNotifyListeners();
      return;
    }

    final isSameCompany = _currentContext?.companyId == newContext.companyId;
    _currentContext = newContext;

    if (!isSameCompany) {
      _state = RolesAdministrationState.initial(
        companyId: newContext.companyId,
      );
      _safeNotifyListeners();
      await initialize();
    }
  }

  /// Handles session logout by invalidating pending requests and clearing sensitive data.
  void handleLogout() {
    if (_isDisposed) return;
    _epoch++;
    _currentContext = null;
    _state = RolesAdministrationState.initial();
    _safeNotifyListeners();
  }

  // =========================================================================
  // Invalidation Signal Handling
  // =========================================================================

  void _handleInvalidationSignal() {
    if (_isDisposed || _currentContext == null) return;
    _requestCoalescedRefresh();
  }

  Future<void> _requestCoalescedRefresh() async {
    if (_isDisposed || _currentContext == null) return;

    if (_isRefreshing) {
      _refreshRequestedWhileActive = true;
      return;
    }

    _isRefreshing = true;
    try {
      do {
        _refreshRequestedWhileActive = false;
        final currentEpoch = _epoch;
        await _performBoundedRefresh();
        if (_isDisposed || currentEpoch != _epoch) break;
      } while (_refreshRequestedWhileActive &&
          !_isDisposed &&
          _currentContext != null);
    } finally {
      _isRefreshing = false;
    }
  }

  Future<void> _performBoundedRefresh() async {
    if (_isDisposed || _currentContext == null) return;
    await refreshRoles(silent: true);
    if (_state.hasSelectedRole) {
      await refreshSelectedRole(silent: true);
    }
  }

  // =========================================================================
  // Initialization & Initial Load
  // =========================================================================

  /// Loads the initial surface data (role list page 1 + declared catalog).
  Future<void> initialize() async {
    if (_isDisposed || _currentContext == null) return;

    final requestEpoch = _epoch;
    final requestGen = ++_roleListGeneration;

    _state = _state.copyWith(
      isLoadingRoles: true,
      isLoadingCatalog: !_state.isCatalogLoaded,
      rolesError: () => null,
      catalogError: () => null,
    );
    _safeNotifyListeners();

    final loadCatalogFuture = !_state.isCatalogLoaded
        ? _fetchDeclaredCatalog(requestEpoch)
        : Future.value(null);

    final loadRolesFuture = _fetchRolesPage(
      requestEpoch: requestEpoch,
      requestGen: requestGen,
      cursor: null,
      search: _state.roleSearchQuery,
      kind: _state.roleKindFilter,
    );

    await Future.wait([loadCatalogFuture, loadRolesFuture]);

    if (_isDisposed ||
        requestEpoch != _epoch ||
        requestGen != _roleListGeneration) {
      return;
    }

    _state = _state.copyWith(isInitialized: true);
    _safeNotifyListeners();
  }

  Future<void> _fetchDeclaredCatalog(int requestEpoch) async {
    if (_currentContext == null) return;

    try {
      final catalogIds = await _administration.listDeclaredPermissionCatalog
          .execute(context: _currentContext!);

      if (_isDisposed || requestEpoch != _epoch) return;

      final descriptors = catalogIds
          .map((id) => _metadataResolver.describe(id))
          .toList();

      descriptors.sort((a, b) {
        final groupCmp = a.group.order.compareTo(b.group.order);
        if (groupCmp != 0) return groupCmp;
        final sortCmp = a.sortOrder.compareTo(b.sortOrder);
        if (sortCmp != 0) return sortCmp;
        return a.permissionId.value.compareTo(b.permissionId.value);
      });

      _state = _state.copyWith(
        declaredCatalog: List.unmodifiable(descriptors),
        isLoadingCatalog: false,
        catalogError: () => null,
      );
    } catch (e) {
      if (_isDisposed || requestEpoch != _epoch) return;
      _state = _state.copyWith(
        isLoadingCatalog: false,
        catalogError: () => NexaBizAuthorizationPresentationError(error: e),
      );
    }
  }

  // =========================================================================
  // Roles Pagination, Search & Filter
  // =========================================================================

  Future<void> _fetchRolesPage({
    required int requestEpoch,
    required int requestGen,
    required String? cursor,
    required String? search,
    required NexaBizCompanyRoleKind? kind,
    bool silent = false,
  }) async {
    if (_currentContext == null) return;

    try {
      final page = await _administration.listCompanyRoles.execute(
        context: _currentContext!,
        page: NexaBizAuthorizationAdministrationPageRequest(
          limit: _pageSize,
          cursor: cursor,
        ),
        filter: NexaBizCompanyRoleFilter(search: search, kind: kind),
      );

      if (_isDisposed ||
          requestEpoch != _epoch ||
          requestGen != _roleListGeneration) {
        return;
      }

      final existingRoles = cursor == null
          ? <NexaBizCompanyRoleSummary>[]
          : List<NexaBizCompanyRoleSummary>.from(_state.roles);

      final existingIds = existingRoles.map((r) => r.roleId).toSet();
      for (final item in page.items) {
        if (!existingIds.contains(item.roleId)) {
          existingRoles.add(item);
        }
      }

      _state = _state.copyWith(
        roles: List.unmodifiable(existingRoles),
        rolesNextCursor: () => page.nextCursor,
        isLoadingRoles: false,
        isLoadingMoreRoles: false,
        rolesError: () => null,
      );
      _safeNotifyListeners();
    } catch (e) {
      if (_isDisposed ||
          requestEpoch != _epoch ||
          requestGen != _roleListGeneration) {
        return;
      }

      _state = _state.copyWith(
        isLoadingRoles: false,
        isLoadingMoreRoles: false,
        rolesError: () => NexaBizAuthorizationPresentationError(error: e),
      );
      _safeNotifyListeners();
    }
  }

  /// Refreshes the first page of roles with current search and filter.
  Future<void> refreshRoles({bool silent = false}) async {
    if (_isDisposed || _currentContext == null) return;

    final requestEpoch = _epoch;
    final requestGen = ++_roleListGeneration;

    if (!silent) {
      _state = _state.copyWith(isLoadingRoles: true, rolesError: () => null);
      _safeNotifyListeners();
    }

    await _fetchRolesPage(
      requestEpoch: requestEpoch,
      requestGen: requestGen,
      cursor: null,
      search: _state.roleSearchQuery,
      kind: _state.roleKindFilter,
      silent: silent,
    );
  }

  /// Loads the next page of roles using the cursor.
  Future<void> loadMoreRoles() async {
    if (_isDisposed ||
        _currentContext == null ||
        _state.isLoadingMoreRoles ||
        !_state.hasMoreRoles) {
      return;
    }

    final requestEpoch = _epoch;
    final requestGen = _roleListGeneration;

    _state = _state.copyWith(isLoadingMoreRoles: true);
    _safeNotifyListeners();

    await _fetchRolesPage(
      requestEpoch: requestEpoch,
      requestGen: requestGen,
      cursor: _state.rolesNextCursor,
      search: _state.roleSearchQuery,
      kind: _state.roleKindFilter,
    );
  }

  /// Searches roles with generation-based race safety.
  Future<void> searchRoles(String? query) async {
    if (_isDisposed || _currentContext == null) return;

    final trimmed = query?.trim();
    final normalized = (trimmed == null || trimmed.isEmpty) ? null : trimmed;

    if (_state.roleSearchQuery == normalized) return;

    final requestEpoch = _epoch;
    final requestGen = ++_roleListGeneration;

    _state = _state.copyWith(
      roleSearchQuery: () => normalized,
      rolesNextCursor: () => null,
      isLoadingRoles: true,
      rolesError: () => null,
    );
    _safeNotifyListeners();

    await _fetchRolesPage(
      requestEpoch: requestEpoch,
      requestGen: requestGen,
      cursor: null,
      search: normalized,
      kind: _state.roleKindFilter,
    );
  }

  /// Filters roles by kind (All, Built-in, Custom).
  Future<void> filterRoleKind(NexaBizCompanyRoleKind? kind) async {
    if (_isDisposed || _currentContext == null) return;
    if (_state.roleKindFilter == kind) return;

    final requestEpoch = _epoch;
    final requestGen = ++_roleListGeneration;

    _state = _state.copyWith(
      roleKindFilter: () => kind,
      rolesNextCursor: () => null,
      isLoadingRoles: true,
      rolesError: () => null,
    );
    _safeNotifyListeners();

    await _fetchRolesPage(
      requestEpoch: requestEpoch,
      requestGen: requestGen,
      cursor: null,
      search: _state.roleSearchQuery,
      kind: kind,
    );
  }

  // =========================================================================
  // Role Selection & Details Lifecycle
  // =========================================================================

  /// Selects [roleId] and concurrently loads its details, permissions, and assigned members.
  ///
  /// Guarantees that late responses from earlier role selections are completely discarded.
  Future<void> selectRole(NexaBizRoleId roleId, {bool silent = false}) async {
    if (_isDisposed || _currentContext == null) return;

    final requestEpoch = _epoch;
    final requestGen = ++_roleDetailsGeneration;

    // Find summary from current list if available
    NexaBizCompanyRoleSummary? summary;
    for (final r in _state.roles) {
      if (r.roleId == roleId) {
        summary = r;
        break;
      }
    }

    if (!silent) {
      _state = _state.copyWith(
        selectedRoleId: () => roleId,
        selectedRoleSummary: () => summary,
        selectedRoleDetails: () => null,
        selectedRolePermissions: const [],
        assignedMembers: const [],
        assignedMembersNextCursor: () => null,
        assignableMembers: const [],
        assignableMembersNextCursor: () => null,
        assignableMembersSearchQuery: () => null,
        isLoadingRoleDetails: true,
        isLoadingRolePermissions: true,
        isLoadingAssignedMembers: true,
        roleDetailsError: () => null,
        assignedMembersError: () => null,
        mutationError: () => null,
      );
      _safeNotifyListeners();
    }

    final detailsFuture = _administration.getCompanyRole.execute(
      context: _currentContext!,
      roleId: roleId,
    );

    final permissionsFuture = _administration.listRolePermissions.execute(
      context: _currentContext!,
      roleId: roleId,
      page: NexaBizAuthorizationAdministrationPageRequest(limit: 100),
    );

    final membersFuture = _administration.listMembershipsAssignedToRole.execute(
      context: _currentContext!,
      roleId: roleId,
      page: NexaBizAuthorizationAdministrationPageRequest(limit: _pageSize),
    );

    try {
      final results = await Future.wait([
        detailsFuture,
        permissionsFuture,
        membersFuture,
      ]);

      if (_isDisposed ||
          requestEpoch != _epoch ||
          requestGen != _roleDetailsGeneration) {
        return;
      }

      final details = results[0] as NexaBizCompanyRoleDetails;
      final permissionsPage =
          results[1]
              as NexaBizAuthorizationAdministrationPage<
                NexaBizRolePermissionAssignment
              >;
      final membersPage =
          results[2]
              as NexaBizAuthorizationAdministrationPage<
                NexaBizMembershipRoleAssignment
              >;

      final grantedIds = permissionsPage.items
          .map((p) => p.permissionId)
          .toSet();
      final permissionItems = _composeRolePermissions(grantedIds);

      _state = _state.copyWith(
        selectedRoleDetails: () => details,
        selectedRolePermissions: permissionItems,
        isLoadingRoleDetails: false,
        isLoadingRolePermissions: false,
        assignedMembers: List.unmodifiable(membersPage.items),
        assignedMembersNextCursor: () => membersPage.nextCursor,
        isLoadingAssignedMembers: false,
        roleDetailsError: () => null,
        assignedMembersError: () => null,
      );
      _safeNotifyListeners();
    } catch (e) {
      if (_isDisposed ||
          requestEpoch != _epoch ||
          requestGen != _roleDetailsGeneration) {
        return;
      }

      _state = _state.copyWith(
        isLoadingRoleDetails: false,
        isLoadingRolePermissions: false,
        isLoadingAssignedMembers: false,
        roleDetailsError: () =>
            NexaBizAuthorizationPresentationError(error: e, roleId: roleId),
      );
      _safeNotifyListeners();
    }
  }

  /// Clears active role selection and associated detail states.
  void clearSelectedRole() {
    if (_isDisposed) return;
    _roleDetailsGeneration++;
    _state = _state.copyWith(
      selectedRoleId: () => null,
      selectedRoleSummary: () => null,
      selectedRoleDetails: () => null,
      selectedRolePermissions: const [],
      assignedMembers: const [],
      assignedMembersNextCursor: () => null,
      assignableMembers: const [],
      assignableMembersNextCursor: () => null,
      assignableMembersSearchQuery: () => null,
      isLoadingRoleDetails: false,
      isLoadingRolePermissions: false,
      isLoadingAssignedMembers: false,
      roleDetailsError: () => null,
      assignedMembersError: () => null,
      mutationError: () => null,
    );
    _safeNotifyListeners();
  }

  /// Refreshes details, permissions, and assigned members for the currently selected role.
  Future<void> refreshSelectedRole({bool silent = false}) async {
    final roleId = _state.selectedRoleId;
    if (roleId == null || _currentContext == null) return;
    await selectRole(roleId, silent: silent);
  }

  List<NexaBizRolePermissionItem> _composeRolePermissions(
    Set<NexaBizPermissionId> grantedIds,
  ) {
    final items = _state.declaredCatalog.map((descriptor) {
      final isGranted = grantedIds.contains(descriptor.permissionId);
      final isPending = _state.pendingPermissionIds.contains(
        descriptor.permissionId,
      );
      return NexaBizRolePermissionItem(
        descriptor: descriptor,
        isGranted: isGranted,
        isPending: isPending,
      );
    }).toList();

    final catalogIds = _state.declaredCatalog
        .map((d) => d.permissionId)
        .toSet();
    for (final id in grantedIds) {
      if (!catalogIds.contains(id)) {
        items.add(
          NexaBizRolePermissionItem(
            descriptor: _metadataResolver.describe(id),
            isGranted: true,
            isPending: _state.pendingPermissionIds.contains(id),
          ),
        );
      }
    }
    return items;
  }

  // =========================================================================
  // Assigned Members Pagination
  // =========================================================================

  Future<void> loadMoreAssignedMembers() async {
    final roleId = _state.selectedRoleId;
    if (_isDisposed ||
        _currentContext == null ||
        roleId == null ||
        _state.isLoadingMoreAssignedMembers ||
        !_state.hasMoreAssignedMembers) {
      return;
    }

    final requestEpoch = _epoch;
    final requestGen = _roleDetailsGeneration;

    _state = _state.copyWith(isLoadingMoreAssignedMembers: true);
    _safeNotifyListeners();

    try {
      final page = await _administration.listMembershipsAssignedToRole.execute(
        context: _currentContext!,
        roleId: roleId,
        page: NexaBizAuthorizationAdministrationPageRequest(
          limit: _pageSize,
          cursor: _state.assignedMembersNextCursor,
        ),
      );

      if (_isDisposed ||
          requestEpoch != _epoch ||
          requestGen != _roleDetailsGeneration) {
        return;
      }

      final existingMembers = List<NexaBizMembershipRoleAssignment>.from(
        _state.assignedMembers,
      );
      final existingIds = existingMembers.map((m) => m.membershipId).toSet();

      for (final item in page.items) {
        if (!existingIds.contains(item.membershipId)) {
          existingMembers.add(item);
        }
      }

      _state = _state.copyWith(
        assignedMembers: List.unmodifiable(existingMembers),
        assignedMembersNextCursor: () => page.nextCursor,
        isLoadingMoreAssignedMembers: false,
      );
      _safeNotifyListeners();
    } catch (e) {
      if (_isDisposed ||
          requestEpoch != _epoch ||
          requestGen != _roleDetailsGeneration) {
        return;
      }

      _state = _state.copyWith(
        isLoadingMoreAssignedMembers: false,
        assignedMembersError: () =>
            NexaBizAuthorizationPresentationError(error: e, roleId: roleId),
      );
      _safeNotifyListeners();
    }
  }

  // =========================================================================
  // Assignable Members (Candidate Selection)
  // =========================================================================

  Future<void> loadAssignableMembers({String? search}) async {
    final roleId = _state.selectedRoleId;
    if (_isDisposed || _currentContext == null || roleId == null) return;

    final requestEpoch = _epoch;
    final requestGen = ++_assignableMembersGeneration;

    final trimmed = search?.trim();
    final normalized = (trimmed == null || trimmed.isEmpty) ? null : trimmed;

    _state = _state.copyWith(
      assignableMembersSearchQuery: () => normalized,
      assignableMembersNextCursor: () => null,
      isLoadingAssignableMembers: true,
      assignableMembersError: () => null,
    );
    _safeNotifyListeners();

    try {
      final page = await _administration.listAssignableMembershipsForRole
          .execute(
            context: _currentContext!,
            roleId: roleId,
            page: NexaBizAuthorizationAdministrationPageRequest(
              limit: _pageSize,
            ),
            search: normalized,
          );

      if (_isDisposed ||
          requestEpoch != _epoch ||
          requestGen != _assignableMembersGeneration) {
        return;
      }

      _state = _state.copyWith(
        assignableMembers: List.unmodifiable(page.items),
        assignableMembersNextCursor: () => page.nextCursor,
        isLoadingAssignableMembers: false,
        assignableMembersError: () => null,
      );
      _safeNotifyListeners();
    } catch (e) {
      if (_isDisposed ||
          requestEpoch != _epoch ||
          requestGen != _assignableMembersGeneration) {
        return;
      }

      _state = _state.copyWith(
        isLoadingAssignableMembers: false,
        assignableMembersError: () =>
            NexaBizAuthorizationPresentationError(error: e, roleId: roleId),
      );
      _safeNotifyListeners();
    }
  }

  Future<void> loadMoreAssignableMembers() async {
    final roleId = _state.selectedRoleId;
    if (_isDisposed ||
        _currentContext == null ||
        roleId == null ||
        _state.isLoadingMoreAssignableMembers ||
        !_state.hasMoreAssignableMembers) {
      return;
    }

    final requestEpoch = _epoch;
    final requestGen = _assignableMembersGeneration;

    _state = _state.copyWith(isLoadingMoreAssignableMembers: true);
    _safeNotifyListeners();

    try {
      final page = await _administration.listAssignableMembershipsForRole
          .execute(
            context: _currentContext!,
            roleId: roleId,
            page: NexaBizAuthorizationAdministrationPageRequest(
              limit: _pageSize,
              cursor: _state.assignableMembersNextCursor,
            ),
            search: _state.assignableMembersSearchQuery,
          );

      if (_isDisposed ||
          requestEpoch != _epoch ||
          requestGen != _assignableMembersGeneration) {
        return;
      }

      final existing = List<NexaBizAssignableMembership>.from(
        _state.assignableMembers,
      );
      final existingIds = existing.map((m) => m.membershipId).toSet();

      for (final item in page.items) {
        if (!existingIds.contains(item.membershipId)) {
          existing.add(item);
        }
      }

      _state = _state.copyWith(
        assignableMembers: List.unmodifiable(existing),
        assignableMembersNextCursor: () => page.nextCursor,
        isLoadingMoreAssignableMembers: false,
      );
      _safeNotifyListeners();
    } catch (e) {
      if (_isDisposed ||
          requestEpoch != _epoch ||
          requestGen != _assignableMembersGeneration) {
        return;
      }

      _state = _state.copyWith(
        isLoadingMoreAssignableMembers: false,
        assignableMembersError: () =>
            NexaBizAuthorizationPresentationError(error: e, roleId: roleId),
      );
      _safeNotifyListeners();
    }
  }

  // =========================================================================
  // Role Mutations: Create, Update, Delete
  // =========================================================================

  Future<bool> createRole({
    required NexaBizRoleId roleId,
    required NexaBizRoleDisplayName displayName,
    String? description,
  }) async {
    if (_isDisposed || _currentContext == null || _state.isCreatingRole) {
      return false; // Prevent double submit
    }

    _state = _state.copyWith(isCreatingRole: true, mutationError: () => null);
    _safeNotifyListeners();

    try {
      final result = await _administration.createCompanyRole.execute(
        context: _currentContext!,
        roleId: roleId,
        metadata: NexaBizRoleMetadata(
          displayName: displayName,
          description: description,
        ),
      );

      final after = result.after;
      if (after != null) {
        final newSummary = NexaBizCompanyRoleSummary(
          companyId: after.companyId,
          roleId: after.roleId,
          metadata: after.metadata,
          kind: after.kind,
          membershipAssignmentCount: after.membershipAssignmentCount,
        );

        final updatedRoles = [newSummary, ..._state.roles];

        _state = _state.copyWith(
          roles: List.unmodifiable(updatedRoles),
          isCreatingRole: false,
          mutationError: () => null,
        );
        _safeNotifyListeners();

        await selectRole(roleId);
        return true;
      }

      _state = _state.copyWith(
        isCreatingRole: false,
        mutationError: () => null,
      );
      _safeNotifyListeners();
      return true;
    } catch (e) {
      _state = _state.copyWith(
        isCreatingRole: false,
        mutationError: () =>
            NexaBizAuthorizationPresentationError(error: e, roleId: roleId),
      );
      _safeNotifyListeners();
      return false;
    }
  }

  Future<bool> updateRoleMetadata({
    required NexaBizRoleId roleId,
    required NexaBizRoleDisplayName displayName,
    String? description,
  }) async {
    if (_isDisposed || _currentContext == null || _state.isUpdatingRole) {
      return false;
    }

    _state = _state.copyWith(isUpdatingRole: true, mutationError: () => null);
    _safeNotifyListeners();

    try {
      final result = await _administration.updateCompanyRoleMetadata.execute(
        context: _currentContext!,
        roleId: roleId,
        metadata: NexaBizRoleMetadata(
          displayName: displayName,
          description: description,
        ),
      );

      final after = result.after;
      if (after != null) {
        final updatedRoles = _state.roles.map((r) {
          if (r.roleId == roleId) {
            return NexaBizCompanyRoleSummary(
              companyId: after.companyId,
              roleId: after.roleId,
              metadata: after.metadata,
              kind: after.kind,
              membershipAssignmentCount: r.membershipAssignmentCount,
            );
          }
          return r;
        }).toList();

        NexaBizCompanyRoleDetails? updatedDetails = _state.selectedRoleDetails;
        if (_state.selectedRoleId == roleId && updatedDetails != null) {
          updatedDetails = NexaBizCompanyRoleDetails(
            companyId: after.companyId,
            roleId: after.roleId,
            metadata: after.metadata,
            kind: after.kind,
            membershipAssignmentCount: updatedDetails.membershipAssignmentCount,
            permissionAssignmentCount: updatedDetails.permissionAssignmentCount,
            createdAt: updatedDetails.createdAt,
            updatedAt: after.updatedAt,
          );
        }

        _state = _state.copyWith(
          roles: List.unmodifiable(updatedRoles),
          selectedRoleDetails: () => updatedDetails,
          isUpdatingRole: false,
          mutationError: () => null,
        );
        _safeNotifyListeners();
        return true;
      }

      _state = _state.copyWith(
        isUpdatingRole: false,
        mutationError: () => null,
      );
      _safeNotifyListeners();
      return true;
    } catch (e) {
      _state = _state.copyWith(
        isUpdatingRole: false,
        mutationError: () =>
            NexaBizAuthorizationPresentationError(error: e, roleId: roleId),
      );
      _safeNotifyListeners();
      return false;
    }
  }

  Future<bool> deleteRole(NexaBizRoleId roleId) async {
    if (_isDisposed || _currentContext == null || _state.isDeletingRole) {
      return false;
    }

    _state = _state.copyWith(isDeletingRole: true, mutationError: () => null);
    _safeNotifyListeners();

    try {
      await _administration.deleteCompanyRole.execute(
        context: _currentContext!,
        roleId: roleId,
      );

      final updatedRoles = _state.roles
          .where((r) => r.roleId != roleId)
          .toList();

      final wasSelected = _state.selectedRoleId == roleId;

      _state = _state.copyWith(
        roles: List.unmodifiable(updatedRoles),
        isDeletingRole: false,
        selectedRoleId: wasSelected ? () => null : null,
        selectedRoleSummary: wasSelected ? () => null : null,
        selectedRoleDetails: wasSelected ? () => null : null,
        selectedRolePermissions: wasSelected ? const [] : null,
        assignedMembers: wasSelected ? const [] : null,
        mutationError: () => null,
      );
      _safeNotifyListeners();
      return true;
    } catch (e) {
      _state = _state.copyWith(
        isDeletingRole: false,
        mutationError: () =>
            NexaBizAuthorizationPresentationError(error: e, roleId: roleId),
      );
      _safeNotifyListeners();
      return false;
    }
  }

  // =========================================================================
  // Permission Grant / Revoke
  // =========================================================================

  Future<bool> grantPermission(NexaBizPermissionId permissionId) async {
    final roleId = _state.selectedRoleId;
    if (_isDisposed ||
        _currentContext == null ||
        roleId == null ||
        _state.isPermissionPending(permissionId)) {
      return false; // Sequencing guard
    }

    final newPending = Set<NexaBizPermissionId>.from(
      _state.pendingPermissionIds,
    )..add(permissionId);

    _state = _state.copyWith(
      pendingPermissionIds: newPending,
      mutationError: () => null,
    );
    _safeNotifyListeners();

    try {
      await _administration.grantPermissionToRole.execute(
        context: _currentContext!,
        roleId: roleId,
        permissionId: permissionId,
      );

      final updatedPermissions = _state.selectedRolePermissions.map((item) {
        if (item.permissionId == permissionId) {
          return item.copyWith(isGranted: true, isPending: false);
        }
        return item;
      }).toList();

      final pendingAfter = Set<NexaBizPermissionId>.from(
        _state.pendingPermissionIds,
      )..remove(permissionId);

      NexaBizCompanyRoleDetails? updatedDetails = _state.selectedRoleDetails;
      if (updatedDetails != null) {
        final newCount = updatedPermissions.where((p) => p.isGranted).length;
        updatedDetails = NexaBizCompanyRoleDetails(
          companyId: updatedDetails.companyId,
          roleId: updatedDetails.roleId,
          metadata: updatedDetails.metadata,
          kind: updatedDetails.kind,
          membershipAssignmentCount: updatedDetails.membershipAssignmentCount,
          permissionAssignmentCount: newCount,
          createdAt: updatedDetails.createdAt,
          updatedAt: updatedDetails.updatedAt,
        );
      }

      _state = _state.copyWith(
        selectedRolePermissions: List.unmodifiable(updatedPermissions),
        pendingPermissionIds: pendingAfter,
        selectedRoleDetails: () => updatedDetails,
        mutationError: () => null,
      );
      _safeNotifyListeners();
      return true;
    } catch (e) {
      final pendingAfter = Set<NexaBizPermissionId>.from(
        _state.pendingPermissionIds,
      )..remove(permissionId);

      _state = _state.copyWith(
        pendingPermissionIds: pendingAfter,
        mutationError: () =>
            NexaBizAuthorizationPresentationError(error: e, roleId: roleId),
      );
      _safeNotifyListeners();
      return false;
    }
  }

  Future<bool> revokePermission(NexaBizPermissionId permissionId) async {
    final roleId = _state.selectedRoleId;
    if (_isDisposed ||
        _currentContext == null ||
        roleId == null ||
        _state.isPermissionPending(permissionId)) {
      return false;
    }

    final newPending = Set<NexaBizPermissionId>.from(
      _state.pendingPermissionIds,
    )..add(permissionId);

    _state = _state.copyWith(
      pendingPermissionIds: newPending,
      mutationError: () => null,
    );
    _safeNotifyListeners();

    try {
      await _administration.revokePermissionFromRole.execute(
        context: _currentContext!,
        roleId: roleId,
        permissionId: permissionId,
      );

      final updatedPermissions = _state.selectedRolePermissions.map((item) {
        if (item.permissionId == permissionId) {
          return item.copyWith(isGranted: false, isPending: false);
        }
        return item;
      }).toList();

      final pendingAfter = Set<NexaBizPermissionId>.from(
        _state.pendingPermissionIds,
      )..remove(permissionId);

      NexaBizCompanyRoleDetails? updatedDetails = _state.selectedRoleDetails;
      if (updatedDetails != null) {
        final newCount = updatedPermissions.where((p) => p.isGranted).length;
        updatedDetails = NexaBizCompanyRoleDetails(
          companyId: updatedDetails.companyId,
          roleId: updatedDetails.roleId,
          metadata: updatedDetails.metadata,
          kind: updatedDetails.kind,
          membershipAssignmentCount: updatedDetails.membershipAssignmentCount,
          permissionAssignmentCount: newCount,
          createdAt: updatedDetails.createdAt,
          updatedAt: updatedDetails.updatedAt,
        );
      }

      _state = _state.copyWith(
        selectedRolePermissions: List.unmodifiable(updatedPermissions),
        pendingPermissionIds: pendingAfter,
        selectedRoleDetails: () => updatedDetails,
        mutationError: () => null,
      );
      _safeNotifyListeners();
      return true;
    } catch (e) {
      final pendingAfter = Set<NexaBizPermissionId>.from(
        _state.pendingPermissionIds,
      )..remove(permissionId);

      _state = _state.copyWith(
        pendingPermissionIds: pendingAfter,
        mutationError: () =>
            NexaBizAuthorizationPresentationError(error: e, roleId: roleId),
      );
      _safeNotifyListeners();
      return false;
    }
  }

  // =========================================================================
  // Member Assignment / Unassignment
  // =========================================================================

  Future<bool> assignMember(NexaBizMembershipId membershipId) async {
    final roleId = _state.selectedRoleId;
    if (_isDisposed ||
        _currentContext == null ||
        roleId == null ||
        _state.isMembershipPending(membershipId)) {
      return false; // Sequencing guard
    }

    final newPending = Set<NexaBizMembershipId>.from(
      _state.pendingMembershipIds,
    )..add(membershipId);

    _state = _state.copyWith(
      pendingMembershipIds: newPending,
      mutationError: () => null,
    );
    _safeNotifyListeners();

    try {
      await _administration.assignRoleToMembership.execute(
        context: _currentContext!,
        roleId: roleId,
        membershipId: membershipId,
      );

      final updatedCandidates = _state.assignableMembers
          .where((m) => m.membershipId != membershipId)
          .toList();

      final pendingAfter = Set<NexaBizMembershipId>.from(
        _state.pendingMembershipIds,
      )..remove(membershipId);

      _state = _state.copyWith(
        assignableMembers: List.unmodifiable(updatedCandidates),
        pendingMembershipIds: pendingAfter,
        mutationError: () => null,
      );
      _safeNotifyListeners();

      // Refresh assigned members to obtain enriched projection
      await _refreshAssignedMembersSilently(roleId);
      return true;
    } catch (e) {
      final pendingAfter = Set<NexaBizMembershipId>.from(
        _state.pendingMembershipIds,
      )..remove(membershipId);

      _state = _state.copyWith(
        pendingMembershipIds: pendingAfter,
        mutationError: () => NexaBizAuthorizationPresentationError(
          error: e,
          roleId: roleId,
          membershipId: membershipId,
        ),
      );
      _safeNotifyListeners();
      return false;
    }
  }

  Future<bool> unassignMember(NexaBizMembershipId membershipId) async {
    final roleId = _state.selectedRoleId;
    if (_isDisposed ||
        _currentContext == null ||
        roleId == null ||
        _state.isMembershipPending(membershipId)) {
      return false;
    }

    final newPending = Set<NexaBizMembershipId>.from(
      _state.pendingMembershipIds,
    )..add(membershipId);

    _state = _state.copyWith(
      pendingMembershipIds: newPending,
      mutationError: () => null,
    );
    _safeNotifyListeners();

    try {
      await _administration.unassignRoleFromMembership.execute(
        context: _currentContext!,
        roleId: roleId,
        membershipId: membershipId,
      );

      final updatedMembers = _state.assignedMembers
          .where((m) => m.membershipId != membershipId)
          .toList();

      final pendingAfter = Set<NexaBizMembershipId>.from(
        _state.pendingMembershipIds,
      )..remove(membershipId);

      _state = _state.copyWith(
        assignedMembers: List.unmodifiable(updatedMembers),
        pendingMembershipIds: pendingAfter,
        mutationError: () => null,
      );
      _safeNotifyListeners();

      // Update assignment count in details and summary
      _updateMembershipCount(roleId, updatedMembers.length);
      return true;
    } catch (e) {
      final pendingAfter = Set<NexaBizMembershipId>.from(
        _state.pendingMembershipIds,
      )..remove(membershipId);

      // On failure (e.g. Last Owner protected), member remains assigned
      _state = _state.copyWith(
        pendingMembershipIds: pendingAfter,
        mutationError: () => NexaBizAuthorizationPresentationError(
          error: e,
          roleId: roleId,
          membershipId: membershipId,
        ),
      );
      _safeNotifyListeners();
      return false;
    }
  }

  Future<void> _refreshAssignedMembersSilently(NexaBizRoleId roleId) async {
    if (_currentContext == null) return;
    try {
      final page = await _administration.listMembershipsAssignedToRole.execute(
        context: _currentContext!,
        roleId: roleId,
        page: NexaBizAuthorizationAdministrationPageRequest(limit: _pageSize),
      );
      _state = _state.copyWith(
        assignedMembers: List.unmodifiable(page.items),
        assignedMembersNextCursor: () => page.nextCursor,
      );
      _updateMembershipCount(roleId, page.items.length);
      _safeNotifyListeners();
    } catch (_) {}
  }

  void _updateMembershipCount(NexaBizRoleId roleId, int newCount) {
    NexaBizCompanyRoleDetails? updatedDetails = _state.selectedRoleDetails;
    if (_state.selectedRoleId == roleId && updatedDetails != null) {
      updatedDetails = NexaBizCompanyRoleDetails(
        companyId: updatedDetails.companyId,
        roleId: updatedDetails.roleId,
        metadata: updatedDetails.metadata,
        kind: updatedDetails.kind,
        membershipAssignmentCount: newCount,
        permissionAssignmentCount: updatedDetails.permissionAssignmentCount,
        createdAt: updatedDetails.createdAt,
        updatedAt: updatedDetails.updatedAt,
      );
    }

    final updatedRoles = _state.roles.map((r) {
      if (r.roleId == roleId) {
        return NexaBizCompanyRoleSummary(
          companyId: r.companyId,
          roleId: r.roleId,
          metadata: r.metadata,
          kind: r.kind,
          membershipAssignmentCount: newCount,
        );
      }
      return r;
    }).toList();

    _state = _state.copyWith(
      roles: List.unmodifiable(updatedRoles),
      selectedRoleDetails: () => updatedDetails,
    );
  }

  void clearMutationError() {
    if (_isDisposed) return;
    _state = _state.copyWith(mutationError: () => null);
    _safeNotifyListeners();
  }

  void clearErrors() {
    if (_isDisposed) return;
    _state = _state.copyWith(
      rolesError: () => null,
      catalogError: () => null,
      roleDetailsError: () => null,
      assignedMembersError: () => null,
      assignableMembersError: () => null,
      mutationError: () => null,
    );
    _safeNotifyListeners();
  }

  @override
  void dispose() {
    if (_isDisposed) return;
    _isDisposed = true;
    _sessionSubscription?.cancel();
    _sessionSubscription = null;
    if (_invalidationSignal != null) {
      _invalidationSignal.removeListener(_handleInvalidationSignal);
    }
    super.dispose();
  }
}
