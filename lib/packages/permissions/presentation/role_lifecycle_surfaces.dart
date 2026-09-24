import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';
import 'package:nexabiz_ui/nexabiz_ui.dart';

import '../../../app/authorization/app_permission_gate.dart';
import '../../../core/authorization/administration/nexabiz_authorization_administration_models.dart';
import '../../../core/authorization/administration/nexabiz_authorization_administration_permissions.dart';
import '../../../core/company/nexabiz_company_scope.dart';
import '../../../core/roles/nexabiz_role_id.dart';
import '../../../l10n/app_localizations.dart';
import 'controllers/roles_administration_controller.dart';
import 'metadata/nexabiz_authorization_presentation_error_mapper.dart';

enum _RoleMetadataMode { create, edit }

Future<void> showCreateRoleSurface({
  required BuildContext context,
  required RolesAdministrationController controller,
}) async {
  controller.clearMutationError();
  final l10n = AppLocalizations.of(context);
  final compact = AppBreakpoints.of(context) != AppBreakpointTier.expanded;
  final initialCompanyId = controller.state.companyId;

  if (compact) {
    await AppBottomSheet.show<void>(
      context: context,
      title: l10n.authAdminCreateRoleTitle,
      icon: AppIcons.plus,
      barrierDismissible: true,
      child: _RoleMetadataForm(
        controller: controller,
        mode: _RoleMetadataMode.create,
        initialCompanyId: initialCompanyId,
        close: AppBottomSheet.close<void>,
      ),
    ).future;
    return;
  }

  final dialogController = AppDialogController();
  await AppDialog.show<void>(
    context: context,
    controller: dialogController,
    title: l10n.authAdminCreateRoleTitle,
    icon: AppIcons.plus,
    size: AppDialogSize.medium,
    showActions: false,
    child: _RoleMetadataForm(
      controller: controller,
      mode: _RoleMetadataMode.create,
      initialCompanyId: initialCompanyId,
      close: (_) => dialogController.close(),
    ),
  );
}

Future<void> showEditRoleSurface({
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
      title: l10n.authAdminEditRoleTitle,
      icon: AppIcons.edit,
      barrierDismissible: true,
      child: _RoleMetadataForm(
        controller: controller,
        mode: _RoleMetadataMode.edit,
        initialCompanyId: role.companyId,
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
    title: l10n.authAdminEditRoleTitle,
    icon: AppIcons.edit,
    size: AppDialogSize.medium,
    showActions: false,
    child: _RoleMetadataForm(
      controller: controller,
      mode: _RoleMetadataMode.edit,
      initialCompanyId: role.companyId,
      role: role,
      close: (_) => dialogController.close(),
    ),
  );
}

Future<void> showDeleteRoleSurface({
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
      title: l10n.authAdminDeleteRoleTitle,
      icon: AppIcons.warning,
      barrierDismissible: false,
      draggable: false,
      child: _DeleteRoleConfirmation(
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
    title: l10n.authAdminDeleteRoleTitle,
    icon: AppIcons.warning,
    size: AppDialogSize.small,
    barrierDismissible: false,
    showActions: false,
    child: _DeleteRoleConfirmation(
      controller: controller,
      role: role,
      close: (_) => dialogController.close(),
    ),
  );
}

typedef _CloseSurface = void Function(BuildContext context);

class _RoleMetadataForm extends StatefulWidget {
  const _RoleMetadataForm({
    required this.controller,
    required this.mode,
    required this.initialCompanyId,
    required this.close,
    this.role,
  });

  final RolesAdministrationController controller;
  final _RoleMetadataMode mode;
  final NexaBizCompanyId? initialCompanyId;
  final NexaBizCompanyRoleDetails? role;
  final _CloseSurface close;

  @override
  State<_RoleMetadataForm> createState() => _RoleMetadataFormState();
}

class _RoleMetadataFormState extends State<_RoleMetadataForm> {
  late final TextEditingController _displayName;
  late final TextEditingController _roleKey;
  late final TextEditingController _description;
  String? _displayNameError;
  String? _roleKeyError;
  bool _closing = false;

  bool get _isCreate => widget.mode == _RoleMetadataMode.create;

  @override
  void initState() {
    super.initState();
    _displayName = TextEditingController(
      text: widget.role?.metadata.displayName.value,
    );
    _roleKey = TextEditingController(text: widget.role?.roleId.value);
    _description = TextEditingController(
      text: widget.role?.metadata.description,
    );
    widget.controller.addListener(_onControllerChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChanged);
    _displayName.dispose();
    _roleKey.dispose();
    _description.dispose();
    super.dispose();
  }

  void _onControllerChanged() {
    if (!mounted || _closing) return;
    final state = widget.controller.state;
    final targetMissing =
        !_isCreate &&
        !state.roles.any((summary) => summary.roleId == widget.role!.roleId);
    if (state.companyId != widget.initialCompanyId || targetMissing) {
      _closing = true;
      widget.close(context);
      return;
    }
    setState(() {});
  }

  Future<void> _submit() async {
    final state = widget.controller.state;
    final pending = _isCreate ? state.isCreatingRole : state.isUpdatingRole;
    if (pending || _closing || state.companyId != widget.initialCompanyId) {
      return;
    }

    final l10n = AppLocalizations.of(context);
    const mapper = NexaBizAuthorizationPresentationErrorMapper();
    NexaBizRoleDisplayName? displayName;
    NexaBizRoleId? roleId;
    String? displayNameError;
    String? roleKeyError;

    try {
      displayName = NexaBizRoleDisplayName(_displayName.text);
    } catch (error) {
      displayNameError = mapper.mapError(error: error, l10n: l10n);
    }

    if (_isCreate) {
      try {
        roleId = NexaBizRoleId(_roleKey.text);
        if (roleId.namespace != 'company') {
          throw ArgumentError.value(roleId, 'roleId');
        }
      } catch (error) {
        roleKeyError = mapper.mapError(error: error, l10n: l10n);
      }
    } else {
      roleId = widget.role!.roleId;
    }

    if (displayNameError != null || roleKeyError != null) {
      setState(() {
        _displayNameError = displayNameError;
        _roleKeyError = roleKeyError;
      });
      return;
    }

    setState(() {
      _displayNameError = null;
      _roleKeyError = null;
    });

    final success = _isCreate
        ? await widget.controller.createRole(
            roleId: roleId!,
            displayName: displayName!,
            description: _description.text,
          )
        : await widget.controller.updateRoleMetadata(
            roleId: roleId!,
            displayName: displayName!,
            description: _description.text,
          );

    if (!mounted || !success || _closing) return;
    _closing = true;
    widget.close(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = widget.controller.state;
    final isSubmitting = _isCreate
        ? state.isCreatingRole
        : state.isUpdatingRole;
    final mutationError = state.mutationError?.resolveMessage(l10n);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (mutationError != null) ...[
          AppCard(
            color: AppColors.errorContainer,
            child: Text(
              mutationError,
              style: const TextStyle(color: AppColors.error),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
        ],
        AppFormRow(
          fullWidthChildren: [
            AppTextField(
              controller: _description,
              label: l10n.authAdminRoleDescriptionLabel,
              hint: l10n.authAdminRoleDescriptionPlaceholder,
              helperText: l10n.authAdminRoleDescriptionOptional,
              enabled: !isSubmitting,
              minLines: 3,
              maxLines: 5,
              textInputAction: TextInputAction.newline,
            ),
          ],
          children: [
            AppTextField(
              controller: _displayName,
              label: l10n.authAdminRoleDisplayNameLabel,
              hint: l10n.authAdminRoleDisplayNamePlaceholder,
              required: true,
              errorText: _displayNameError,
              enabled: !isSubmitting,
              textInputAction: TextInputAction.next,
            ),
            AppTextField(
              controller: _roleKey,
              label: l10n.authAdminRoleKeyLabel,
              hint: _isCreate ? l10n.authAdminRoleKeyPlaceholder : null,
              helperText: l10n.authAdminRoleKeyHelpText,
              required: _isCreate,
              errorText: _roleKeyError,
              enabled: _isCreate && !isSubmitting,
              readOnly: !_isCreate,
              textDirection: TextDirection.ltr,
              textInputAction: TextInputAction.next,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        Wrap(
          alignment: WrapAlignment.end,
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            AppButton(
              label: l10n.actionCancel,
              variant: AppButtonVariant.outlined,
              onPressed: isSubmitting ? null : () => widget.close(context),
            ),
            AppPermissionGate.hide(
              permissionId:
                  NexaBizAuthorizationAdministrationPermissions.roleManage,
              child: AppButton(
                label: _isCreate
                    ? l10n.authAdminActionCreate
                    : l10n.authAdminActionUpdate,
                icon: _isCreate ? AppIcons.plus : AppIcons.edit,
                isLoading: isSubmitting,
                onPressed: isSubmitting ? null : _submit,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _DeleteRoleConfirmation extends StatefulWidget {
  const _DeleteRoleConfirmation({
    required this.controller,
    required this.role,
    required this.close,
  });

  final RolesAdministrationController controller;
  final NexaBizCompanyRoleDetails role;
  final _CloseSurface close;

  @override
  State<_DeleteRoleConfirmation> createState() =>
      _DeleteRoleConfirmationState();
}

class _DeleteRoleConfirmationState extends State<_DeleteRoleConfirmation> {
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
        (targetMissing && !state.isDeletingRole)) {
      _closing = true;
      widget.close(context);
      return;
    }
    setState(() {});
  }

  Future<void> _delete() async {
    final state = widget.controller.state;
    if (_closing ||
        state.isDeletingRole ||
        state.companyId != widget.role.companyId) {
      return;
    }
    final success = await widget.controller.deleteRole(widget.role.roleId);
    if (!mounted || !success || _closing) return;
    _closing = true;
    widget.close(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = widget.controller.state;
    final error = state.mutationError?.resolveMessage(l10n);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.authAdminDeleteRoleConfirm(
            widget.role.metadata.displayName.value,
          ),
          style: AppTypography.body(context),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          l10n.authAdminDeleteRoleConfirmMessage,
          style: AppTypography.bodyMedium(context),
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
              onPressed: state.isDeletingRole
                  ? null
                  : () => widget.close(context),
            ),
            AppPermissionGate.hide(
              permissionId:
                  NexaBizAuthorizationAdministrationPermissions.roleManage,
              child: AppButton(
                label: l10n.authAdminActionDelete,
                variant: AppButtonVariant.destructive,
                isLoading: state.isDeletingRole,
                onPressed: state.isDeletingRole ? null : _delete,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
