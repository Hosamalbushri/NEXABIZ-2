import '../permissions/nexabiz_permission_intent.dart';

/// Pure Dart immutable read-only catalog of declared capability permissions.
///
/// Serves as the single source of truth for whether a [NexaBizPermissionId]
/// is a legitimate declared permission in the application.
abstract interface class NexaBizPermissionCatalog {
  /// Checks whether [permissionId] has been declared by an active capability.
  bool isDeclared(NexaBizPermissionId permissionId);

  /// All declared permission identifiers in the catalog.
  Set<NexaBizPermissionId> get declaredPermissions;
}

/// Canonical immutable implementation of [NexaBizPermissionCatalog].
final class NexaBizImmutablePermissionCatalog implements NexaBizPermissionCatalog {
  const NexaBizImmutablePermissionCatalog(this._declaredPermissions);

  final Set<NexaBizPermissionId> _declaredPermissions;

  @override
  bool isDeclared(NexaBizPermissionId permissionId) =>
      _declaredPermissions.contains(permissionId);

  @override
  Set<NexaBizPermissionId> get declaredPermissions =>
      Set.unmodifiable(_declaredPermissions);
}

