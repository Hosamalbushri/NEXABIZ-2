/// Validated, opaque identity of a company membership. No trimming or normalization occurs.
final class NexaBizMembershipId {
  factory NexaBizMembershipId(String value) {
    if (value.isEmpty || value.trim() != value) {
      throw ArgumentError.value(
        value,
        'value',
        'Membership ID must be non-empty and unpadded.',
      );
    }
    return NexaBizMembershipId._(value);
  }

  const NexaBizMembershipId._(this.value);

  final String value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NexaBizMembershipId && value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'NexaBizMembershipId(<redacted>)';
}

