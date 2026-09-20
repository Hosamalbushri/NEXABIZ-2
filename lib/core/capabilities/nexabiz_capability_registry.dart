import '../permissions/nexabiz_permission_intent.dart';
import 'contributions/nexabiz_capability_runtime_contributions.dart';
import 'nexabiz_capability.dart';

/// Registry responsible for registering, validating, topologically sorting,
/// and locking NexaBiz capabilities.
///
/// Lifecycle:
/// Construct -> Register -> Validate -> Topological Sort -> Index -> Lock -> Read-only Runtime
class NexaBizCapabilityRegistry {
  // Runtime IDs use lower snake case, without trimming or normalization.
  static final RegExp _canonicalId = RegExp(r'^[a-z][a-z0-9_]*$');
  final Map<String, NexaBizCapability> _registeredCapabilities = {};
  List<NexaBizCapability> _sortedCapabilities = [];
  bool _isLocked = false;

  /// Whether the registry has been validated, sorted, and locked.
  bool get isLocked => _isLocked;

  /// Register a single capability.
  ///
  /// Throws [StateError] if registry is locked or if capability ID is invalid/duplicate.
  void register(NexaBizCapability capability) {
    _checkNotLocked();

    final id = capability.capabilityId;
    if (id.trim().isEmpty) {
      throw StateError('Capability ID cannot be empty or whitespace.');
    }
    if (id != id.trim() || !_canonicalId.hasMatch(id)) {
      throw StateError(
        'Capability ID "$id" must be canonical lower snake case.',
      );
    }

    if (_registeredCapabilities.containsKey(id)) {
      throw StateError('Duplicate capability ID registered: "$id"');
    }

    _registeredCapabilities[id] = capability;
  }

  /// Register a list of capabilities.
  void registerAll(Iterable<NexaBizCapability> capabilities) {
    for (final capability in capabilities) {
      register(capability);
    }
  }

  /// Validate capability dependencies, check for cycles, sort topologically, and lock the registry.
  void validateAndLock() {
    _checkNotLocked();

    // 1. Dependency Validation
    for (final entry in _registeredCapabilities.entries) {
      final capId = entry.key;
      final cap = entry.value;

      // Check for duplicate declarations in dependsOn (NO toSet hiding)
      final dependsOn = cap.dependsOn;
      final uniqueDependsOn = <String>{};
      for (final dep in dependsOn) {
        if (!uniqueDependsOn.add(dep)) {
          throw StateError(
            'Capability "$capId" contains duplicate dependency declaration "$dep".',
          );
        }
      }

      for (final depId in dependsOn) {
        if (depId.trim().isEmpty) {
          throw StateError('Capability "$capId" has an empty dependency ID.');
        }
        if (depId != depId.trim() || !_canonicalId.hasMatch(depId)) {
          throw StateError(
            'Capability "$capId" has noncanonical dependency ID "$depId".',
          );
        }
        if (depId == capId) {
          throw StateError(
            'Capability "$capId" cannot depend on itself (self-dependency).',
          );
        }
        if (!_registeredCapabilities.containsKey(depId)) {
          throw StateError(
            'Capability "$capId" depends on missing capability "$depId".',
          );
        }
      }
    }

    // Runtime contributions are declarations only. Validate identities and
    // duplicate ownership without evaluating setup or permission decisions.
    final providedSetupIds = <String>{};
    final declaredPermissionIds = <String>{};
    for (final entry in _registeredCapabilities.entries) {
      final capability = entry.value;
      if (capability is! NexaBizCapabilityWithRuntimeContributions) continue;
      final setup = capability.setupContribution;
      if (setup != null) {
        final requiredIds = <String>{};
        for (final requirement in setup.providedRequirements) {
          requirement.validate();
          if (!providedSetupIds.add(requirement.value)) {
            throw StateError(
              'Duplicate provided setup requirement "${requirement.value}".',
            );
          }
        }
        for (final requirement in setup.requiredRequirements) {
          requirement.validate();
          if (!requiredIds.add(requirement.value)) {
            throw StateError(
              'Capability "${entry.key}" repeats required setup requirement "${requirement.value}".',
            );
          }
        }
      }
      final permissions = capability.permissionContribution;
      if (permissions != null) {
        final requiredIds = <String>{};
        for (final id in permissions.declaredPermissionIds) {
          _validatePermissionId(id, entry.key);
          if (!declaredPermissionIds.add(id.value)) {
            throw StateError('Duplicate declared permission ID "${id.value}".');
          }
        }
        for (final requirement in permissions.requiredPermissions) {
          final id = requirement.permissionId;
          _validatePermissionId(id, entry.key);
          if (!requiredIds.add(id.value)) {
            throw StateError(
              'Capability "${entry.key}" repeats required permission ID "${id.value}".',
            );
          }
        }
      }
    }

    // 2. Topological Sort & Cycle Detection using Kahn's Algorithm
    // In-degree maps how many unsatisfied dependencies a capability has.
    final inDegree = <String, int>{};
    // Adjacency map: depId -> list of capability IDs that depend on depId
    final dependentsMap = <String, List<String>>{};

    for (final capId in _registeredCapabilities.keys) {
      inDegree[capId] = _registeredCapabilities[capId]!.dependsOn.length;
      dependentsMap[capId] = [];
    }

    for (final entry in _registeredCapabilities.entries) {
      final capId = entry.key;
      for (final depId in entry.value.dependsOn) {
        dependentsMap[depId]!.add(capId);
      }
    }

    // Queue of nodes with 0 in-degree (no dependencies)
    final queue = <String>[];
    for (final entry in inDegree.entries) {
      if (entry.value == 0) {
        queue.add(entry.key);
      }
    }

    // Apply the same precedence whenever dependencies unlock more capabilities.
    int compareReadyCapabilities(String a, String b) {
      final orderA = _registeredCapabilities[a]!.metadata.sortOrder;
      final orderB = _registeredCapabilities[b]!.metadata.sortOrder;
      if (orderA != orderB) return orderA.compareTo(orderB);
      return a.compareTo(b);
    }

    final sortedResult = <NexaBizCapability>[];

    while (queue.isNotEmpty) {
      queue.sort(compareReadyCapabilities);
      final currentId = queue.removeAt(0);
      sortedResult.add(_registeredCapabilities[currentId]!);

      final dependents = dependentsMap[currentId] ?? [];
      for (final dependentId in dependents) {
        inDegree[dependentId] = inDegree[dependentId]! - 1;
        if (inDegree[dependentId] == 0) {
          queue.add(dependentId);
        }
      }
    }

    if (sortedResult.length != _registeredCapabilities.length) {
      throw StateError('Dependency cycle detected in capability registry.');
    }

    _sortedCapabilities = List.unmodifiable(sortedResult);
    _isLocked = true;
  }

  /// Get read-only list of capabilities in topological order.
  ///
  /// Throws [StateError] if registry is not locked.
  List<NexaBizCapability> get capabilities {
    _checkIsLocked();
    return _sortedCapabilities;
  }

  /// Get a capability by its ID.
  ///
  /// Throws [StateError] if registry is not locked.
  NexaBizCapability getCapability(String capabilityId) {
    _checkIsLocked();
    final cap = _registeredCapabilities[capabilityId];
    if (cap == null) {
      throw StateError('Capability "$capabilityId" is not registered.');
    }
    return cap;
  }

  /// Check if a capability exists.
  ///
  /// Throws [StateError] if registry is not locked.
  bool containsCapability(String capabilityId) {
    _checkIsLocked();
    return _registeredCapabilities.containsKey(capabilityId);
  }

  void _checkNotLocked() {
    if (_isLocked) {
      throw StateError('Capability registry is locked and cannot be mutated.');
    }
  }

  static void _validatePermissionId(
    NexaBizPermissionId id,
    String capabilityId,
  ) {
    try {
      NexaBizPermissionId(id.value);
    } on ArgumentError {
      throw StateError(
        'Capability "$capabilityId" declares a noncanonical permission ID "${id.value}".',
      );
    }
  }

  void _checkIsLocked() {
    if (!_isLocked) {
      throw StateError(
        'Capability registry must be validated and locked before reading.',
      );
    }
  }
}
