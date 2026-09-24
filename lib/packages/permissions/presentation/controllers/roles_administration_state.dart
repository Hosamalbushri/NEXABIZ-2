import '../../../../core/authorization/administration/nexabiz_authorization_administration_models.dart';
import '../../../../core/authorization/nexabiz_membership_id.dart';
import '../../../../core/company/nexabiz_company_scope.dart';
import '../../../../core/permissions/nexabiz_permission_intent.dart';
import '../../../../core/roles/nexabiz_role_id.dart';
import '../../../../l10n/app_localizations.dart';
import '../metadata/nexabiz_authorization_presentation_error_mapper.dart';
import '../metadata/nexabiz_permission_presentation_models.dart';

/// Presentation representation of a permission row for role inspection and grant toggling.
///
/// Holds stable, language-neutral presentation descriptors without hardcoding localized strings.
final class NexaBizRolePermissionItem {
  const NexaBizRolePermissionItem({
    required this.descriptor,
    required this.isGranted,
    required this.isPending,
  });

  final NexaBizPermissionPresentationDescriptor descriptor;
  final bool isGranted;
  final bool isPending;

  NexaBizPermissionId get permissionId => descriptor.permissionId;
  NexaBizPermissionPresentationGroup get group => descriptor.group;
  int get sortOrder => descriptor.sortOrder;
  bool get isExplicit => descriptor.isExplicit;

  String resolveTitle(AppLocalizations l10n) => descriptor.resolveTitle(l10n);
  String resolveDescription(AppLocalizations l10n) =>
      descriptor.resolveDescription(l10n);

  NexaBizRolePermissionItem copyWith({bool? isGranted, bool? isPending}) {
    return NexaBizRolePermissionItem(
      descriptor: descriptor,
      isGranted: isGranted ?? this.isGranted,
      isPending: isPending ?? this.isPending,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NexaBizRolePermissionItem &&
          descriptor.permissionId == other.descriptor.permissionId &&
          isGranted == other.isGranted &&
          isPending == other.isPending;

  @override
  int get hashCode =>
      Object.hash(descriptor.permissionId, isGranted, isPending);
}

/// Language-neutral typed presentation error descriptor.
///
/// Wraps the underlying domain/persistence exception and maps to localized messages
/// on demand during widget rendering via [resolveMessage], preventing stale string state
/// across locale switches.
final class NexaBizAuthorizationPresentationError {
  const NexaBizAuthorizationPresentationError({
    required this.error,
    this.roleId,
    this.permissionId,
    this.membershipId,
  });

  final Object error;
  final NexaBizRoleId? roleId;
  final NexaBizPermissionId? permissionId;
  final NexaBizMembershipId? membershipId;

  String resolveMessage(
    AppLocalizations l10n, {
    NexaBizAuthorizationPresentationErrorMapper mapper =
        const NexaBizAuthorizationPresentationErrorMapper(),
  }) {
    return mapper.mapError(error: error, l10n: l10n);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NexaBizAuthorizationPresentationError &&
          error == other.error &&
          roleId == other.roleId &&
          permissionId == other.permissionId &&
          membershipId == other.membershipId;

  @override
  int get hashCode => Object.hash(error, roleId, permissionId, membershipId);
}

/// Immutable Presentation State for Roles Administration.
///
/// Encapsulates all role listing, selection, details, permission catalog,
/// membership assignments, and candidate assignment states with granular loading flags.
final class RolesAdministrationState {
  const RolesAdministrationState({
    required this.companyId,
    required this.isInitialized,
    required this.roles,
    required this.rolesNextCursor,
    required this.isLoadingRoles,
    required this.isLoadingMoreRoles,
    required this.roleSearchQuery,
    required this.roleKindFilter,
    required this.rolesError,
    required this.declaredCatalog,
    required this.isLoadingCatalog,
    required this.catalogError,
    required this.selectedRoleId,
    required this.selectedRoleSummary,
    required this.selectedRoleDetails,
    required this.selectedRolePermissions,
    required this.isLoadingRoleDetails,
    required this.isLoadingRolePermissions,
    required this.roleDetailsError,
    required this.assignedMembers,
    required this.assignedMembersNextCursor,
    required this.isLoadingAssignedMembers,
    required this.isLoadingMoreAssignedMembers,
    required this.assignedMembersError,
    required this.assignableMembers,
    required this.assignableMembersNextCursor,
    required this.assignableMembersSearchQuery,
    required this.isLoadingAssignableMembers,
    required this.isLoadingMoreAssignableMembers,
    required this.assignableMembersError,
    required this.isCreatingRole,
    required this.isUpdatingRole,
    required this.isDeletingRole,
    required this.pendingPermissionIds,
    required this.pendingMembershipIds,
    required this.mutationError,
  });

  factory RolesAdministrationState.initial({NexaBizCompanyId? companyId}) {
    return RolesAdministrationState(
      companyId: companyId,
      isInitialized: false,
      roles: const [],
      rolesNextCursor: null,
      isLoadingRoles: false,
      isLoadingMoreRoles: false,
      roleSearchQuery: null,
      roleKindFilter: null,
      rolesError: null,
      declaredCatalog: const [],
      isLoadingCatalog: false,
      catalogError: null,
      selectedRoleId: null,
      selectedRoleSummary: null,
      selectedRoleDetails: null,
      selectedRolePermissions: const [],
      isLoadingRoleDetails: false,
      isLoadingRolePermissions: false,
      roleDetailsError: null,
      assignedMembers: const [],
      assignedMembersNextCursor: null,
      isLoadingAssignedMembers: false,
      isLoadingMoreAssignedMembers: false,
      assignedMembersError: null,
      assignableMembers: const [],
      assignableMembersNextCursor: null,
      assignableMembersSearchQuery: null,
      isLoadingAssignableMembers: false,
      isLoadingMoreAssignableMembers: false,
      assignableMembersError: null,
      isCreatingRole: false,
      isUpdatingRole: false,
      isDeletingRole: false,
      pendingPermissionIds: const {},
      pendingMembershipIds: const {},
      mutationError: null,
    );
  }

  // Active Company Tenant Scope
  final NexaBizCompanyId? companyId;
  final bool isInitialized;

  // Roles Listing
  final List<NexaBizCompanyRoleSummary> roles;
  final String? rolesNextCursor;
  final bool isLoadingRoles;
  final bool isLoadingMoreRoles;
  final String? roleSearchQuery;
  final NexaBizCompanyRoleKind? roleKindFilter;
  final NexaBizAuthorizationPresentationError? rolesError;

  bool get hasMoreRoles => rolesNextCursor != null;

  // Declared Permission Catalog
  final List<NexaBizPermissionPresentationDescriptor> declaredCatalog;
  final bool isLoadingCatalog;
  final NexaBizAuthorizationPresentationError? catalogError;

  bool get isCatalogLoaded => declaredCatalog.isNotEmpty;

  // Selected Role & Details
  final NexaBizRoleId? selectedRoleId;
  final NexaBizCompanyRoleSummary? selectedRoleSummary;
  final NexaBizCompanyRoleDetails? selectedRoleDetails;
  final List<NexaBizRolePermissionItem> selectedRolePermissions;
  final bool isLoadingRoleDetails;
  final bool isLoadingRolePermissions;
  final NexaBizAuthorizationPresentationError? roleDetailsError;

  bool get hasSelectedRole => selectedRoleId != null;

  // Assigned Memberships
  final List<NexaBizMembershipRoleAssignment> assignedMembers;
  final String? assignedMembersNextCursor;
  final bool isLoadingAssignedMembers;
  final bool isLoadingMoreAssignedMembers;
  final NexaBizAuthorizationPresentationError? assignedMembersError;

  bool get hasMoreAssignedMembers => assignedMembersNextCursor != null;

  // Assignable Candidate Memberships
  final List<NexaBizAssignableMembership> assignableMembers;
  final String? assignableMembersNextCursor;
  final String? assignableMembersSearchQuery;
  final bool isLoadingAssignableMembers;
  final bool isLoadingMoreAssignableMembers;
  final NexaBizAuthorizationPresentationError? assignableMembersError;

  bool get hasMoreAssignableMembers => assignableMembersNextCursor != null;

  // Mutation Pending States
  final bool isCreatingRole;
  final bool isUpdatingRole;
  final bool isDeletingRole;
  final Set<NexaBizPermissionId> pendingPermissionIds;
  final Set<NexaBizMembershipId> pendingMembershipIds;
  final NexaBizAuthorizationPresentationError? mutationError;

  bool isPermissionPending(NexaBizPermissionId id) =>
      pendingPermissionIds.contains(id);

  bool isMembershipPending(NexaBizMembershipId id) =>
      pendingMembershipIds.contains(id);

  bool isPermissionGranted(NexaBizPermissionId id) => selectedRolePermissions
      .any((item) => item.permissionId == id && item.isGranted);

  RolesAdministrationState copyWith({
    NexaBizCompanyId? companyId,
    bool? isInitialized,
    List<NexaBizCompanyRoleSummary>? roles,
    String? Function()? rolesNextCursor,
    bool? isLoadingRoles,
    bool? isLoadingMoreRoles,
    String? Function()? roleSearchQuery,
    NexaBizCompanyRoleKind? Function()? roleKindFilter,
    NexaBizAuthorizationPresentationError? Function()? rolesError,
    List<NexaBizPermissionPresentationDescriptor>? declaredCatalog,
    bool? isLoadingCatalog,
    NexaBizAuthorizationPresentationError? Function()? catalogError,
    NexaBizRoleId? Function()? selectedRoleId,
    NexaBizCompanyRoleSummary? Function()? selectedRoleSummary,
    NexaBizCompanyRoleDetails? Function()? selectedRoleDetails,
    List<NexaBizRolePermissionItem>? selectedRolePermissions,
    bool? isLoadingRoleDetails,
    bool? isLoadingRolePermissions,
    NexaBizAuthorizationPresentationError? Function()? roleDetailsError,
    List<NexaBizMembershipRoleAssignment>? assignedMembers,
    String? Function()? assignedMembersNextCursor,
    bool? isLoadingAssignedMembers,
    bool? isLoadingMoreAssignedMembers,
    NexaBizAuthorizationPresentationError? Function()? assignedMembersError,
    List<NexaBizAssignableMembership>? assignableMembers,
    String? Function()? assignableMembersNextCursor,
    String? Function()? assignableMembersSearchQuery,
    bool? isLoadingAssignableMembers,
    bool? isLoadingMoreAssignableMembers,
    NexaBizAuthorizationPresentationError? Function()? assignableMembersError,
    bool? isCreatingRole,
    bool? isUpdatingRole,
    bool? isDeletingRole,
    Set<NexaBizPermissionId>? pendingPermissionIds,
    Set<NexaBizMembershipId>? pendingMembershipIds,
    NexaBizAuthorizationPresentationError? Function()? mutationError,
  }) {
    return RolesAdministrationState(
      companyId: companyId ?? this.companyId,
      isInitialized: isInitialized ?? this.isInitialized,
      roles: roles ?? this.roles,
      rolesNextCursor: rolesNextCursor != null
          ? rolesNextCursor()
          : this.rolesNextCursor,
      isLoadingRoles: isLoadingRoles ?? this.isLoadingRoles,
      isLoadingMoreRoles: isLoadingMoreRoles ?? this.isLoadingMoreRoles,
      roleSearchQuery: roleSearchQuery != null
          ? roleSearchQuery()
          : this.roleSearchQuery,
      roleKindFilter: roleKindFilter != null
          ? roleKindFilter()
          : this.roleKindFilter,
      rolesError: rolesError != null ? rolesError() : this.rolesError,
      declaredCatalog: declaredCatalog ?? this.declaredCatalog,
      isLoadingCatalog: isLoadingCatalog ?? this.isLoadingCatalog,
      catalogError: catalogError != null ? catalogError() : this.catalogError,
      selectedRoleId: selectedRoleId != null
          ? selectedRoleId()
          : this.selectedRoleId,
      selectedRoleSummary: selectedRoleSummary != null
          ? selectedRoleSummary()
          : this.selectedRoleSummary,
      selectedRoleDetails: selectedRoleDetails != null
          ? selectedRoleDetails()
          : this.selectedRoleDetails,
      selectedRolePermissions:
          selectedRolePermissions ?? this.selectedRolePermissions,
      isLoadingRoleDetails: isLoadingRoleDetails ?? this.isLoadingRoleDetails,
      isLoadingRolePermissions:
          isLoadingRolePermissions ?? this.isLoadingRolePermissions,
      roleDetailsError: roleDetailsError != null
          ? roleDetailsError()
          : this.roleDetailsError,
      assignedMembers: assignedMembers ?? this.assignedMembers,
      assignedMembersNextCursor: assignedMembersNextCursor != null
          ? assignedMembersNextCursor()
          : this.assignedMembersNextCursor,
      isLoadingAssignedMembers:
          isLoadingAssignedMembers ?? this.isLoadingAssignedMembers,
      isLoadingMoreAssignedMembers:
          isLoadingMoreAssignedMembers ?? this.isLoadingMoreAssignedMembers,
      assignedMembersError: assignedMembersError != null
          ? assignedMembersError()
          : this.assignedMembersError,
      assignableMembers: assignableMembers ?? this.assignableMembers,
      assignableMembersNextCursor: assignableMembersNextCursor != null
          ? assignableMembersNextCursor()
          : this.assignableMembersNextCursor,
      assignableMembersSearchQuery: assignableMembersSearchQuery != null
          ? assignableMembersSearchQuery()
          : this.assignableMembersSearchQuery,
      isLoadingAssignableMembers:
          isLoadingAssignableMembers ?? this.isLoadingAssignableMembers,
      isLoadingMoreAssignableMembers:
          isLoadingMoreAssignableMembers ?? this.isLoadingMoreAssignableMembers,
      assignableMembersError: assignableMembersError != null
          ? assignableMembersError()
          : this.assignableMembersError,
      isCreatingRole: isCreatingRole ?? this.isCreatingRole,
      isUpdatingRole: isUpdatingRole ?? this.isUpdatingRole,
      isDeletingRole: isDeletingRole ?? this.isDeletingRole,
      pendingPermissionIds: pendingPermissionIds ?? this.pendingPermissionIds,
      pendingMembershipIds: pendingMembershipIds ?? this.pendingMembershipIds,
      mutationError: mutationError != null
          ? mutationError()
          : this.mutationError,
    );
  }
}
