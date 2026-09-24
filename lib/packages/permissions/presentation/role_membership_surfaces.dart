import 'package:flutter/widgets.dart';
import 'package:nexabiz_ui/nexabiz_ui.dart';

import '../../../app/authorization/app_permission_gate.dart';
import '../../../core/authorization/administration/nexabiz_authorization_administration_models.dart';
import '../../../core/authorization/administration/nexabiz_authorization_administration_permissions.dart';
import '../../../l10n/app_localizations.dart';
import 'controllers/roles_administration_controller.dart';
import 'controllers/roles_administration_state.dart';

typedef _CloseMembershipSurface = void Function(BuildContext context);

Future<void> showAssignMemberSurface({
  required BuildContext context,
  required RolesAdministrationController controller,
  required NexaBizCompanyRoleDetails role,
}) async {
  controller.clearMutationError();
  final l10n = AppLocalizations.of(context);
  final compact = AppBreakpoints.of(context) != AppBreakpointTier.expanded;

  if (compact) {
    await AppBottomSheet.show<void>(
      context: context,
      title: l10n.authAdminAssignMemberTitle,
      icon: AppIcons.userAdd,
      scrollable: true,
      child: _AssignMemberSurface(
        controller: controller,
        role: role,
        close: AppBottomSheet.close<void>,
      ),
    ).future;
    return;
  }

  final dialogController = AppDialogController();
  await AppDialog.show<void>(
    context: context,
    controller: dialogController,
    title: l10n.authAdminAssignMemberTitle,
    icon: AppIcons.userAdd,
    size: AppDialogSize.medium,
    showActions: false,
    child: _AssignMemberSurface(
      controller: controller,
      role: role,
      close: (_) => dialogController.close(),
    ),
  );
}

Future<void> showUnassignMemberSurface({
  required BuildContext context,
  required RolesAdministrationController controller,
  required NexaBizCompanyRoleDetails role,
  required NexaBizMembershipRoleAssignment member,
}) async {
  controller.clearMutationError();
  final l10n = AppLocalizations.of(context);
  final compact = AppBreakpoints.of(context) != AppBreakpointTier.expanded;

  if (compact) {
    await AppBottomSheet.show<void>(
      context: context,
      title: l10n.authAdminActionUnassign,
      icon: AppIcons.warning,
      barrierDismissible: false,
      draggable: false,
      child: _UnassignMemberConfirmation(
        controller: controller,
        role: role,
        member: member,
        close: AppBottomSheet.close<void>,
      ),
    ).future;
    return;
  }

  final dialogController = AppDialogController();
  await AppDialog.show<void>(
    context: context,
    controller: dialogController,
    title: l10n.authAdminActionUnassign,
    icon: AppIcons.warning,
    size: AppDialogSize.small,
    barrierDismissible: false,
    showActions: false,
    child: _UnassignMemberConfirmation(
      controller: controller,
      role: role,
      member: member,
      close: (_) => dialogController.close(),
    ),
  );
}

class _AssignMemberSurface extends StatefulWidget {
  const _AssignMemberSurface({
    required this.controller,
    required this.role,
    required this.close,
  });

  final RolesAdministrationController controller;
  final NexaBizCompanyRoleDetails role;
  final _CloseMembershipSurface close;

  @override
  State<_AssignMemberSurface> createState() => _AssignMemberSurfaceState();
}

class _AssignMemberSurfaceState extends State<_AssignMemberSurface> {
  late final TextEditingController _searchController;
  bool _closing = false;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    widget.controller.addListener(_onControllerChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_closing) {
        widget.controller.loadAssignableMembers();
      }
    });
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onControllerChanged() {
    if (!mounted || _closing) return;
    final state = widget.controller.state;
    final targetMissing = !state.roles.any(
      (summary) => summary.roleId == widget.role.roleId,
    );
    if (state.companyId != widget.role.companyId ||
        state.selectedRoleId != widget.role.roleId ||
        targetMissing) {
      _closing = true;
      widget.close(context);
      return;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = widget.controller.state;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppPermissionGate.builder(
          permissionId:
              NexaBizAuthorizationAdministrationPermissions.assignmentManage,
          mode: AppPermissionGateMode.disable,
          builder: (context, canManageAssignments) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppSearchField(
                  key: const ValueKey('role-membership-search'),
                  controller: _searchController,
                  hint: l10n.authAdminSearchMembersPlaceholder,
                  enabled: canManageAssignments,
                  onChanged: (query) =>
                      widget.controller.loadAssignableMembers(search: query),
                ),
                const SizedBox(height: AppSpacing.md),
                _buildCandidateContent(
                  context: context,
                  l10n: l10n,
                  canManageAssignments: canManageAssignments,
                  state: state,
                ),
              ],
            );
          },
        ),
        const SizedBox(height: AppSpacing.md),
        Align(
          alignment: AlignmentDirectional.centerEnd,
          child: AppButton(
            label: l10n.actionClose,
            variant: AppButtonVariant.outlined,
            onPressed: () => widget.close(context),
          ),
        ),
      ],
    );
  }

  Widget _buildCandidateContent({
    required BuildContext context,
    required AppLocalizations l10n,
    required bool canManageAssignments,
    required RolesAdministrationState state,
  }) {
    if (state.isLoadingAssignableMembers && state.assignableMembers.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(AppSpacing.xl),
        child: Center(child: AppLoading()),
      );
    }

    if (state.assignableMembersError != null &&
        state.assignableMembers.isEmpty) {
      return AppErrorState(
        title: l10n.authAdminAssignMemberTitle,
        message: state.assignableMembersError!.resolveMessage(l10n),
        onRetry: canManageAssignments
            ? () => widget.controller.loadAssignableMembers(
                search: _searchController.text,
              )
            : null,
      );
    }

    if (state.assignableMembers.isEmpty) {
      return AppEmptyState(
        title: state.assignableMembersSearchQuery == null
            ? l10n.authAdminEmptyAssignableMembers
            : l10n.authAdminEmptyAssignableMembersSearch,
        icon: AppIcons.user,
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.authAdminAvailableMembersSection,
          style: AppTypography.bodyBold(context),
        ),
        const SizedBox(height: AppSpacing.sm),
        ListView.separated(
          shrinkWrap: true,
          primary: false,
          itemCount:
              state.assignableMembers.length +
              (state.hasMoreAssignableMembers ? 1 : 0),
          separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.xs),
          itemBuilder: (context, index) {
            if (index == state.assignableMembers.length) {
              return Center(
                child: AppButton(
                  label: l10n.authAdminLoadMore,
                  icon: AppIcons.refresh,
                  variant: AppButtonVariant.outlined,
                  isLoading: state.isLoadingMoreAssignableMembers,
                  onPressed:
                      canManageAssignments &&
                          !state.isLoadingMoreAssignableMembers
                      ? widget.controller.loadMoreAssignableMembers
                      : null,
                ),
              );
            }

            final candidate = state.assignableMembers[index];
            final displayName = _resolveMemberName(
              l10n: l10n,
              userName: candidate.userName,
              userEmail: candidate.userEmail,
            );
            final email = _secondaryEmail(
              userName: candidate.userName,
              userEmail: candidate.userEmail,
            );
            final pending = state.isMembershipPending(candidate.membershipId);
            final error =
                state.mutationError?.membershipId == candidate.membershipId
                ? state.mutationError!.resolveMessage(l10n)
                : null;

            return AppCard(
              key: ValueKey(candidate.membershipId),
              padding: EdgeInsets.zero,
              child: AppListTile(
                leading: const Icon(
                  AppIcons.user,
                  color: AppColors.primaryBlue,
                ),
                title: Text(displayName),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (email != null)
                      Directionality(
                        textDirection: TextDirection.ltr,
                        child: Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: Text(email),
                        ),
                      ),
                    Text(
                      candidate.isEligible
                          ? l10n.authAdminMemberEligible
                          : l10n.authAdminMemberIneligible,
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
                trailing: Semantics(
                  label: l10n.authAdminAssignMemberSemantics(displayName),
                  enabled:
                      canManageAssignments && candidate.isEligible && !pending,
                  liveRegion: pending,
                  child: AppButton(
                    label: l10n.authAdminActionAssign,
                    icon: AppIcons.userAdd,
                    isCompact: true,
                    isLoading: pending,
                    onPressed:
                        canManageAssignments && candidate.isEligible && !pending
                        ? () => widget.controller.assignMember(
                            candidate.membershipId,
                          )
                        : null,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _UnassignMemberConfirmation extends StatefulWidget {
  const _UnassignMemberConfirmation({
    required this.controller,
    required this.role,
    required this.member,
    required this.close,
  });

  final RolesAdministrationController controller;
  final NexaBizCompanyRoleDetails role;
  final NexaBizMembershipRoleAssignment member;
  final _CloseMembershipSurface close;

  @override
  State<_UnassignMemberConfirmation> createState() =>
      _UnassignMemberConfirmationState();
}

class _UnassignMemberConfirmationState
    extends State<_UnassignMemberConfirmation> {
  bool _closing = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onControllerChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChanged);
    super.dispose();
  }

  void _onControllerChanged() {
    if (!mounted || _closing) return;
    final state = widget.controller.state;
    final targetMissing = !state.roles.any(
      (summary) => summary.roleId == widget.role.roleId,
    );
    if (state.companyId != widget.role.companyId ||
        state.selectedRoleId != widget.role.roleId ||
        targetMissing) {
      _closing = true;
      widget.close(context);
      return;
    }
    setState(() {});
  }

  Future<void> _unassign() async {
    final state = widget.controller.state;
    if (_closing ||
        state.selectedRoleId != widget.role.roleId ||
        state.isMembershipPending(widget.member.membershipId)) {
      return;
    }
    final success = await widget.controller.unassignMember(
      widget.member.membershipId,
    );
    if (!mounted || !success || _closing) return;
    _closing = true;
    widget.close(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = widget.controller.state;
    final displayName = _resolveMemberName(
      l10n: l10n,
      userName: widget.member.userName,
      userEmail: widget.member.userEmail,
    );
    final pending = state.isMembershipPending(widget.member.membershipId);
    final error =
        state.mutationError?.membershipId == widget.member.membershipId
        ? state.mutationError!.resolveMessage(l10n)
        : null;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.authAdminUnassignMemberConfirm(
            displayName,
            widget.role.metadata.displayName.value,
          ),
          style: AppTypography.body(context),
        ),
        if (error != null) ...[
          const SizedBox(height: AppSpacing.md),
          AppCard(
            color: AppColors.errorContainer,
            child: Text(error, style: const TextStyle(color: AppColors.error)),
          ),
        ],
        const SizedBox(height: AppSpacing.lg),
        Wrap(
          alignment: WrapAlignment.end,
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            AppButton(
              label: l10n.actionCancel,
              variant: AppButtonVariant.outlined,
              onPressed: pending ? null : () => widget.close(context),
            ),
            AppPermissionGate.hide(
              permissionId: NexaBizAuthorizationAdministrationPermissions
                  .assignmentManage,
              child: Semantics(
                label: l10n.authAdminUnassignMemberSemantics(displayName),
                liveRegion: pending,
                child: AppButton(
                  label: l10n.authAdminActionUnassign,
                  variant: AppButtonVariant.destructive,
                  isLoading: pending,
                  onPressed: pending ? null : _unassign,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
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

String? _secondaryEmail({
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
