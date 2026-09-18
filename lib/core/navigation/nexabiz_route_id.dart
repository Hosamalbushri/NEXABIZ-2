/// Framework-neutral logical route identity.
///
/// Combines a [namespace] (e.g. 'demo', 'financial') and a [routeName] (e.g. 'root', 'coa').
/// Route identity must be globally unique across all capabilities.
class NexaBizRouteId {
  static final RegExp _canonicalSegment = RegExp(r'^[a-z][a-z0-9_]*$');
  final String namespace;
  final String routeName;

  const NexaBizRouteId({required this.namespace, required this.routeName});

  /// Canonical string representation (e.g., 'financial.coa').
  String get value => '$namespace.$routeName';

  /// Reject invalid segments without normalizing them. Called at collection time
  /// so const metadata is checked in release builds as well as debug builds.
  void validate() {
    for (final segment in [namespace, routeName]) {
      if (segment != segment.trim() || !_canonicalSegment.hasMatch(segment)) {
        throw StateError(
          'Route ID "$value" must contain canonical lower snake case segments.',
        );
      }
    }
  }

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
