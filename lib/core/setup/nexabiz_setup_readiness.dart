enum NexaBizSetupState { uninitialized, inProgress, ready, blocked }

/// Requirements for Core initialization only.
enum NexaBizSetupRequirement { company, adminUser }

/// Immutable snapshot of global setup progress.
final class NexaBizSetupReadiness {
  static const Set<NexaBizSetupRequirement> requiredCoreRequirements = {
    NexaBizSetupRequirement.company,
    NexaBizSetupRequirement.adminUser,
  };

  factory NexaBizSetupReadiness({
    required NexaBizSetupState state,
    required Iterable<NexaBizSetupRequirement> completed,
  }) {
    final completedSet = Set<NexaBizSetupRequirement>.unmodifiable(completed);
    if (state == NexaBizSetupState.ready &&
        !completedSet.containsAll(requiredCoreRequirements)) {
      throw StateError(
        'Setup cannot be ready while mandatory requirements are missing.',
      );
    }
    return NexaBizSetupReadiness._(state, completedSet);
  }

  const NexaBizSetupReadiness._(this.state, this.completed);

  final NexaBizSetupState state;
  final Set<NexaBizSetupRequirement> completed;

  bool get isReady => state == NexaBizSetupState.ready;

  Set<NexaBizSetupRequirement> get missing =>
      Set<NexaBizSetupRequirement>.unmodifiable(
        requiredCoreRequirements.difference(completed),
      );
}
