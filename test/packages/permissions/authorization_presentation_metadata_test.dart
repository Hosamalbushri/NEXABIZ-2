import 'package:flutter_test/flutter_test.dart';
import 'package:nexabiz/core/permissions/nexabiz_permission_intent.dart';
import 'package:nexabiz/l10n/app_localizations_ar.dart';
import 'package:nexabiz/l10n/app_localizations_en.dart';
import 'package:nexabiz/packages/company/company_capability.dart';
import 'package:nexabiz/packages/identity/identity_capability.dart';
import 'package:nexabiz/packages/permissions/permissions_capability.dart';
import 'package:nexabiz/packages/permissions/presentation/metadata/nexabiz_permission_presentation_models.dart';
import 'package:nexabiz/packages/permissions/presentation/metadata/nexabiz_permission_presentation_resolver.dart';

void main() {
  final l10nEn = AppLocalizationsEn();
  final l10nAr = AppLocalizationsAr();
  const resolver = NexaBizPermissionPresentationResolver();

  final companyPermissions =
      CompanyCapability().permissionContribution.declaredPermissionIds;
  final identityPermissions =
      IdentityCapability().permissionContribution.declaredPermissionIds;
  final authorizationPermissions =
      PermissionsCapability().permissionContribution.declaredPermissionIds;

  final allCanonicalPermissions = <NexaBizPermissionId>[
    ...companyPermissions,
    ...identityPermissions,
    ...authorizationPermissions,
  ];

  group('Authorization presentation metadata catalog coverage', () {
    test('canonical permissions count is exactly 10', () {
      expect(allCanonicalPermissions, hasLength(10));
      expect(companyPermissions, hasLength(3));
      expect(identityPermissions, hasLength(2));
      expect(authorizationPermissions, hasLength(5));
    });

    test(
      '100% of declared capability permissions have explicit presentation descriptors',
      () {
        final registeredIds = NexaBizPermissionPresentationResolver
            .registeredExplicitPermissionIds;

        for (final permissionId in allCanonicalPermissions) {
          expect(
            registeredIds.contains(permissionId.value),
            isTrue,
            reason:
                'Permission ${permissionId.value} must have explicit metadata registered',
          );

          final descriptor = resolver.describe(permissionId);
          expect(descriptor.isExplicit, isTrue);
          expect(
            descriptor.group,
            isNot(equals(NexaBizPermissionPresentationGroup.other)),
          );
        }
      },
    );

    test('no duplicate registered permission IDs in explicit catalog', () {
      final registeredIds =
          NexaBizPermissionPresentationResolver.registeredExplicitPermissionIds;
      expect(registeredIds.length, equals(10));
    });

    test('group assignments match architecture contract', () {
      for (final id in companyPermissions) {
        final descriptor = resolver.describe(id);
        expect(
          descriptor.group,
          equals(NexaBizPermissionPresentationGroup.company),
        );
      }

      for (final id in identityPermissions) {
        final descriptor = resolver.describe(id);
        expect(
          descriptor.group,
          equals(NexaBizPermissionPresentationGroup.identity),
        );
      }

      for (final id in authorizationPermissions) {
        final descriptor = resolver.describe(id);
        expect(
          descriptor.group,
          equals(NexaBizPermissionPresentationGroup.authorization),
        );
      }
    });

    test('within-group sort orders are strictly unique per group', () {
      final descriptorsByGroup =
          <NexaBizPermissionPresentationGroup, List<int>>{};

      for (final permissionId in allCanonicalPermissions) {
        final desc = resolver.describe(permissionId);
        descriptorsByGroup
            .putIfAbsent(desc.group, () => [])
            .add(desc.sortOrder);
      }

      for (final entry in descriptorsByGroup.entries) {
        final orders = entry.value;
        final uniqueOrders = orders.toSet();
        expect(
          uniqueOrders.length,
          equals(orders.length),
          reason:
              'Group ${entry.key} contains duplicate sortOrder entries: $orders',
        );
      }
    });
  });

  group('Presentation metadata localization', () {
    test(
      'all 10 canonical permissions resolve non-empty, human-readable titles and descriptions in English and Arabic',
      () {
        for (final permissionId in allCanonicalPermissions) {
          final resolvedEn = resolver.resolve(
            permissionId: permissionId,
            l10n: l10nEn,
          );
          final resolvedAr = resolver.resolve(
            permissionId: permissionId,
            l10n: l10nAr,
          );

          // Titles must not be empty and must NOT be the raw permission ID
          expect(resolvedEn.title.trim(), isNotEmpty);
          expect(resolvedEn.title, isNot(equals(permissionId.value)));
          expect(resolvedAr.title.trim(), isNotEmpty);
          expect(resolvedAr.title, isNot(equals(permissionId.value)));

          // Descriptions must not be empty
          expect(resolvedEn.description.trim(), isNotEmpty);
          expect(resolvedAr.description.trim(), isNotEmpty);

          // Group titles must be valid
          expect(resolvedEn.groupTitle.trim(), isNotEmpty);
          expect(resolvedAr.groupTitle.trim(), isNotEmpty);
        }
      },
    );

    test(
      'presentation groups have non-empty, localized titles in English and Arabic',
      () {
        for (final group in NexaBizPermissionPresentationGroup.values) {
          final titleEn = group.resolveTitle(l10nEn);
          final titleAr = group.resolveTitle(l10nAr);

          expect(titleEn.trim(), isNotEmpty);
          expect(titleAr.trim(), isNotEmpty);
        }
      },
    );

    test(
      'pluralization messages for permission and member counts format properly',
      () {
        expect(l10nEn.authAdminPermissionCount(0), equals('No permissions'));
        expect(l10nEn.authAdminPermissionCount(1), equals('1 permission'));
        expect(l10nEn.authAdminPermissionCount(5), equals('5 permissions'));

        expect(l10nEn.authAdminMemberCount(0), equals('No members'));
        expect(l10nEn.authAdminMemberCount(1), equals('1 member'));
        expect(l10nEn.authAdminMemberCount(12), equals('12 members'));

        expect(l10nAr.authAdminPermissionCount(0), isNotEmpty);
        expect(l10nAr.authAdminPermissionCount(1), isNotEmpty);
        expect(l10nAr.authAdminPermissionCount(2), isNotEmpty);
        expect(l10nAr.authAdminPermissionCount(5), isNotEmpty);

        expect(l10nAr.authAdminMemberCount(0), isNotEmpty);
        expect(l10nAr.authAdminMemberCount(1), isNotEmpty);
        expect(l10nAr.authAdminMemberCount(2), isNotEmpty);
        expect(l10nAr.authAdminMemberCount(12), isNotEmpty);
      },
    );
  });

  group('Fail-safe unknown permission fallback', () {
    test(
      'unknown permission produces safe fallback descriptor in other group without throwing',
      () {
        final syntheticId = NexaBizPermissionId('finance.invoice.approve');
        final descriptor = resolver.describe(syntheticId);

        expect(descriptor.permissionId, equals(syntheticId));
        expect(
          descriptor.group,
          equals(NexaBizPermissionPresentationGroup.other),
        );
        expect(descriptor.sortOrder, equals(999));
        expect(descriptor.isExplicit, isFalse);

        final resolvedEn = resolver.resolve(
          permissionId: syntheticId,
          l10n: l10nEn,
        );
        final resolvedAr = resolver.resolve(
          permissionId: syntheticId,
          l10n: l10nAr,
        );

        // Raw ID is displayed as fallback title
        expect(resolvedEn.title, equals('finance.invoice.approve'));
        expect(resolvedAr.title, equals('finance.invoice.approve'));

        // Descriptions clearly indicate unmapped status
        expect(resolvedEn.description, contains('finance.invoice.approve'));
        expect(resolvedAr.description, contains('finance.invoice.approve'));
        expect(resolvedEn.groupTitle, equals('Other Permissions'));
        expect(resolvedAr.groupTitle, equals('صلاحيات أخرى'));
      },
    );
  });

  group('Deterministic sorting', () {
    test(
      'resolveCatalog sorts deterministically by group order, sort order, and canonical id',
      () {
        final unsortedIds = [
          NexaBizPermissionId(
            'permissions.assignment.manage',
          ), // authorization, sort 4
          NexaBizPermissionId('unknown.alpha.view'), // other, sort 999
          NexaBizPermissionId('company.membership.view'), // company, sort 2
          NexaBizPermissionId(
            'permissions.catalog.view',
          ), // authorization, sort 0
          NexaBizPermissionId('identity.user.manage'), // identity, sort 1
          NexaBizPermissionId('company.profile.view'), // company, sort 0
          NexaBizPermissionId('unknown.beta.manage'), // other, sort 999
          NexaBizPermissionId('identity.session.view'), // identity, sort 0
        ];

        final resolved = resolver.resolveCatalog(
          permissionIds: unsortedIds,
          l10n: l10nEn,
        );

        final sortedIds = resolved.map((r) => r.permissionId.value).toList();

        expect(
          sortedIds,
          equals([
            // Group 0: Company
            'company.profile.view', // sort 0
            'company.membership.view', // sort 2
            // Group 1: Identity
            'identity.session.view', // sort 0
            'identity.user.manage', // sort 1
            // Group 2: Authorization
            'permissions.catalog.view', // sort 0
            'permissions.assignment.manage', // sort 4
            // Group 3: Other (tie-breaker by canonical id)
            'unknown.alpha.view',
            'unknown.beta.manage',
          ]),
        );
      },
    );
  });
}
