import 'package:flutter/widgets.dart';
import 'package:nexabiz_ui/nexabiz_ui.dart';

import '../../../app/authorization/app_permission_scope.dart';
import '../../../app/authorization/app_permission_gate.dart';
import '../../../app/authorization/nexabiz_authorization_invalidation_signal.dart';
import '../../../core/authorization/administration/nexabiz_authorization_administration_models.dart';
import '../../../core/authorization/administration/nexabiz_authorization_administration_permissions.dart';
import '../../../core/roles/nexabiz_role_id.dart';
import '../../../l10n/app_localizations.dart';
import 'controllers/roles_administration_controller.dart';
import 'controllers/roles_administration_state.dart';
import 'metadata/nexabiz_permission_presentation_models.dart';
import 'role_lifecycle_surfaces.dart';
import 'role_membership_surfaces.dart';

/// Canonical Roles Administration Screen.
///
/// Implements master-detail inspection of company roles, metadata,
/// permission assignments, and assigned company members.
///
/// Adheres to:
/// - `AGENTS.md` and repository architectural contracts.
/// - Single-flight invalidation and race safety via [RolesAdministrationController].
/// - Role lifecycle affordances remain UX-gated; UseCases are authoritative.
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
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppPermissionGate.hide(
                permissionId:
                    NexaBizAuthorizationAdministrationPermissions.roleManage,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: AppButton(
                    label: l10n.authAdminActionCreate,
                    icon: AppIcons.plus,
                    expand: true,
                    onPressed: () async {
                      await showCreateRoleSurface(
                        context: context,
                        controller: controller,
                      );
                    },
                  ),
                ),
              ),
              AppSearchField(
                hint: l10n.authAdminSearchRolesPlaceholder,
                onChanged: (query) => controller.searchRoles(query),
              ),
              const SizedBox(height: AppSpacing.sm),
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
            ],
          ),
        ),
        ..._buildRoleListSlivers(context, l10n, controller, state),
      ],
    );
  }

  List<Widget> _buildRoleListSlivers(
    BuildContext context,
    AppLocalizations l10n,
    RolesAdministrationController controller,
    RolesAdministrationState state,
  ) {
    if (state.isLoadingRoles && state.roles.isEmpty) {
      return const [
        SliverFillRemaining(
          child: AppLoading(style: AppLoadingStyle.skeletonList),
        ),
      ];
    }

    if (state.rolesError != null && state.roles.isEmpty) {
      return [
        SliverToBoxAdapter(
          child: AppErrorState(
            message: state.rolesError!.resolveMessage(l10n),
            onRetry: () => controller.refreshRoles(),
          ),
        ),
      ];
    }

    if (state.roles.isEmpty) {
      final isSearching =
          state.roleSearchQuery != null && state.roleSearchQuery!.isNotEmpty;
      return [
        SliverToBoxAdapter(
          child: AppEmptyState(
            title: isSearching
                ? l10n.authAdminEmptyRolesSearch
                : l10n.authAdminEmptyRoles,
            icon: AppIcons.shield,
          ),
        ),
      ];
    }

    final itemCount =
        state.roles.length + (state.rolesNextCursor != null ? 1 : 0);
    return [
      SliverList(
        delegate: SliverChildBuilderDelegate((context, rawIndex) {
          if (rawIndex.isOdd) {
            return const SizedBox(height: AppSpacing.xs);
          }
          final index = rawIndex ~/ 2;
          if (index == state.roles.length) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              child: Center(
                child: AppButton(
                  label: l10n.authAdminLoadMore,
                  icon: AppIcons.refresh,
                  isLoading: state.isLoadingMoreRoles,
                  onPressed: controller.loadMoreRoles,
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
                tone: role.isBuiltIn
                    ? AppStatusTone.neutral
                    : AppStatusTone.info,
                animate: false,
              ),
            ),
          );
        }, childCount: itemCount * 2 - 1),
      ),
    ];
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

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  if (isCompactOrMedium) ...[
                    AppIconButton(
                      icon: AppIcons.chevronLeft,
                      tooltip: l10n.actionBack,
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
                          state
                                  .selectedRoleSummary
                                  ?.metadata
                                  .displayName
                                  .value ??
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
            ],
          ),
        ),
        SliverFillRemaining(
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
          if (!details.isBuiltIn) ...[
            AppPermissionGate.hide(
              permissionId:
                  NexaBizAuthorizationAdministrationPermissions.roleManage,
              child: Wrap(
                alignment: WrapAlignment.end,
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  AppButton(
                    label: l10n.authAdminEditRoleTitle,
                    icon: AppIcons.edit,
                    variant: AppButtonVariant.outlined,
                    onPressed: () async {
                      await showEditRoleSurface(
                        context: context,
                        controller: controller,
                        role: details,
                      );
                    },
                  ),
                  AppButton(
                    label: l10n.authAdminActionDelete,
                    variant: AppButtonVariant.destructive,
                    onPressed: () async {
                      await showDeleteRoleSurface(
                        context: context,
                        controller: controller,
                        role: details,
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
          ],

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

    final targetIsMutable =
        state.selectedRoleDetails != null &&
        !state.selectedRoleDetails!.isBuiltIn;

    return AppPermissionGate.builder(
      permissionId: NexaBizAuthorizationAdministrationPermissions.policyManage,
      builder: (context, actorCanManagePolicy) {
        final visiblePermissions = targetIsMutable
            ? state.selectedRolePermissions
            : state.selectedRolePermissions
                  .where((permission) => permission.isGranted)
                  .toList();

        if (visiblePermissions.isEmpty) {
          return Center(
            child: AppEmptyState(
              title: l10n.permissionsResponsibilityNoRuntimeGrants,
              icon: AppIcons.lock,
            ),
          );
        }

        final permissionsByGroup =
            <
              NexaBizPermissionPresentationGroup,
              List<NexaBizRolePermissionItem>
            >{};
        for (final permission in visiblePermissions) {
          permissionsByGroup
              .putIfAbsent(permission.group, () => [])
              .add(permission);
        }

        final sortedGroups = permissionsByGroup.keys.toList()
          ..sort((a, b) => a.order.compareTo(b.order));
        final canMutate = targetIsMutable && actorCanManagePolicy;

        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          itemCount: sortedGroups.length,
          itemBuilder: (context, groupIndex) {
            final group = sortedGroups[groupIndex];
            final groupPermissions = permissionsByGroup[group]!;

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
                    style: AppTypography.bodyBold(
                      context,
                    ).copyWith(color: AppColors.mutedTextLight),
                  ),
                ),
                ...groupPermissions.map(
                  (permission) => _buildPermissionRow(
                    context: context,
                    l10n: l10n,
                    controller: controller,
                    state: state,
                    permission: permission,
                    canMutate: canMutate,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildPermissionRow({
    required BuildContext context,
    required AppLocalizations l10n,
    required RolesAdministrationController controller,
    required RolesAdministrationState state,
    required NexaBizRolePermissionItem permission,
    required bool canMutate,
  }) {
    final isPending = state.isPermissionPending(permission.permissionId);
    final stateLabel = permission.isGranted
        ? l10n.authAdminRolePermissionGranted
        : l10n.authAdminRolePermissionNotGranted;
    final permissionError =
        state.mutationError?.permissionId == permission.permissionId
        ? state.mutationError!.resolveMessage(l10n)
        : null;

    final Widget trailing;
    if (isPending) {
      trailing = Semantics(
        label: permission.resolveTitle(l10n),
        value: stateLabel,
        hint: l10n.authAdminPendingApplying,
        liveRegion: true,
        child: const SizedBox.square(
          dimension: AppDimensions.minTouchTarget,
          child: AppLoading(showMessage: false),
        ),
      );
    } else if (canMutate) {
      trailing = Semantics(
        label: permission.resolveTitle(l10n),
        value: stateLabel,
        toggled: permission.isGranted,
        enabled: true,
        child: AppCheckbox(
          key: ValueKey(permission.permissionId),
          value: permission.isGranted,
          onChanged: (nextValue) {
            if (nextValue == true && !permission.isGranted) {
              controller.grantPermission(permission.permissionId);
            } else if (nextValue == false && permission.isGranted) {
              controller.revokePermission(permission.permissionId);
            }
          },
        ),
      );
    } else {
      trailing = AppStatusBadge(
        label: stateLabel,
        tone: permission.isGranted
            ? AppStatusTone.success
            : AppStatusTone.neutral,
        animate: false,
      );
    }

    return AppCard(
      margin: const EdgeInsetsDirectional.only(bottom: AppSpacing.xs),
      padding: EdgeInsets.zero,
      child: AppListTile(
        title: Text(
          permission.resolveTitle(l10n),
          style: AppTypography.bodyBold(context),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Directionality(
              textDirection: TextDirection.ltr,
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  permission.permissionId.value,
                  key: ValueKey(permission.permissionId.value),
                  style: AppTypography.caption(
                    context,
                  ).copyWith(color: AppColors.mutedTextLight),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xxs),
            Text(permission.resolveDescription(l10n)),
            if (permissionError != null) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                permissionError,
                style: AppTypography.bodySmall(
                  context,
                ).copyWith(color: AppColors.error),
              ),
            ],
          ],
        ),
        trailing: trailing,
      ),
    );
  }

  Widget _buildAssignedMembersTab(
    BuildContext context,
    AppLocalizations l10n,
    RolesAdministrationController controller,
    RolesAdministrationState state,
  ) {
    final role = state.selectedRoleDetails;
    if (role == null) return const SizedBox.shrink();

    return AppPermissionGate.builder(
      permissionId:
          NexaBizAuthorizationAdministrationPermissions.assignmentManage,
      builder: (context, canManageAssignments) {
        return CustomScrollView(
          slivers: [
            if (canManageAssignments) ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.md),
                  child: Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: AppButton(
                      key: const ValueKey('assign-member-action'),
                      label: l10n.authAdminAssignMemberTitle,
                      icon: AppIcons.userAdd,
                      onPressed: () => showAssignMemberSurface(
                        context: context,
                        controller: controller,
                        role: role,
                      ),
                    ),
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.sm)),
            ],
            SliverFillRemaining(
              child: _buildAssignedMembersContent(
                context: context,
                l10n: l10n,
                controller: controller,
                state: state,
                role: role,
                canManageAssignments: canManageAssignments,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAssignedMembersContent({
    required BuildContext context,
    required AppLocalizations l10n,
    required RolesAdministrationController controller,
    required RolesAdministrationState state,
    required NexaBizCompanyRoleDetails role,
    required bool canManageAssignments,
  }) {
    if (state.isLoadingAssignedMembers && state.assignedMembers.isEmpty) {
      return const Center(child: AppLoading());
    }

    if (state.assignedMembersError != null && state.assignedMembers.isEmpty) {
      return AppErrorState(
        title: l10n.authAdminAssignedMembersTitle,
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
                onPressed: state.isLoadingMoreAssignedMembers
                    ? null
                    : controller.loadMoreAssignedMembers,
                variant: AppButtonVariant.outlined,
              ),
            ),
          );
        }

        final member = state.assignedMembers[index];
        final displayName = _resolveMemberName(
          l10n: l10n,
          userName: member.userName,
          userEmail: member.userEmail,
        );
        final secondaryEmail = _secondaryMemberEmail(
          userName: member.userName,
          userEmail: member.userEmail,
        );
        final pending = state.isMembershipPending(member.membershipId);
        final error = state.mutationError?.membershipId == member.membershipId
            ? state.mutationError!.resolveMessage(l10n)
            : null;

        return AppCard(
          key: ValueKey(member.membershipId),
          padding: EdgeInsets.zero,
          child: AppListTile(
            leading: const Icon(AppIcons.user, color: AppColors.primaryBlue),
            title: Text(displayName, style: AppTypography.bodyBold(context)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (secondaryEmail != null)
                  Directionality(
                    textDirection: TextDirection.ltr,
                    child: Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: Text(secondaryEmail),
                    ),
                  ),
                if (error != null) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    error,
                    style: AppTypography.bodySmall(
                      context,
                    ).copyWith(color: AppColors.error),
                  ),
                ],
              ],
            ),
            trailing: Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.xs,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                AppStatusBadge(
                  label: member.isEligible
                      ? l10n.authAdminMemberEligible
                      : l10n.authAdminMemberIneligible,
                  tone: member.isEligible
                      ? AppStatusTone.success
                      : AppStatusTone.neutral,
                  animate: false,
                ),
                if (canManageAssignments)
                  Semantics(
                    label: l10n.authAdminUnassignMemberSemantics(displayName),
                    liveRegion: pending,
                    child: AppButton(
                      key: ValueKey(('unassign', member.membershipId)),
                      label: l10n.authAdminActionUnassign,
                      variant: AppButtonVariant.destructive,
                      isCompact: true,
                      isLoading: pending,
                      onPressed: pending
                          ? null
                          : () => showUnassignMemberSurface(
                              context: context,
                              controller: controller,
                              role: role,
                              member: member,
                            ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _resolveMemberName({
    required AppLocalizations l10n,
    required String? userName,
    required String? userEmail,
  }) {
    final name = userName?.trim();
    if (name != null && name.isNotEmpty) return name;
    final email = userEmail?.trim();
    if (email != null && email.isNotEmpty) return email;
    return l10n.authAdminUnknownMember;
  }

  String? _secondaryMemberEmail({
    required String? userName,
    required String? userEmail,
  }) {
    final name = userName?.trim();
    final email = userEmail?.trim();
    if (name == null || name.isEmpty || email == null || email.isEmpty) {
      return null;
    }
    return email;
  }
}
