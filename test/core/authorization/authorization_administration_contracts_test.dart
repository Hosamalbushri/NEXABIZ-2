import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:nexabiz/core/authorization/administration/nexabiz_authorization_administration_errors.dart';
import 'package:nexabiz/core/authorization/administration/nexabiz_authorization_administration_models.dart';
import 'package:nexabiz/core/authorization/administration/nexabiz_authorization_administration_permissions.dart';
import 'package:nexabiz/core/authorization/administration/nexabiz_authorization_administration_policy.dart';
import 'package:nexabiz/core/authorization/nexabiz_membership_id.dart';
import 'package:nexabiz/core/authorization/nexabiz_permission_catalog.dart';
import 'package:nexabiz/core/company/nexabiz_company_scope.dart';
import 'package:nexabiz/core/permissions/nexabiz_permission_intent.dart';
import 'package:nexabiz/core/roles/nexabiz_role_id.dart';
import 'package:nexabiz/core/roles/nexabiz_role_scope.dart';

void main() {
  const rolePolicy = NexaBizCompanyRoleAdministrationPolicy();
  final companyA = NexaBizCompanyId('company-a');
  final companyB = NexaBizCompanyId('company-b');
  final customRoleId = NexaBizRoleId('company.sales_manager');

  group('Authorization administration domain contracts', () {
    test('1. custom role identity remains stable across metadata changes', () {
      final initial = NexaBizRoleMetadata(
        displayName: NexaBizRoleDisplayName('Sales Manager'),
      );
      final renamed = NexaBizRoleMetadata(
        displayName: NexaBizRoleDisplayName('Regional Sales Manager'),
      );

      expect(customRoleId.value, 'company.sales_manager');
      expect(initial.displayName, isNot(renamed.displayName));
      expect(customRoleId, NexaBizRoleId('company.sales_manager'));
    });

    test(
      '2. display name trims text, supports Unicode, and has a stable key',
      () {
        final name = NexaBizRoleDisplayName('  مدير المبيعات  ');

        expect(name.value, 'مدير المبيعات');
        expect(name.comparisonKey, 'مدير المبيعات');
        expect(
          NexaBizRoleDisplayName('Sales').comparisonKey,
          NexaBizRoleDisplayName('SALES').comparisonKey,
        );
      },
    );

    test(
      '3. empty and oversized display names are rejected with typed errors',
      () {
        expect(
          () => NexaBizRoleDisplayName('   '),
          throwsA(
            isA<NexaBizInvalidRoleDisplayNameException>().having(
              (error) => error.reason,
              'reason',
              NexaBizRoleDisplayNameValidationReason.empty,
            ),
          ),
        );
        expect(
          () => NexaBizRoleDisplayName('x' * 101),
          throwsA(
            isA<NexaBizInvalidRoleDisplayNameException>().having(
              (error) => error.reason,
              'reason',
              NexaBizRoleDisplayNameValidationReason.tooLong,
            ),
          ),
        );
      },
    );

    test('4. role keys use the existing canonical value object', () {
      expect(
        NexaBizRoleId.scoped(NexaBizRoleScope.company, 'inventory_manager'),
        NexaBizRoleId('company.inventory_manager'),
      );
      expect(() => NexaBizRoleId('Company.Owner'), throwsArgumentError);
      expect(() => NexaBizRoleId('company owner'), throwsArgumentError);
    });

    test('5. built-in owner is recognized from centralized policy', () {
      expect(
        rolePolicy.classifyRole(
          roleId: NexaBizBuiltInCompanyRoles.companyOwner,
          persistedIsBuiltIn: false,
        ),
        NexaBizCompanyRoleKind.builtIn,
      );
      expect(
        () => rolePolicy.ensureMetadataMutable(
          roleId: NexaBizBuiltInCompanyRoles.companyOwner,
          persistedIsBuiltIn: false,
        ),
        throwsA(isA<NexaBizBuiltInRoleProtectedException>()),
      );
      expect(
        () => rolePolicy.ensurePermissionGrantable(
          roleId: NexaBizBuiltInCompanyRoles.companyOwner,
          persistedIsBuiltIn: false,
        ),
        throwsA(
          isA<NexaBizBuiltInRoleProtectedException>().having(
            (error) => error.action,
            'action',
            NexaBizBuiltInRoleProtectedAction.grantPermission,
          ),
        ),
      );
    });

    test('6. non-built-in company role is recognized as custom', () {
      expect(
        rolePolicy.classifyRole(
          roleId: customRoleId,
          persistedIsBuiltIn: false,
        ),
        NexaBizCompanyRoleKind.custom,
      );
      expect(
        () => rolePolicy.ensureCreatableCustomRole(customRoleId),
        returnsNormally,
      );
    });

    test('7. unknown permission is rejected against catalog authority', () {
      final catalog = NexaBizImmutablePermissionCatalog({
        NexaBizAuthorizationAdministrationPermissions.policyReview,
      });
      final permissionPolicy =
          NexaBizAuthorizationAdministrationPermissionPolicy(catalog);
      final unknown = NexaBizPermissionId('permissions.unknown.manage');

      expect(
        () => permissionPolicy.ensureDeclared(unknown),
        throwsA(
          isA<NexaBizUndeclaredPermissionException>().having(
            (error) => error.permissionId,
            'permissionId',
            unknown,
          ),
        ),
      );
    });

    test('8. every projection carries explicit company scope', () {
      final summary = NexaBizCompanyRoleSummary(
        companyId: companyA,
        roleId: customRoleId,
        metadata: NexaBizRoleMetadata(
          displayName: NexaBizRoleDisplayName('Sales'),
        ),
        kind: NexaBizCompanyRoleKind.custom,
        membershipAssignmentCount: 0,
      );

      expect(summary.companyId, companyA);
      expect(summary.roleId, customRoleId);
    });

    test('9. cross-company mismatch is a stable typed failure', () {
      expect(
        () => rolePolicy.ensureSameCompany(
          expectedCompanyId: companyA,
          actualCompanyId: companyB,
        ),
        throwsA(
          isA<NexaBizAuthorizationCrossCompanyException>()
              .having(
                (error) => error.code,
                'code',
                NexaBizAuthorizationAdministrationErrorCode
                    .crossCompanyMismatch,
              )
              .having(
                (error) => error.expectedCompanyId,
                'expectedCompanyId',
                companyA,
              ),
        ),
      );
    });

    test('10. removing the last active owner is modeled explicitly', () {
      expect(
        () => rolePolicy.ensureOwnerUnassignmentLeavesActiveOwner(
          companyId: companyA,
          roleId: NexaBizBuiltInCompanyRoles.companyOwner,
          activeOwnerCountAfter: 0,
        ),
        throwsA(
          isA<NexaBizLastOwnerProtectedException>().having(
            (error) => error.code,
            'code',
            NexaBizAuthorizationAdministrationErrorCode.lastOwnerProtected,
          ),
        ),
      );
      expect(
        () => rolePolicy.ensureOwnerUnassignmentLeavesActiveOwner(
          companyId: companyA,
          roleId: NexaBizBuiltInCompanyRoles.companyOwner,
          activeOwnerCountAfter: 1,
        ),
        returnsNormally,
      );
    });

    test('11. typed error codes remain independent from message parsing', () {
      final error = NexaBizRoleNotFoundException(
        companyId: companyA,
        roleId: customRoleId,
      );

      expect(
        error.code,
        NexaBizAuthorizationAdministrationErrorCode.roleNotFound,
      );
      expect(error.companyId, companyA);
      expect(error.roleId, customRoleId);
    });

    test('12. administration contracts do not use the legacy role column', () {
      final sources = Directory('lib/core/authorization/administration')
          .listSync(recursive: true)
          .whereType<File>()
          .where((file) => file.path.endsWith('.dart'))
          .map((file) => file.readAsStringSync())
          .join('\n');

      expect(sources, isNot(contains('core_company_memberships.role')));
      expect(sources, isNot(contains('membership.role')));
    });

    test('13. session remains free of permission state', () {
      final source = File(
        'lib/core/session/nexabiz_session.dart',
      ).readAsStringSync();

      expect(source, isNot(contains('Set<NexaBizPermissionId>')));
      expect(source, isNot(contains('effectivePermissions')));
      expect(source, isNot(contains('permissionCache')));
    });

    test('14. system role administration remains outside contract scope', () {
      expect(
        () => rolePolicy.ensureCompanyRoleId(NexaBizRoleId('system.admin')),
        throwsArgumentError,
      );
    });

    test('15. read and write operations use least-privilege permissions', () {
      expect(
        NexaBizAuthorizationAdministrationOperation
            .listPermissionCatalog
            .requiredPermission,
        NexaBizAuthorizationAdministrationPermissions.catalogView,
      );
      expect(
        NexaBizAuthorizationAdministrationOperation
            .listRoles
            .requiredPermission,
        NexaBizAuthorizationAdministrationPermissions.policyReview,
      );
      expect(
        NexaBizAuthorizationAdministrationOperation
            .createRole
            .requiredPermission,
        NexaBizAuthorizationAdministrationPermissions.roleManage,
      );
      expect(
        NexaBizAuthorizationAdministrationOperation
            .grantRolePermission
            .requiredPermission,
        NexaBizAuthorizationAdministrationPermissions.policyManage,
      );
      expect(
        NexaBizAuthorizationAdministrationOperation
            .assignMembershipRole
            .requiredPermission,
        NexaBizAuthorizationAdministrationPermissions.assignmentManage,
      );
    });

    test('16. inactive assignment targets are rejected before mutation', () {
      final membershipId = NexaBizMembershipId('membership-a');

      expect(
        () => rolePolicy.ensureAssignmentEligibility(
          companyId: companyA,
          membershipId: membershipId,
          companyIsActive: true,
          membershipIsActive: false,
          userIsActive: true,
        ),
        throwsA(
          isA<NexaBizMembershipIneligibleException>().having(
            (error) => error.reason,
            'reason',
            NexaBizMembershipIneligibilityReason.inactiveMembership,
          ),
        ),
      );
    });

    test('17. bounded cursor paging does not assume whole-database reads', () {
      final page = NexaBizAuthorizationAdministrationPageRequest(
        cursor: 'next-1',
        limit: 25,
      );

      expect(page.cursor, 'next-1');
      expect(page.limit, 25);
      expect(
        () => NexaBizAuthorizationAdministrationPageRequest(limit: 101),
        throwsArgumentError,
      );
    });
  });
}
