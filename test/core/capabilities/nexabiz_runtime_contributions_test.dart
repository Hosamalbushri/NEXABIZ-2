import '../../support/bootstrap_test_helper.dart';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:nexabiz/core/capabilities/capability_metadata.dart';
import 'package:nexabiz/core/capabilities/contributions/nexabiz_capability_runtime_contributions.dart';
import 'package:nexabiz/core/capabilities/nexabiz_capability_registry.dart';
import 'package:nexabiz/core/capabilities/contributions/nexabiz_permission_contribution.dart';
import 'package:nexabiz/core/capabilities/contributions/nexabiz_setup_contribution.dart';
import 'package:nexabiz/core/navigation/nexabiz_navigation_contribution.dart';
import 'package:nexabiz/core/navigation/nexabiz_route_access_requirement.dart';
import 'package:nexabiz/core/navigation/nexabiz_route_definition.dart';
import 'package:nexabiz/core/navigation/nexabiz_route_id.dart';
import 'package:nexabiz/core/permissions/nexabiz_permission_intent.dart';
import 'package:nexabiz/core/setup/nexabiz_setup_requirement_id.dart';

class _Capability implements NexaBizCapabilityWithRuntimeContributions {
  _Capability(
    this.capabilityId, {
    this.setupContribution,
    this.permissionContribution,
  });

  @override
  final String capabilityId;
  @override
  final NexaBizSetupContribution? setupContribution;
  @override
  final NexaBizPermissionContribution? permissionContribution;
  @override
  CapabilityMetadata get metadata => const CapabilityMetadata(
    nameKey: 'testCapability',
    iconIdentifier: 'test',
  );
  @override
  List<String> get dependsOn => const [];
  @override
  NexaBizNavigationContribution? get navigationContribution => null;
}

class _Setup implements NexaBizSetupContribution {
  _Setup({
    this.providedRequirements = const [],
    this.requiredRequirements = const [],
  });
  @override
  final List<NexaBizSetupRequirementId> providedRequirements;
  @override
  final List<NexaBizSetupRequirementId> requiredRequirements;
}

class _Permissions implements NexaBizPermissionContribution {
  _Permissions({
    this.declaredPermissionIds = const [],
    this.requiredPermissions = const [],
  });
  @override
  final List<NexaBizPermissionId> declaredPermissionIds;
  @override
  final List<NexaBizPermissionRequirement> requiredPermissions;
}

void main() {
  test(
    'capabilities without contributions and current manifest still bootstrap',
    () async {
      final registry = NexaBizCapabilityRegistry()
        ..register(_Capability('plain'));
      registry.validateAndLock();
      expect(registry.isLocked, isTrue);
      final bootstrap = await bootstrapForTest();
      expect(bootstrap.capabilityRegistry.isLocked, isTrue);
      bootstrap.router.dispose();
    },
  );

  test('accepts canonical setup contributions', () {
    final registry = NexaBizCapabilityRegistry()
      ..register(
        _Capability(
          'one',
          setupContribution: _Setup(
            providedRequirements: [
              const NexaBizSetupRequirementId('one.ready'),
            ],
            requiredRequirements: [
              const NexaBizSetupRequirementId('base.company'),
            ],
          ),
        ),
      );
    registry.validateAndLock();
    expect(registry.isLocked, isTrue);
  });

  test('rejects noncanonical setup requirement IDs at lock', () {
    final registry = NexaBizCapabilityRegistry()
      ..register(
        _Capability(
          'one',
          setupContribution: _Setup(
            providedRequirements: [
              const NexaBizSetupRequirementId('Bad Requirement'),
            ],
          ),
        ),
      );
    expect(registry.validateAndLock, throwsStateError);
    expect(registry.isLocked, isFalse);
  });

  test('rejects duplicate provided setup requirement IDs', () {
    final registry = NexaBizCapabilityRegistry()
      ..register(
        _Capability(
          'one',
          setupContribution: _Setup(
            providedRequirements: [
              const NexaBizSetupRequirementId('one.ready'),
            ],
          ),
        ),
      )
      ..register(
        _Capability(
          'two',
          setupContribution: _Setup(
            providedRequirements: [
              const NexaBizSetupRequirementId('one.ready'),
            ],
          ),
        ),
      );
    expect(registry.validateAndLock, throwsStateError);
  });

  test('accepts canonical permission declarations and requirements', () {
    final registry = NexaBizCapabilityRegistry()
      ..register(
        _Capability(
          'one',
          permissionContribution: _Permissions(
            declaredPermissionIds: [NexaBizPermissionId('one.record.view')],
            requiredPermissions: [
              NexaBizPermissionRequirement(
                NexaBizPermissionId('base.company.read'),
              ),
            ],
          ),
        ),
      );
    registry.validateAndLock();
    expect(registry.isLocked, isTrue);
  });

  test('rejects duplicate declared permission IDs across capabilities', () {
    final id = NexaBizPermissionId('one.record.view');
    final registry = NexaBizCapabilityRegistry()
      ..register(
        _Capability(
          'one',
          permissionContribution: _Permissions(declaredPermissionIds: [id]),
        ),
      )
      ..register(
        _Capability(
          'two',
          permissionContribution: _Permissions(declaredPermissionIds: [id]),
        ),
      );
    expect(registry.validateAndLock, throwsStateError);
    expect(registry.isLocked, isFalse);
  });

  test('permission ID rejects noncanonical text before contribution', () {
    expect(() => NexaBizPermissionId('Bad Permission'), throwsArgumentError);
  });

  test('route access remains descriptive metadata', () {
    const access = NexaBizRouteAccessRequirement(requiresActiveSession: true);
    const route = NexaBizRouteDefinition(
      routeId: NexaBizRouteId(namespace: 'one', routeName: 'root'),
      path: '/one',
      accessRequirement: access,
    );
    expect(route.accessRequirement, access);
    expect(route.path, '/one');
  });

  test('contribution contracts have no framework or UI imports', () {
    final files = Directory('lib/core/capabilities/contributions')
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('.dart'));
    expect(files, isNotEmpty);
    for (final file in files) {
      final source = file.readAsStringSync();
      expect(source, isNot(contains("package:flutter/")), reason: file.path);
      expect(source, isNot(contains("package:go_router/")), reason: file.path);
      expect(
        source,
        isNot(contains('package:flutter_riverpod/')),
        reason: file.path,
      );
      expect(source, isNot(contains('package:nexabiz_ui/')), reason: file.path);
    }
  });
}
