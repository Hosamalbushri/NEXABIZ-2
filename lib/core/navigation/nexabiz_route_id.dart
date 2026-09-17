/// Framework-neutral logical route identity.
///
/// Combines a [namespace] (e.g. 'demo', 'financial') and a [routeName] (e.g. 'root', 'coa').
/// Route identity must be globally unique across all capabilities.
class NexaBizRouteId {
  final String namespace;
  final String routeName;

  const NexaBizRouteId({
    required this.namespace,
    required this.routeName,
  });

  /// Canonical string representation (e.g., 'financial.coa').
  String get value => '$namespace.$routeName';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NexaBizRouteId &&
          runtimeType == other.runtimeType &&
          namespace == other.namespace &&
          routeName == other.routeName;

  @override
  int get hashCode => namespace.hashCode ^ routeName.hashCode;

  @override
  String toString() => value;
}
