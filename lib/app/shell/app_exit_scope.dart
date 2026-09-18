import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:nexabiz_ui/nexabiz_ui.dart';

import '../../l10n/app_localizations.dart';

/// Callback type for application exit confirmation.
typedef AppExitCallback = Future<bool> Function(BuildContext context);

/// Canonical application exit scope.
/// Intercepts system back events at the root shell boundary.
///
/// Navigation Back Hierarchy:
/// 1. If GoRouter branch/root navigator can pop, pops the active top route.
/// 2. If at true root (nothing can pop), presents exit confirmation dialog.
/// 3. If confirmed, requests graceful application termination via [SystemNavigator.pop].
class AppExitPopScope extends StatefulWidget {
  final Widget child;
  final AppExitCallback? onConfirmExit;

  const AppExitPopScope({
    super.key,
    required this.child,
    this.onConfirmExit,
  });

  /// Show canonical exit confirmation dialog.
  static Future<bool> confirmExit(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await AppDialog.confirm(
      context: context,
      title: l10n.exitDialogTitle,
      message: l10n.exitDialogMessage,
      confirmLabel: l10n.actionExit,
      cancelLabel: l10n.actionCancel,
      tone: AppDialogTone.warning,
    );
    return confirmed ?? false;
  }

  @override
  State<AppExitPopScope> createState() => _AppExitPopScopeState();
}

class _AppExitPopScopeState extends State<AppExitPopScope>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Future<bool> didPopRoute() async {
    return await _handlePop();
  }

  Future<bool> _handlePop() async {
    if (!mounted) return false;

    // 1. If an overlay/sheet like QuickActionsPanel is open, close it
    if (AppQuickActionsPanel.closeActivePanel(context)) {
      return true;
    }

    // 2. If GoRouter has pushed sub-routes, pop the top sub-route
    final router = GoRouter.maybeOf(context);
    final canPop = router != null && router.canPop();
    if (canPop) {
      router.pop();
      return true;
    }

    // At true root — show exit confirmation dialog
    final shouldExit = widget.onConfirmExit != null
        ? await widget.onConfirmExit!(context)
        : await AppExitPopScope.confirmExit(context);

    if (shouldExit) {
      await SystemNavigator.pop();
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _handlePop();
      },
      child: widget.child,
    );
  }
}
