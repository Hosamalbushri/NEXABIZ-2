import 'package:flutter/widgets.dart';
import 'package:nexabiz_ui/nexabiz_ui.dart';

import '../../../app/authorization/app_permission_scope.dart';
import '../../../app/authorization/nexabiz_authorization_invalidation_signal.dart';
import '../../../core/authorization/administration/nexabiz_authorization_administration_models.dart';
import '../../../core/roles/nexabiz_role_id.dart';
import '../../../l10n/app_localizations.dart';
import 'controllers/roles_administration_controller.dart';
import 'controllers/roles_administration_state.dart';
import 'metadata/nexabiz_permission_presentation_models.dart';

/// Canonical Roles Administration Screen — Strict Read-Only Mode.
///
/// Implements master-detail inspection of company roles, metadata,
/// permission assignments, and assigned company members.
///
/// Adheres to:
/// - `AGENTS.md` and repository architectural contracts.
/// - Single-flight invalidation and race safety via [RolesAdministrationController].
/// - Strict Read-Only: Zero mutation buttons, dialogs, sheets, or toggles.
class RolesScreen extends StatefulWidget {
  const RolesScreen({super.key, this.controller});

  /// Optional injected controller for testing and isolation.
  final RolesAdministrationController? controller;

  @override
  State<RolesScreen> createState() => _RolesScreenState();
}

class _RolesScreenState extends State<RolesScreen> {
  RolesAdministrationController? _controller;
  bool _ownsController = false;
  bool _showDetailOnCompact = false;
  int _selectedTabIndex = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_controller == null) {
      if (widget.controller != null) {
        _controller = widget.controller;
        _ownsController = false;
      } else {
        final scope = AppPermissionScope.of(context);
        final adminFacade = scope.authorizationAdministration;
        if (adminFacade != null) {
          _controller = RolesAdministrationController(
            administration: adminFacade,
            sessionController: scope.sessionController,
            invalidationSignal:
                scope.invalidationSignal
                    as NexaBizAuthorizationInvalidationSignal?,
          )..initialize();
          _ownsController = true;
        }
      }
      _controller?.addListener(_onControllerChanged);
    }
  }

  @override
  void didUpdateWidget(RolesScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != null && widget.controller != _controller) {
      if (_ownsController) {
        _controller?.removeListener(_onControllerChanged);
        _controller?.dispose();
      } else {
        _controller?.removeListener(_onControllerChanged);
      }
      _controller = widget.controller;
      _ownsController = false;
      _controller?.addListener(_onControllerChanged);
    }
  }

  void _onControllerChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _controller?.removeListener(_onControllerChanged);
    if (_ownsController) {
      _controller?.dispose();
    }
    super.dispose();
  }

  void _handleRoleSelected(NexaBizRoleId roleId) {
    _controller?.selectRole(roleId);
    setState(() {
      _showDetailOnCompact = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final controller = _controller;
    if (controller == null) {
      return AppPage(
        maxWidth: AppLayoutTokens.maxPageWidth,
        scrollable: false,
        child: const Center(child: AppLoading()),
      );
    }

    final state = controller.state;

    return AppMasterDetailPage(
      title: l10n.authAdminPageTitle,
      subtitle: l10n.authAdminPageSubtitle,
      masterWidth: 380.0,
      showDetailOnCompact: _showDetailOnCompact,
      collapseOnMedium: true,
      master: _buildMasterList(context, l10n, controller, state),
      detail: _buildDetailView(context, l10n, controller, state),
    );
  }

  Widget _buildMasterList(
    BuildContext context,
    AppLocalizations l10n,
    RolesAdministrationController controller,
    RolesAdministrationState state,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. Search Bar
        AppSearchField(
          hint: l10n.authAdminSearchRolesPlaceholder,
          onChanged: (query) => controller.searchRoles(query),
        ),
        const SizedBox(height: AppSpacing.sm),

        // 2. Role Kind Filter Options
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: AppExclusiveToggleGroup<NexaBizCompanyRoleKind?>(
            value: state.roleKindFilter,
            onChanged: (kind) => controller.filterRoleKind(kind),
            options: [
              ToggleOption(
                value: null,
                child: Text(
                  l10n.authAdminFilterAllRoles,
                  style: const TextStyle(fontSize: 12),
                ),
              ),
              ToggleOption(
                value: NexaBizCompanyRoleKind.builtIn,
                child: Text(
                  l10n.authAdminFilterBuiltInRoles,
                  style: const TextStyle(fontSize: 12),
                ),
              ),
              ToggleOption(
                value: NexaBizCompanyRoleKind.custom,
                child: Text(
                  l10n.authAdminFilterCustomRoles,
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        // 3. Role List Content
        Expanded(
          child: _buildRoleListContent(context, l10n, controller, state),
        ),
      ],
    );
  }

  Widget _buildRoleListContent(
    BuildContext context,
    AppLocalizations l10n,
    RolesAdministrationController controller,
    RolesAdministrationState state,
  ) {
    if (state.isLoadingRoles && state.roles.isEmpty) {
      return const AppLoading(style: AppLoadingStyle.skeletonList);
    }

    if (state.rolesError != null && state.roles.isEmpty) {
      return AppErrorState(
        message: state.rolesError!.resolveMessage(l10n),
        onRetry: () => controller.refreshRoles(),
      );
    }

    if (state.roles.isEmpty) {
      final isSearching =
          state.roleSearchQuery != null && state.roleSearchQuery!.isNotEmpty;
      return AppEmptyState(
        title: isSearching
            ? l10n.authAdminEmptyRolesSearch
            : l10n.authAdminEmptyRoles,
        icon: AppIcons.shield,
      );
    }

    return ListView.separated(
      itemCount: state.roles.length + (state.rolesNextCursor != null ? 1 : 0),
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.xs),
      itemBuilder: (context, index) {
        if (index == state.roles.length) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            child: Center(
              child: AppButton(
                label: l10n.authAdminLoadMore,
                icon: AppIcons.refresh,
                isLoading: state.isLoadingMoreRoles,
                onPressed: () => controller.loadMoreRoles(),
                variant: AppButtonVariant.outlined,
              ),
            ),
          );
        }

        final role = state.roles[index];
        final isSelected = state.selectedRoleId == role.roleId;

        return AppCard(
          padding: EdgeInsets.zero,
          color: isSelected
              ? AppColors.primaryBlue.withValues(alpha: 0.1)
              : null,
          child: AppListTile(
            onTap: () => _handleRoleSelected(role.roleId),
            leading: Icon(
              role.isBuiltIn ? AppIcons.shield : AppIcons.settings,
              color: role.isBuiltIn
                  ? AppColors.accentPurple
                  : AppColors.primaryBlue,
            ),
            title: Text(
              role.metadata.displayName.value,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                color: isSelected ? AppColors.primaryBlue : null,
              ),
            ),
            subtitle: Text(
              role.roleId.value,
              style: const TextStyle(fontSize: 12),
            ),
            trailing: AppStatusBadge(
              label: role.isBuiltIn
                  ? l10n.authAdminRoleTypeBuiltIn
                  : l10n.authAdminRoleTypeCustom,
              tone: role.isBuiltIn ? AppStatusTone.neutral : AppStatusTone.info,
              animate: false,
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailView(
    BuildContext context,
    AppLocalizations l10n,
    RolesAdministrationController controller,
    RolesAdministrationState state,
  ) {
    if (state.selectedRoleId == null) {
      return Center(
        child: AppEmptyState(
          title: l10n.authAdminRoleDetailsTitle,
          subtitle: l10n.authAdminNoRoleSelected,
          icon: AppIcons.shield,
        ),
      );
    }

    final tier = AppBreakpoints.of(context);
    final isCompactOrMedium =
        tier == AppBreakpointTier.compact || tier == AppBreakpointTier.medium;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. Compact / Medium Back Affordance & Detail Header
        Row(
          children: [
            if (isCompactOrMedium) ...[
              AppIconButton(
                icon: AppIcons.chevronLeft,
                onPressed: () {
                  setState(() {
                    _showDetailOnCompact = false;
                  });
                },
              ),
              const SizedBox(width: AppSpacing.xs),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    state.selectedRoleSummary?.metadata.displayName.value ??
                        state.selectedRoleId!.value,
                    style: AppTypography.sectionTitle(context),
                  ),
                  Text(
                    state.selectedRoleId!.value,
                    style: AppTypography.caption(context),
                  ),
                ],
              ),
            ),
            if (state.selectedRoleSummary != null)
              AppStatusBadge(
                label: state.selectedRoleSummary!.isBuiltIn
                    ? l10n.authAdminRoleTypeBuiltIn
                    : l10n.authAdminRoleTypeCustom,
                tone: state.selectedRoleSummary!.isBuiltIn
                    ? AppStatusTone.neutral
                    : AppStatusTone.info,
                animate: false,
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        const AppDivider(),
        const SizedBox(height: AppSpacing.xs),

        // 2. Main Tabs (Overview, Permissions, Assigned Members)
        Expanded(
          child: AppTabs(
            index: _selectedTabIndex,
            onChanged: (index) {
              setState(() {
                _selectedTabIndex = index;
              });
            },
            style: AppTabStyle.underline,
            items: [
              AppTabItem(
                label: l10n.authAdminRoleDetailsTitle,
                icon: const Icon(AppIcons.info, size: 16),
                child: _buildOverviewTab(context, l10n, controller, state),
              ),
              AppTabItem(
                label: l10n.authAdminPermissionsTitle,
                icon: const Icon(AppIcons.lock, size: 16),
                child: _buildPermissionsTab(context, l10n, controller, state),
              ),
              AppTabItem(
                label: l10n.authAdminAssignedMembersTitle,
                icon: const Icon(AppIcons.user, size: 16),
                child: _buildAssignedMembersTab(
                  context,
                  l10n,
                  controller,
                  state,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOverviewTab(
    BuildContext context,
    AppLocalizations l10n,
    RolesAdministrationController controller,
    RolesAdministrationState state,
  ) {
    if (state.isLoadingRoleDetails && state.selectedRoleDetails == null) {
      return const Center(child: AppLoading());
    }

    if (state.roleDetailsError != null && state.selectedRoleDetails == null) {
      return AppErrorState(
        message: state.roleDetailsError!.resolveMessage(l10n),
        onRetry: () => controller.refreshSelectedRole(),
      );
    }

    final details = state.selectedRoleDetails;
    if (details == null) {
      return Center(
        child: AppEmptyState(
          title: l10n.authAdminRoleDetailsTitle,
          subtitle: l10n.authAdminNoRoleSelected,
          icon: AppIcons.shield,
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Built-in Explanation Alert
          if (details.isBuiltIn) ...[
            AppCard(
              color: AppColors.infoContainer,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    AppIcons.info,
                    color: AppColors.primaryBlue,
                    size: 20,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      l10n.authAdminRoleBuiltInHelp,
                      style: const TextStyle(fontSize: 13, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
          ],

          // Key-Value Overview Table
          AppCard(
            child: Column(
              children: [
                AppDetailInfoRow(
                  label: l10n.authAdminRoleDisplayNameLabel,
                  value: details.metadata.displayName.value,
                ),
                const AppDivider(),
                AppDetailInfoRow(
                  label: l10n.authAdminRoleKeyLabel,
                  value: details.roleId.value,
                ),
                const AppDivider(),
                AppDetailInfoRow(
                  label: l10n.authAdminPermissionsTitle,
                  value: l10n.authAdminPermissionCount(
                    details.permissionAssignmentCount,
                  ),
                ),
                const AppDivider(),
                AppDetailInfoRow(
                  label: l10n.authAdminAssignedMembersTitle,
                  value: l10n.authAdminMemberCount(
                    details.membershipAssignmentCount,
                  ),
                ),
                if (details.metadata.description != null) ...[
                  const AppDivider(),
                  AppDetailInfoRow(
                    label: l10n.authAdminRoleDescriptionLabel,
                    value: details.metadata.description!,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionsTab(
    BuildContext context,
    AppLocalizations l10n,
    RolesAdministrationController controller,
    RolesAdministrationState state,
  ) {
    if (state.isLoadingRolePermissions &&
        state.selectedRolePermissions.isEmpty) {
      return const Center(child: AppLoading());
    }

    final grantedPermissions = state.selectedRolePermissions
        .where((p) => p.isGranted)
        .toList();

    if (grantedPermissions.isEmpty) {
      return Center(
        child: AppEmptyState(
          title: l10n.permissionsResponsibilityNoRuntimeGrants,
          icon: AppIcons.lock,
        ),
      );
    }

    // Deterministic Grouping
    final permissionsByGroup =
        <NexaBizPermissionPresentationGroup, List<NexaBizRolePermissionItem>>{};
    for (final perm in grantedPermissions) {
      permissionsByGroup.putIfAbsent(perm.group, () => []).add(perm);
    }

    final sortedGroups = permissionsByGroup.keys.toList()
      ..sort((a, b) => a.order.compareTo(b.order));

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      itemCount: sortedGroups.length,
      itemBuilder: (context, groupIndex) {
        final group = sortedGroups[groupIndex];
        final groupPerms = permissionsByGroup[group]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xs,
                vertical: AppSpacing.xs,
              ),
              child: Text(
                group.resolveTitle(l10n),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: AppColors.mutedTextLight,
                ),
              ),
            ),
            ...groupPerms.map((perm) {
              return AppCard(
                margin: const EdgeInsets.only(bottom: AppSpacing.xs),
                padding: const EdgeInsets.all(AppSpacing.sm),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 2),
                      child: Icon(
                        AppIcons.check,
                        color: AppColors.success,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            perm.resolveTitle(l10n),
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            perm.permissionId.value,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.mutedTextLight,
                              fontFamily: 'monospace',
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            perm.resolveDescription(l10n),
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.mutedTextLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                    AppStatusBadge(
                      label: l10n.authAdminRolePermissionGranted,
                      tone: AppStatusTone.success,
                      animate: false,
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: AppSpacing.sm),
          ],
        );
      },
    );
  }

  Widget _buildAssignedMembersTab(
    BuildContext context,
    AppLocalizations l10n,
    RolesAdministrationController controller,
    RolesAdministrationState state,
  ) {
    if (state.isLoadingAssignedMembers && state.assignedMembers.isEmpty) {
      return const Center(child: AppLoading());
    }

    if (state.assignedMembersError != null && state.assignedMembers.isEmpty) {
      return AppErrorState(
        message: state.assignedMembersError!.resolveMessage(l10n),
        onRetry: () => controller.refreshSelectedRole(),
      );
    }

    if (state.assignedMembers.isEmpty) {
      return Center(
        child: AppEmptyState(
          title: l10n.authAdminEmptyAssignedMembers,
          icon: AppIcons.user,
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      itemCount:
          state.assignedMembers.length +
          (state.assignedMembersNextCursor != null ? 1 : 0),
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.xs),
      itemBuilder: (context, index) {
        if (index == state.assignedMembers.length) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            child: Center(
              child: AppButton(
                label: l10n.authAdminLoadMore,
                icon: AppIcons.refresh,
                isLoading: state.isLoadingMoreAssignedMembers,
                onPressed: () => controller.loadMoreAssignedMembers(),
                variant: AppButtonVariant.outlined,
              ),
            ),
          );
        }

        final member = state.assignedMembers[index];

        // Safe Human Label Fallback (Section 38)
        final String displayName;
        final String? secondaryIdentifier;

        if (member.userName != null && member.userName!.trim().isNotEmpty) {
          displayName = member.userName!.trim();
          secondaryIdentifier = member.userEmail?.trim();
        } else if (member.userEmail != null &&
            member.userEmail!.trim().isNotEmpty) {
          displayName = member.userEmail!.trim();
          secondaryIdentifier = null;
        } else {
          displayName = member.userId.value;
          secondaryIdentifier = null;
        }

        return AppCard(
          padding: EdgeInsets.zero,
          child: AppListTile(
            leading: const Icon(AppIcons.user, color: AppColors.primaryBlue),
            title: Text(
              displayName,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: secondaryIdentifier != null
                ? Text(secondaryIdentifier)
                : null,
            trailing: AppStatusBadge(
              label: member.isEligible
                  ? l10n.authAdminMemberEligible
                  : l10n.authAdminMemberIneligible,
              tone: member.isEligible
                  ? AppStatusTone.success
                  : AppStatusTone.neutral,
              animate: false,
            ),
          ),
        );
      },
    );
  }
}
