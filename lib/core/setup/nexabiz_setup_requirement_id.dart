/// Stable setup requirement identity: capability.requirement.
///
/// Validation occurs when the capability registry locks, matching route IDs.
final class NexaBizSetupRequirementId {
  const NexaBizSetupRequirementId(this.value);

  static final RegExp _canonical = RegExp(
    r'^[a-z][a-z0-9_]*\.[a-z][a-z0-9_]*$',
  );

  final String value;

  void validate() {
    if (!_canonical.hasMatch(value)) {
      throw StateError(
        'Setup requirement ID "$value" must be capability.requirement in canonical lower snake case.',
      );
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NexaBizSetupRequirementId && value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value;
}
