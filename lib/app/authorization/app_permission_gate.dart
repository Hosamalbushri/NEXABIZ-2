import 'dart:async';

import 'package:flutter/widgets.dart';

import '../../core/authorization/nexabiz_authorization_context.dart';
import '../../core/authorization/nexabiz_permission_evaluator.dart';
import '../../core/permissions/nexabiz_permission_intent.dart';
import '../../core/session/core_session_controller.dart';
import '../../core/session/nexabiz_session.dart';
import 'app_permission_scope.dart';

/// Presentation mode configuring how [AppPermissionGate] displays unauthorized actions.
enum AppPermissionGateMode {
  /// Hides the protected UI completely when permission is not granted.
  hide,

  /// Displays the protected UI in a disabled, non-interactive state when permission is not granted.
  disable,
}

/// [AppPermissionGate] is a UX-only presentation primitive used to adapt
/// interface visibility and interactivity based on real-time permission evaluation.
///
/// IMPORTANT ARCHITECTURAL CONTRACT:
/// 1. AppPermissionGate MUST NOT be used as the sole authorization mechanism.
///    It is strictly a user-experience enhancement (hiding/disabling controls).
/// 2. Protected operations and business mutations MUST still invoke and enforce
///    NexaBizPermissionGuard at the UseCase layer, which remains the single
///    authoritative security boundary.
/// 3. Fail-Closed UX: While evaluating, or in the event of missing dependencies,
///    invalid context, unknown permissions, or evaluation failure, access is
///    strictly denied (hidden in [AppPermissionGateMode.hide], disabled in
///    [AppPermissionGateMode.disable]).
class AppPermissionGate extends StatefulWidget {
  /// The canonical permission required to access or interact with the child UI.
  final NexaBizPermissionId permissionId;

  /// Whether to hide the child entirely or present it in a disabled state.
  final AppPermissionGateMode mode;

  /// The widget to display when permission is granted (used when [builder] is omitted).
  final Widget? child;

  /// Builder providing the active authorization status [isAllowed] to construct child UI.
  ///
  /// In [AppPermissionGateMode.disable], callers should use [isAllowed] to
  /// construct the component in its native disabled state (for example, by
  /// passing a null callback). The gate additionally enforces a fail-closed
  /// pointer, focus, keyboard, and accessibility interaction boundary while
  /// [isAllowed] is false.
  final Widget Function(BuildContext context, bool isAllowed)? builder;

  /// Optional replacement widget when permission is denied or pending in [AppPermissionGateMode.hide] mode.
  /// Defaults to [SizedBox.shrink()].
  final Widget? fallback;

  /// Optional explicit permission evaluator (overrides [AppPermissionScope]).
  final NexaBizPermissionEvaluator? evaluator;

  /// Optional explicit session controller (overrides [AppPermissionScope]).
  final CoreSessionController? sessionController;

  /// Optional explicit invalidation signal (overrides [AppPermissionScope]).
  final Listenable? invalidationSignal;

  const AppPermissionGate({
    super.key,
    required this.permissionId,
    this.mode = AppPermissionGateMode.hide,
    this.child,
    this.builder,
    this.fallback,
    this.evaluator,
    this.sessionController,
    this.invalidationSignal,
  }) : assert(
         child != null || builder != null,
         'Either child or builder must be provided to AppPermissionGate.',
       );

  /// Convenience constructor for hiding unauthorized UI.
  const AppPermissionGate.hide({
    super.key,
    required this.permissionId,
    required Widget this.child,
    this.fallback,
    this.evaluator,
    this.sessionController,
    this.invalidationSignal,
  }) : mode = AppPermissionGateMode.hide,
       builder = null;

  /// Convenience constructor for disabling unauthorized actions via a builder.
  const AppPermissionGate.disable({
    super.key,
    required this.permissionId,
    required Widget Function(BuildContext context, bool isAllowed) this.builder,
    this.fallback,
    this.evaluator,
    this.sessionController,
    this.invalidationSignal,
  }) : mode = AppPermissionGateMode.disable,
       child = null;

  /// Convenience builder constructor supporting custom presentation based on [isAllowed].
  const AppPermissionGate.builder({
    super.key,
    required this.permissionId,
    this.mode = AppPermissionGateMode.hide,
    required Widget Function(BuildContext context, bool isAllowed) this.builder,
    this.fallback,
    this.evaluator,
    this.sessionController,
    this.invalidationSignal,
  }) : child = null;

  @override
  State<AppPermissionGate> createState() => _AppPermissionGateState();
}

class _AppPermissionGateState extends State<AppPermissionGate> {
  bool _isAllowed = false;
  bool _isEvaluating = true;
  int _evaluationGeneration = 0;

  StreamSubscription<NexaBizSession>? _sessionSubscription;
  Listenable? _observedInvalidationSignal;
  CoreSessionController? _observedSessionController;

  @override
  void initState() {
    super.initState();
    // Subscriptions and initial evaluation happen in didChangeDependencies
    // to ensure InheritedWidget dependencies are resolved properly.
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateListenersAndEvaluate();
  }

  @override
  void didUpdateWidget(covariant AppPermissionGate oldWidget) {
    super.didUpdateWidget(oldWidget);
    final dependenciesChanged =
        widget.permissionId != oldWidget.permissionId ||
        widget.evaluator != oldWidget.evaluator ||
        widget.sessionController != oldWidget.sessionController ||
        widget.invalidationSignal != oldWidget.invalidationSignal;

    if (dependenciesChanged) {
      _updateListenersAndEvaluate();
    }
  }

  NexaBizPermissionEvaluator? _resolveEvaluator() {
    return widget.evaluator ??
        AppPermissionScope.maybeOf(context)?.permissionEvaluator;
  }

  CoreSessionController? _resolveSessionController() {
    return widget.sessionController ??
        AppPermissionScope.maybeOf(context)?.sessionController;
  }

  Listenable? _resolveInvalidationSignal() {
    return widget.invalidationSignal ??
        AppPermissionScope.maybeOf(context)?.invalidationSignal;
  }

  void _updateListenersAndEvaluate() {
    final sessionController = _resolveSessionController();
    if (_observedSessionController != sessionController) {
      _sessionSubscription?.cancel();
      _observedSessionController = sessionController;
      if (sessionController != null) {
        _sessionSubscription = sessionController.onSessionChanged.listen((_) {
          _evaluate();
        });
      }
    }

    final invalidationSignal = _resolveInvalidationSignal();
    if (_observedInvalidationSignal != invalidationSignal) {
      _observedInvalidationSignal?.removeListener(_onInvalidationNotified);
      _observedInvalidationSignal = invalidationSignal;
      _observedInvalidationSignal?.addListener(_onInvalidationNotified);
    }

    _evaluate();
  }

  void _onInvalidationNotified() {
    _evaluate();
  }

  Future<void> _evaluate() async {
    final generation = ++_evaluationGeneration;
    _applyPendingDecision(generation);

    final sessionController = _resolveSessionController();
    final evaluator = _resolveEvaluator();

    final activeSession = sessionController?.currentSession;
    if (activeSession == null || !activeSession.isActive || evaluator == null) {
      _applyDecision(false, generation);
      return;
    }

    // Construct trusted authorization context from authoritative session
    final NexaBizAuthorizationContext authContext;
    try {
      authContext = NexaBizAuthorizationContext.fromSession(activeSession);
    } catch (_) {
      // Invalid context -> Fail-Closed
      _applyDecision(false, generation);
      return;
    }

    // Capture session identity before async flight for concurrency verification
    final sessionAtStartId = activeSession.sessionId;
    final companyAtStartId = activeSession.companyId;
    final membershipAtStartId = activeSession.membershipId;

    final NexaBizPermissionDecision decision;
    try {
      decision = await evaluator.evaluate(
        context: authContext,
        permissionId: widget.permissionId,
      );
    } catch (_) {
      // Infrastructure or evaluation failure -> Fail-Closed
      _applyDecision(false, generation);
      return;
    }

    if (!mounted) return;

    // Stale check 1: Has another evaluation request superseded this one?
    if (generation != _evaluationGeneration) {
      return;
    }

    // Stale check 2: Has active session mutated during flight (logout/switch/membership)?
    final sessionAtEnd = sessionController?.currentSession;
    if (sessionAtEnd == null ||
        !sessionAtEnd.isActive ||
        sessionAtEnd.sessionId != sessionAtStartId ||
        sessionAtEnd.companyId != companyAtStartId ||
        sessionAtEnd.membershipId != membershipAtStartId) {
      // Reject stale in-flight result
      _applyDecision(false, generation);
      return;
    }

    _applyDecision(decision.isAllowed, generation);
  }

  void _applyPendingDecision(int generation) {
    if (!mounted || generation != _evaluationGeneration) return;
    if (_isAllowed || !_isEvaluating) {
      setState(() {
        _isAllowed = false;
        _isEvaluating = true;
      });
    }
  }

  void _applyDecision(bool isAllowed, int generation) {
    if (!mounted || generation != _evaluationGeneration) return;
    if (_isAllowed != isAllowed || _isEvaluating) {
      setState(() {
        _isAllowed = isAllowed;
        _isEvaluating = false;
      });
    }
  }

  @override
  void dispose() {
    _evaluationGeneration++;
    _sessionSubscription?.cancel();
    _observedInvalidationSignal?.removeListener(_onInvalidationNotified);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.mode == AppPermissionGateMode.hide) {
      if (widget.builder != null) {
        return widget.builder!(context, _isAllowed);
      }
      if (_isAllowed) {
        return widget.child!;
      }
      return widget.fallback ?? const SizedBox.shrink();
    }

    // AppPermissionGateMode.disable
    if (widget.builder != null) {
      final child = widget.builder!(context, _isAllowed);
      return _isAllowed ? child : _buildDisabledInteractionBoundary(child);
    }

    if (widget.child != null) {
      if (_isAllowed) {
        return widget.child!;
      }
      return _buildDisabledInteractionBoundary(
        Opacity(opacity: 0.5, child: widget.child!),
      );
    }

    return widget.fallback ?? const SizedBox.shrink();
  }

  Widget _buildDisabledInteractionBoundary(Widget child) {
    return Semantics(
      enabled: false,
      blockUserActions: true,
      child: ExcludeFocus(child: IgnorePointer(child: child)),
    );
  }
}
