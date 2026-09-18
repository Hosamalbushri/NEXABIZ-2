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

    test(
      'successfully registers, validates, sorts, and locks valid capabilities',
      () {
        final capA = _TestCapability(capabilityId: 'cap_a');
        final capB = _TestCapability(
          capabilityId: 'cap_b',
          dependsOn: ['cap_a'],
        );

        registry.register(capB);
        registry.register(capA);
        expect(registry.isLocked, isFalse);

        registry.validateAndLock();
        expect(registry.isLocked, isTrue);

        final sorted = registry.capabilities;
        expect(sorted.length, equals(2));
        expect(sorted[0].capabilityId, equals('cap_a'));
        expect(sorted[1].capabilityId, equals('cap_b'));
      },
    );

    test('rejects registration of empty capability ID', () {
      final emptyCap = _TestCapability(capabilityId: '  ');
      expect(() => registry.register(emptyCap), throwsStateError);
    });

    for (final id in [
      '',
      ' ',
      '\t\n',
      ' padded',
      'padded ',
      'CamelCase',
      'dash-name',
      'dot.name',
      '1start',
      '_start',
      'two words',
    ]) {
      test('rejects noncanonical capability ID ${id.codeUnits}', () {
        expect(
          () => registry.register(_TestCapability(capabilityId: id)),
          throwsStateError,
        );
        expect(registry.isLocked, isFalse);
      });
    }

    for (final id in [
      '',
      ' ',
      ' root',
      'root ',
      'CamelCase',
      'dash-name',
      'dot.name',
    ]) {
      test('rejects noncanonical dependency ID ${id.codeUnits}', () {
        registry.register(_TestCapability(capabilityId: 'root'));
        registry.register(
          _TestCapability(capabilityId: 'dependent', dependsOn: [id]),
        );
        expect(
          registry.validateAndLock,
          throwsA(
            isA<StateError>().having(
              (error) => error.message,
              'message',
              anyOf(
                contains('empty dependency ID'),
                contains('noncanonical dependency ID'),
              ),
            ),
          ),
        );
        expect(registry.isLocked, isFalse);
      });
    }

    test(
      'orders newly ready capabilities independently of registration order',
      () {
        final capabilities = [
          _TestCapability(capabilityId: 'root', sortOrder: -10),
          _TestCapability(capabilityId: 'z', dependsOn: ['root']),
          _TestCapability(capabilityId: 'a', dependsOn: ['root']),
          _TestCapability(
            capabilityId: 'urgent',
            dependsOn: ['root'],
            sortOrder: -5,
          ),
          _TestCapability(capabilityId: 'independent', sortOrder: 10),
        ];
        for (final registrationOrder in [capabilities, capabilities.reversed]) {
          final registry = NexaBizCapabilityRegistry();
          registry.registerAll(registrationOrder);
          registry.validateAndLock();
          expect(
            registry.capabilities.map((capability) => capability.capabilityId),
            ['root', 'urgent', 'a', 'z', 'independent'],
          );
        }
      },
    );

    test(
      'failed dependency validation can be retried after registering the dependency',
      () {
        registry.register(
          _TestCapability(capabilityId: 'dependent', dependsOn: ['missing']),
        );
        expect(registry.validateAndLock, throwsStateError);
        expect(registry.isLocked, isFalse);
        registry.register(_TestCapability(capabilityId: 'missing'));
        registry.validateAndLock();
        expect(
          registry.capabilities.map((capability) => capability.capabilityId),
          ['missing', 'dependent'],
        );
        expect(() => registry.capabilities.clear(), throwsUnsupportedError);
        expect(registry.validateAndLock, throwsStateError);
      },
    );

    test('rejects an empty dependency ID', () {
      registry.register(
        _TestCapability(capabilityId: 'test', dependsOn: [' ']),
      );
      expect(registry.validateAndLock, throwsStateError);
      expect(registry.isLocked, isFalse);
    });

    test('rejects duplicate capability IDs', () {
      final cap1 = _TestCapability(capabilityId: 'dup');
      final cap2 = _TestCapability(capabilityId: 'dup');

      registry.register(cap1);
      expect(() => registry.register(cap2), throwsStateError);
    });

    test('rejects self-dependency', () {
      final selfCap = _TestCapability(
        capabilityId: 'self',
        dependsOn: ['self'],
      );
      registry.register(selfCap);

      expect(() => registry.validateAndLock(), throwsStateError);
    });

    test('rejects missing dependencies', () {
      final cap = _TestCapability(
        capabilityId: 'dependent',
        dependsOn: ['non_existent'],
      );
      registry.register(cap);

      expect(() => registry.validateAndLock(), throwsStateError);
    });

    test('rejects duplicate dependency declarations in dependsOn list', () {
      final capA = _TestCapability(capabilityId: 'cap_a');
      final capB = _TestCapability(
        capabilityId: 'cap_b',
        dependsOn: ['cap_a', 'cap_a'],
      );

      registry.register(capA);
      registry.register(capB);

      expect(() => registry.validateAndLock(), throwsStateError);
    });

    test('rejects dependency cycle between two capabilities', () {
      final capA = _TestCapability(capabilityId: 'cap_a', dependsOn: ['cap_b']);
      final capB = _TestCapability(capabilityId: 'cap_b', dependsOn: ['cap_a']);

      registry.register(capA);
      registry.register(capB);

      expect(() => registry.validateAndLock(), throwsStateError);
    });

    test('rejects dependency cycle among three capabilities', () {
      final capA = _TestCapability(capabilityId: 'cap_a', dependsOn: ['cap_c']);
      final capB = _TestCapability(capabilityId: 'cap_b', dependsOn: ['cap_a']);
      final capC = _TestCapability(capabilityId: 'cap_c', dependsOn: ['cap_b']);

      registry.register(capA);
      registry.register(capB);
      registry.register(capC);

      expect(() => registry.validateAndLock(), throwsStateError);
    });

    test('prevents mutation after locking', () {
      final cap = _TestCapability(capabilityId: 'cap');
      registry.register(cap);
      registry.validateAndLock();

      final newCap = _TestCapability(capabilityId: 'new_cap');
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
