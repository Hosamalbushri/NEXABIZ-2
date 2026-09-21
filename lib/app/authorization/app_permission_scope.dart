import 'package:flutter/widgets.dart';

import '../../core/authorization/nexabiz_permission_evaluator.dart';
import '../../core/session/core_session_controller.dart';

/// Scoped [InheritedWidget] providing authorization evaluation dependencies
/// to presentation widgets such as [AppPermissionGate].
///
/// Ensures clean dependency injection without relying on global singletons
/// or service locators.
class AppPermissionScope extends InheritedWidget {
  /// The authoritative permission evaluator for the current application runtime.
  final NexaBizPermissionEvaluator permissionEvaluator;

  /// The active session controller managing authenticated session lifecycle.
  final CoreSessionController sessionController;

  /// Optional notification signal fired when permissions are mutated in persistence.
  final Listenable? invalidationSignal;

  const AppPermissionScope({
    super.key,
    required this.permissionEvaluator,
    required this.sessionController,
    this.invalidationSignal,
    required super.child,
  });

  /// Retrieves the nearest [AppPermissionScope] from the given [BuildContext], or null if absent.
  static AppPermissionScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AppPermissionScope>();
  }

  /// Retrieves the nearest [AppPermissionScope] from the given [BuildContext].
  /// Throws [FlutterError] if no [AppPermissionScope] is found in the ancestor tree.
  static AppPermissionScope of(BuildContext context) {
    final scope = maybeOf(context);
    assert(scope != null, 'No AppPermissionScope found in ancestor context.');
    return scope!;
  }

  @override
  bool updateShouldNotify(AppPermissionScope oldWidget) {
    return permissionEvaluator != oldWidget.permissionEvaluator ||
        sessionController != oldWidget.sessionController ||
        invalidationSignal != oldWidget.invalidationSignal;
  }
}
