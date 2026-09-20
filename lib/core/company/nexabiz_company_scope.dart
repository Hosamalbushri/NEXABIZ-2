/// Validated, opaque identity of one company. No trimming or normalization occurs.
final class NexaBizCompanyId {
  factory NexaBizCompanyId(String value) {
    if (value.isEmpty || value.trim() != value) {
      throw ArgumentError.value(
        value,
        'value',
        'Company ID must be non-empty and unpadded.',
      );
    }
    return NexaBizCompanyId._(value);
  }

  const NexaBizCompanyId._(this.value);

  final String value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NexaBizCompanyId && value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'NexaBizCompanyId(<redacted>)';
}

/// Either a company workspace or the unscoped system-setup phase.
final class NexaBizCompanyScope {
  const NexaBizCompanyScope.systemSetup() : companyId = null;

  const NexaBizCompanyScope.company(NexaBizCompanyId this.companyId);

  final NexaBizCompanyId? companyId;

  bool get isSystemSetup => companyId == null;
  bool get isCompany => companyId != null;

  /// Fails if a company-bound operation receives the global setup scope.
  NexaBizCompanyId requireCompany() {
    final id = companyId;
    if (id == null) {
      throw StateError('A company scope is required for this operation.');
    }
    return id;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NexaBizCompanyScope && companyId == other.companyId;

  @override
  int get hashCode => Object.hash(NexaBizCompanyScope, companyId);

  @override
  String toString() => isCompany
      ? 'NexaBizCompanyScope.company(<redacted>)'
      : 'NexaBizCompanyScope.systemSetup';
}
