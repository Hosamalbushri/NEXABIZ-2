import 'package:flutter/foundation.dart';

/// Flutter [Listenable] invalidation signal notifying the router and application layers
/// when user roles, permissions, or assignments have been modified.
///
/// Architectural Pattern:
/// ```text
/// Persistence / Mutation
///        ↓
/// NexaBizAuthorizationInvalidationSignal.notifyAuthorizationChanged()
///        ↓
/// Router refreshListenable
///        ↓
/// NexaBizGoRouterAdapter.redirect()
///        ↓
/// NexaBizPermissionEvaluator.evaluate() (reads fresh relational state)
/// ```
///
/// This maintains clean architectural separation:
/// - The Router does NOT watch Drift/SQLite tables.
/// - The Router does NOT perform role/permission diffing.
/// - The Router simply re-evaluates its current location via the authoritative evaluator.
final class NexaBizAuthorizationInvalidationSignal extends ChangeNotifier {
  /// Emits an invalidation event triggering re-evaluation of protected navigation routes.
  void notifyAuthorizationChanged() {
    notifyListeners();
  }
}
