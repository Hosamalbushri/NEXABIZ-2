import 'nexabiz_role_scope.dart';

/// Validated, canonical identity of a role: namespace.name (e.g. system.admin, company.owner).
///
/// ARCHITECTURAL PRINCIPLE: Role != Permission.
/// Role IDs are distinct from Permission IDs. Holding a role name or ID does NOT
/// grant an implicit bypass or automatic access; permissions must always be
/// evaluated explicitly. No "owner" or "admin" string check may bypass security.
final class NexaBizRoleId {
  static final RegExp _canonical = RegExp(
    r'^[a-z][a-z0-9_]*\.[a-z][a-z0-9_]*$',
  );

  factory NexaBizRoleId(String value) {
    if (!_canonical.hasMatch(value)) {
      throw ArgumentError.value(
        value,
        'value',
        'Role ID must be canonical lowercase namespace.name format without spaces.',
      );
    }
    return NexaBizRoleId._(value);
  }

  factory NexaBizRoleId.scoped(NexaBizRoleScope scope, String roleName) {
    return NexaBizRoleId('${scope.name}.$roleName');
  }

  const NexaBizRoleId._(this.value);

  final String value;

  String get namespace => value.substring(0, value.indexOf('.'));

  String get roleName => value.substring(value.indexOf('.') + 1);

  NexaBizRoleScope get scope => switch (namespace) {
        'system' => NexaBizRoleScope.system,
        'company' => NexaBizRoleScope.company,
        _ => throw StateError('Unrecognized role scope namespace: "$namespace".'),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NexaBizRoleId && value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value;
}

