import 'package:flutter_test/flutter_test.dart';
import 'package:nexabiz/core/capabilities/capability_metadata.dart';
import 'package:nexabiz/core/capabilities/nexabiz_capability.dart';
import 'package:nexabiz/core/capabilities/nexabiz_capability_registry.dart';
import 'package:nexabiz/core/navigation/nexabiz_navigation_contribution.dart';

class _TestCapability implements NexaBizCapability {
  @override
  final String capabilityId;
  @override
  final CapabilityMetadata metadata;
  @override
  final List<String> dependsOn;
  @override
  NexaBizNavigationContribution? get navigationContribution => null;

  _TestCapability({
    required this.capabilityId,
    this.dependsOn = const [],
    int sortOrder = 0,
  }) : metadata = CapabilityMetadata(
          nameKey: 'test.$capabilityId',
          iconIdentifier: 'test',
          sortOrder: sortOrder,
        );
}

void main() {
  group('NexaBizCapabilityRegistry', () {
    late NexaBizCapabilityRegistry registry;

    setUp(() {
      registry = NexaBizCapabilityRegistry();
    });

    test('successfully registers, validates, sorts, and locks valid capabilities', () {
      final capA = _TestCapability(capabilityId: 'capA');
      final capB = _TestCapability(capabilityId: 'capB', dependsOn: ['capA']);

      registry.register(capB);
      registry.register(capA);
      expect(registry.isLocked, isFalse);

      registry.validateAndLock();
      expect(registry.isLocked, isTrue);

      final sorted = registry.capabilities;
      expect(sorted.length, equals(2));
      expect(sorted[0].capabilityId, equals('capA'));
      expect(sorted[1].capabilityId, equals('capB'));
    });

    test('rejects registration of empty capability ID', () {
      final emptyCap = _TestCapability(capabilityId: '  ');
      expect(() => registry.register(emptyCap), throwsStateError);
    });

    test('rejects duplicate capability IDs', () {
      final cap1 = _TestCapability(capabilityId: 'dup');
      final cap2 = _TestCapability(capabilityId: 'dup');

      registry.register(cap1);
      expect(() => registry.register(cap2), throwsStateError);
    });

    test('rejects self-dependency', () {
      final selfCap = _TestCapability(capabilityId: 'self', dependsOn: ['self']);
      registry.register(selfCap);

      expect(() => registry.validateAndLock(), throwsStateError);
    });

    test('rejects missing dependencies', () {
      final cap = _TestCapability(capabilityId: 'dependent', dependsOn: ['nonExistent']);
      registry.register(cap);

      expect(() => registry.validateAndLock(), throwsStateError);
    });

    test('rejects duplicate dependency declarations in dependsOn list', () {
      final capA = _TestCapability(capabilityId: 'capA');
      final capB = _TestCapability(capabilityId: 'capB', dependsOn: ['capA', 'capA']);

      registry.register(capA);
      registry.register(capB);

      expect(() => registry.validateAndLock(), throwsStateError);
    });

    test('rejects dependency cycle between two capabilities', () {
      final capA = _TestCapability(capabilityId: 'capA', dependsOn: ['capB']);
      final capB = _TestCapability(capabilityId: 'capB', dependsOn: ['capA']);

      registry.register(capA);
      registry.register(capB);

      expect(() => registry.validateAndLock(), throwsStateError);
    });

    test('rejects dependency cycle among three capabilities', () {
      final capA = _TestCapability(capabilityId: 'capA', dependsOn: ['capC']);
      final capB = _TestCapability(capabilityId: 'capB', dependsOn: ['capA']);
      final capC = _TestCapability(capabilityId: 'capC', dependsOn: ['capB']);

      registry.register(capA);
      registry.register(capB);
      registry.register(capC);

      expect(() => registry.validateAndLock(), throwsStateError);
    });

    test('prevents mutation after locking', () {
      final cap = _TestCapability(capabilityId: 'cap');
      registry.register(cap);
      registry.validateAndLock();

      final newCap = _TestCapability(capabilityId: 'newCap');
      expect(() => registry.register(newCap), throwsStateError);
    });

    test('prevents reading before locking', () {
      final cap = _TestCapability(capabilityId: 'cap');
      registry.register(cap);

      expect(() => registry.capabilities, throwsStateError);
      expect(() => registry.getCapability('cap'), throwsStateError);
      expect(() => registry.containsCapability('cap'), throwsStateError);
    });
  });
}
