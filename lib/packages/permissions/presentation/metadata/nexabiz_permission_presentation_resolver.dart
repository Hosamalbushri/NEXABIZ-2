import '../../../../core/authorization/administration/nexabiz_authorization_administration_permissions.dart';
import '../../../../core/permissions/nexabiz_permission_intent.dart';
import '../../../../l10n/app_localizations.dart';
import 'nexabiz_permission_presentation_models.dart';

/// Single presentation authority responsible for mapping `NexaBizPermissionId`
/// to localized, human-friendly presentation metadata.
///
/// ARCHITECTURAL PRINCIPLES:
/// 1. NOT a security authority: `NexaBizPermissionId` remains the sole security identity,
///    and `NexaBizCapabilityRegistry` remains the sole declaration authority.
/// 2. Fail-safe unknown fallback: Any future or undeclared permission returned by a
///    capability is mapped cleanly into `NexaBizPermissionPresentationGroup.other`
///    without throwing or crashing the UI.
/// 3. Deterministic presentation ordering: Permissions and groups are ordered by
///    canonical system design rather than alphabetical translation accident.
final class NexaBizPermissionPresentationResolver {
  const NexaBizPermissionPresentationResolver();

  static final Map<String, NexaBizPermissionPresentationDescriptor>
  _explicitDescriptors = {
    // 1. Company Workspace Group
    'company.profile.view': NexaBizPermissionPresentationDescriptor(
      permissionId: NexaBizPermissionId('company.profile.view'),
      group: NexaBizPermissionPresentationGroup.company,
      sortOrder: 0,
      titleResolver: (l10n) => l10n.authAdminPermCompanyProfileViewTitle,
      descriptionResolver: (l10n) => l10n.authAdminPermCompanyProfileViewDesc,
    ),
    'company.profile.manage': NexaBizPermissionPresentationDescriptor(
      permissionId: NexaBizPermissionId('company.profile.manage'),
      group: NexaBizPermissionPresentationGroup.company,
      sortOrder: 1,
      titleResolver: (l10n) => l10n.authAdminPermCompanyProfileManageTitle,
      descriptionResolver: (l10n) => l10n.authAdminPermCompanyProfileManageDesc,
    ),
    'company.membership.view': NexaBizPermissionPresentationDescriptor(
      permissionId: NexaBizPermissionId('company.membership.view'),
      group: NexaBizPermissionPresentationGroup.company,
      sortOrder: 2,
      titleResolver: (l10n) => l10n.authAdminPermCompanyMembershipViewTitle,
      descriptionResolver: (l10n) =>
          l10n.authAdminPermCompanyMembershipViewDesc,
    ),

    // 2. Identity & Users Group
    'identity.session.view': NexaBizPermissionPresentationDescriptor(
      permissionId: NexaBizPermissionId('identity.session.view'),
      group: NexaBizPermissionPresentationGroup.identity,
      sortOrder: 0,
      titleResolver: (l10n) => l10n.authAdminPermIdentitySessionViewTitle,
      descriptionResolver: (l10n) => l10n.authAdminPermIdentitySessionViewDesc,
    ),
    'identity.user.manage': NexaBizPermissionPresentationDescriptor(
      permissionId: NexaBizPermissionId('identity.user.manage'),
      group: NexaBizPermissionPresentationGroup.identity,
      sortOrder: 1,
      titleResolver: (l10n) => l10n.authAdminPermIdentityUserManageTitle,
      descriptionResolver: (l10n) => l10n.authAdminPermIdentityUserManageDesc,
    ),

    // 3. Authorization / Access Control Group
    'permissions.catalog.view': NexaBizPermissionPresentationDescriptor(
      permissionId: NexaBizAuthorizationAdministrationPermissions.catalogView,
      group: NexaBizPermissionPresentationGroup.authorization,
      sortOrder: 0,
      titleResolver: (l10n) => l10n.authAdminPermCatalogViewTitle,
      descriptionResolver: (l10n) => l10n.authAdminPermCatalogViewDesc,
    ),
    'permissions.policy.review': NexaBizPermissionPresentationDescriptor(
      permissionId: NexaBizAuthorizationAdministrationPermissions.policyReview,
      group: NexaBizPermissionPresentationGroup.authorization,
      sortOrder: 1,
      titleResolver: (l10n) => l10n.authAdminPermPolicyReviewTitle,
      descriptionResolver: (l10n) => l10n.authAdminPermPolicyReviewDesc,
    ),
    'permissions.role.manage': NexaBizPermissionPresentationDescriptor(
      permissionId: NexaBizAuthorizationAdministrationPermissions.roleManage,
      group: NexaBizPermissionPresentationGroup.authorization,
      sortOrder: 2,
      titleResolver: (l10n) => l10n.authAdminPermRoleManageTitle,
      descriptionResolver: (l10n) => l10n.authAdminPermRoleManageDesc,
    ),
    'permissions.policy.manage': NexaBizPermissionPresentationDescriptor(
      permissionId: NexaBizAuthorizationAdministrationPermissions.policyManage,
      group: NexaBizPermissionPresentationGroup.authorization,
      sortOrder: 3,
      titleResolver: (l10n) => l10n.authAdminPermPolicyManageTitle,
      descriptionResolver: (l10n) => l10n.authAdminPermPolicyManageDesc,
    ),
    'permissions.assignment.manage': NexaBizPermissionPresentationDescriptor(
      permissionId:
          NexaBizAuthorizationAdministrationPermissions.assignmentManage,
      group: NexaBizPermissionPresentationGroup.authorization,
      sortOrder: 4,
      titleResolver: (l10n) => l10n.authAdminPermAssignmentManageTitle,
      descriptionResolver: (l10n) => l10n.authAdminPermAssignmentManageDesc,
    ),
  };

  /// Set of all canonical permission IDs with explicit metadata registered.
  static Set<String> get registeredExplicitPermissionIds =>
      _explicitDescriptors.keys.toSet();

  /// Obtains the presentation descriptor for [permissionId].
  ///
  /// If the permission is not recognized in the canonical descriptor catalog,
  /// returns a safe fallback descriptor in [NexaBizPermissionPresentationGroup.other]
  /// preserving the canonical identifier without throwing.
  NexaBizPermissionPresentationDescriptor describe(
    NexaBizPermissionId permissionId,
  ) {
    final existing = _explicitDescriptors[permissionId.value];
    if (existing != null) return existing;

    return NexaBizPermissionPresentationDescriptor(
      permissionId: permissionId,
      group: NexaBizPermissionPresentationGroup.other,
      sortOrder: 999,
      isExplicit: false,
      titleResolver: (_) => permissionId.value,
      descriptionResolver: (l10n) =>
          l10n.authAdminUnknownPermissionDesc(permissionId.value),
    );
  }

  /// Resolves the presentation metadata for a single [permissionId] into a localized model.
  NexaBizResolvedPermissionPresentation resolve({
    required NexaBizPermissionId permissionId,
    required AppLocalizations l10n,
  }) {
    final descriptor = describe(permissionId);
    return NexaBizResolvedPermissionPresentation(
      permissionId: descriptor.permissionId,
      group: descriptor.group,
      groupTitle: descriptor.group.resolveTitle(l10n),
      title: descriptor.resolveTitle(l10n),
      description: descriptor.resolveDescription(l10n),
      sortOrder: descriptor.sortOrder,
      isExplicit: descriptor.isExplicit,
    );
  }

  /// Resolves and deterministically sorts an arbitrary collection of permission IDs.
  ///
  /// Order is guaranteed by:
  /// 1. Group presentation order (`group.order`)
  /// 2. Within-group sort order (`descriptor.sortOrder`)
  /// 3. Canonical ID tie-breaker (`permissionId.value`)
  List<NexaBizResolvedPermissionPresentation> resolveCatalog({
    required Iterable<NexaBizPermissionId> permissionIds,
    required AppLocalizations l10n,
  }) {
    final resolvedList = permissionIds
        .map((id) => resolve(permissionId: id, l10n: l10n))
        .toList();

    resolvedList.sort((a, b) {
      final groupComparison = a.group.order.compareTo(b.group.order);
      if (groupComparison != 0) return groupComparison;

      final sortOrderComparison = a.sortOrder.compareTo(b.sortOrder);
      if (sortOrderComparison != 0) return sortOrderComparison;

      return a.permissionId.value.compareTo(b.permissionId.value);
    });

    return List.unmodifiable(resolvedList);
  }
}
