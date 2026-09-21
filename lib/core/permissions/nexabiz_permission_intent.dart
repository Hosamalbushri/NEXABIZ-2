/// Stable technical permission identity: module.resource.operation.
final class NexaBizPermissionId {
  static final RegExp _canonical = RegExp(
    r'^[a-z][a-z0-9_]*\.[a-z][a-z0-9_]*\.[a-z][a-z0-9_]*$',
  );

  factory NexaBizPermissionId(String value) {
    if (!_canonical.hasMatch(value)) {
      throw ArgumentError.value(
        value,
        'value',
        'Permission ID must be module.resource.operation.',
      );
    }
    return NexaBizPermissionId._(value);
  }

  const NexaBizPermissionId._(this.value);

  final String value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NexaBizPermissionId && value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value;
}

/// Unknown means no configured decision; it is distinct from explicit denial.
/// Invariant: An 'unknown' decision is NOT AUTHORIZED (Fail-Closed principle).
enum NexaBizPermissionDecision {
  allow,
  deny,
  unknown;

  /// True ONLY when explicitly allowed.
  bool get isAllowed => this == NexaBizPermissionDecision.allow;

  /// True when explicitly denied.
  bool get isDenied => this == NexaBizPermissionDecision.deny;

  /// True when the decision is unconfigured or unknown.
  /// Under Fail-Closed semantics, unknown is never authorized.
  bool get isUnknown => this == NexaBizPermissionDecision.unknown;
}

/// Intent to check one permission; no roles, grants, or evaluation are defined.
final class NexaBizPermissionRequirement {
  const NexaBizPermissionRequirement(this.permissionId);

  final NexaBizPermissionId permissionId;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NexaBizPermissionRequirement &&
          permissionId == other.permissionId;

  @override
  int get hashCode => permissionId.hashCode;
}
