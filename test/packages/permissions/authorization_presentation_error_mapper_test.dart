import 'package:flutter_test/flutter_test.dart';
import 'package:nexabiz/core/authorization/administration/nexabiz_authorization_administration_errors.dart';
import 'package:nexabiz/core/authorization/nexabiz_membership_id.dart';
import 'package:nexabiz/core/authorization/nexabiz_permission_denied_exception.dart';
import 'package:nexabiz/core/company/nexabiz_company_scope.dart';
import 'package:nexabiz/core/permissions/nexabiz_permission_intent.dart';
import 'package:nexabiz/core/roles/nexabiz_role_id.dart';
import 'package:nexabiz/core/roles/nexabiz_role_scope.dart';
import 'package:nexabiz/l10n/app_localizations_ar.dart';
import 'package:nexabiz/l10n/app_localizations_en.dart';
import 'package:nexabiz/packages/permissions/presentation/metadata/nexabiz_authorization_presentation_error_mapper.dart';

void main() {
  final l10nEn = AppLocalizationsEn();
  final l10nAr = AppLocalizationsAr();
  const mapper = NexaBizAuthorizationPresentationErrorMapper();

  final testRoleId = NexaBizRoleId('company.custom_role');
  final testMembershipId = NexaBizMembershipId('test-membership-1');
  final testCompanyId = NexaBizCompanyId('company-1');
  final otherCompanyId = NexaBizCompanyId('company-2');
  final testPermissionId = NexaBizPermissionId('company.profile.view');

  group('Authorization presentation error mapper', () {
    test('maps NexaBizRoleNotFoundException', () {
      final error = NexaBizRoleNotFoundException(
        companyId: testCompanyId,
        roleId: testRoleId,
      );

      expect(
        mapper.mapError(error: error, l10n: l10nEn),
        equals(l10nEn.authAdminErrorRoleNotFound),
      );
      expect(
        mapper.mapError(error: error, l10n: l10nAr),
        equals(l10nAr.authAdminErrorRoleNotFound),
      );
    });

    test('maps NexaBizMembershipNotFoundException', () {
      final error = NexaBizMembershipNotFoundException(
        companyId: testCompanyId,
        membershipId: testMembershipId,
      );

      expect(
        mapper.mapError(error: error, l10n: l10nEn),
        equals(l10nEn.authAdminErrorMembershipNotFound),
      );
      expect(
        mapper.mapError(error: error, l10n: l10nAr),
        equals(l10nAr.authAdminErrorMembershipNotFound),
      );
    });

    test('maps NexaBizAuthorizationCrossCompanyException', () {
      final error = NexaBizAuthorizationCrossCompanyException(
        expectedCompanyId: testCompanyId,
        actualCompanyId: otherCompanyId,
      );

      expect(
        mapper.mapError(error: error, l10n: l10nEn),
        equals(l10nEn.authAdminErrorCrossCompany),
      );
      expect(
        mapper.mapError(error: error, l10n: l10nAr),
        equals(l10nAr.authAdminErrorCrossCompany),
      );
    });

    test('maps NexaBizBuiltInRoleProtectedException for all actions', () {
      final actions = [
        (
          NexaBizBuiltInRoleProtectedAction.create,
          l10nEn.authAdminErrorBuiltInCreate,
          l10nAr.authAdminErrorBuiltInCreate,
        ),
        (
          NexaBizBuiltInRoleProtectedAction.updateMetadata,
          l10nEn.authAdminErrorBuiltInUpdate,
          l10nAr.authAdminErrorBuiltInUpdate,
        ),
        (
          NexaBizBuiltInRoleProtectedAction.delete,
          l10nEn.authAdminErrorBuiltInDelete,
          l10nAr.authAdminErrorBuiltInDelete,
        ),
        (
          NexaBizBuiltInRoleProtectedAction.grantPermission,
          l10nEn.authAdminErrorBuiltInPermissions,
          l10nAr.authAdminErrorBuiltInPermissions,
        ),
        (
          NexaBizBuiltInRoleProtectedAction.revokePermission,
          l10nEn.authAdminErrorBuiltInPermissions,
          l10nAr.authAdminErrorBuiltInPermissions,
        ),
      ];

      for (final (action, expectedEn, expectedAr) in actions) {
        final error = NexaBizBuiltInRoleProtectedException(
          roleId: testRoleId,
          action: action,
        );

        expect(mapper.mapError(error: error, l10n: l10nEn), equals(expectedEn));
        expect(mapper.mapError(error: error, l10n: l10nAr), equals(expectedAr));
      }
    });

    test('maps NexaBizLastOwnerProtectedException with actionable message', () {
      final error = NexaBizLastOwnerProtectedException(testCompanyId);

      final msgEn = mapper.mapError(error: error, l10n: l10nEn);
      final msgAr = mapper.mapError(error: error, l10n: l10nAr);

      expect(msgEn, equals(l10nEn.authAdminErrorLastOwnerProtected));
      expect(msgAr, equals(l10nAr.authAdminErrorLastOwnerProtected));
      expect(msgEn, contains('Assign another active owner first'));
      expect(msgAr, contains('يجب تعيين مالك نشط آخر'));
    });

    test('maps NexaBizUndeclaredPermissionException', () {
      final error = NexaBizUndeclaredPermissionException(testPermissionId);

      expect(
        mapper.mapError(error: error, l10n: l10nEn),
        equals(l10nEn.authAdminErrorUndeclaredPermission),
      );
      expect(
        mapper.mapError(error: error, l10n: l10nAr),
        equals(l10nAr.authAdminErrorUndeclaredPermission),
      );
    });

    test(
      'maps NexaBizAuthorizationAdministrationConflictException for all conflict types',
      () {
        final conflicts = [
          (
            NexaBizAuthorizationAdministrationConflictType.duplicateRoleKey,
            l10nEn.authAdminErrorDuplicateRoleKey,
            l10nAr.authAdminErrorDuplicateRoleKey,
          ),
          (
            NexaBizAuthorizationAdministrationConflictType
                .duplicateRoleDisplayName,
            l10nEn.authAdminErrorDuplicateRoleDisplayName,
            l10nAr.authAdminErrorDuplicateRoleDisplayName,
          ),
          (
            NexaBizAuthorizationAdministrationConflictType
                .roleHasMembershipAssignments,
            l10nEn.authAdminErrorRoleHasAssignments,
            l10nAr.authAdminErrorRoleHasAssignments,
          ),
        ];

        for (final (conflictType, expectedEn, expectedAr) in conflicts) {
          final error = NexaBizAuthorizationAdministrationConflictException(
            type: conflictType,
            roleId: testRoleId,
          );

          expect(
            mapper.mapError(error: error, l10n: l10nEn),
            equals(expectedEn),
          );
          expect(
            mapper.mapError(error: error, l10n: l10nAr),
            equals(expectedAr),
          );
        }
      },
    );

    test(
      'maps NexaBizMembershipIneligibleException for all ineligibility reasons',
      () {
        final reasons = [
          (
            NexaBizMembershipIneligibilityReason.inactiveMembership,
            l10nEn.authAdminErrorMembershipInactive,
            l10nAr.authAdminErrorMembershipInactive,
          ),
          (
            NexaBizMembershipIneligibilityReason.inactiveUser,
            l10nEn.authAdminErrorUserInactive,
            l10nAr.authAdminErrorUserInactive,
          ),
        ];

        for (final (reason, expectedEn, expectedAr) in reasons) {
          final error = NexaBizMembershipIneligibleException(
            membershipId: testMembershipId,
            reason: reason,
          );

          expect(
            mapper.mapError(error: error, l10n: l10nEn),
            equals(expectedEn),
          );
          expect(
            mapper.mapError(error: error, l10n: l10nAr),
            equals(expectedAr),
          );
        }
      },
    );

    test('maps NexaBizCompanyIneligibleException', () {
      final error = NexaBizCompanyIneligibleException(testCompanyId);

      expect(
        mapper.mapError(error: error, l10n: l10nEn),
        equals(l10nEn.authAdminErrorCompanyInactive),
      );
      expect(
        mapper.mapError(error: error, l10n: l10nAr),
        equals(l10nAr.authAdminErrorCompanyInactive),
      );
    });

    test(
      'maps NexaBizInvalidRoleDisplayNameException for all validation reasons',
      () {
        const emptyError = NexaBizInvalidRoleDisplayNameException(
          NexaBizRoleDisplayNameValidationReason.empty,
        );

        const tooLongError = NexaBizInvalidRoleDisplayNameException(
          NexaBizRoleDisplayNameValidationReason.tooLong,
        );

        expect(
          mapper.mapError(error: emptyError, l10n: l10nEn),
          equals(l10nEn.authAdminErrorRoleNameEmpty),
        );
        expect(
          mapper.mapError(error: emptyError, l10n: l10nAr),
          equals(l10nAr.authAdminErrorRoleNameEmpty),
        );

        expect(
          mapper.mapError(error: tooLongError, l10n: l10nEn),
          equals(l10nEn.authAdminErrorRoleNameTooLong(100)),
        );
        expect(
          mapper.mapError(error: tooLongError, l10n: l10nAr),
          equals(l10nAr.authAdminErrorRoleNameTooLong(100)),
        );
      },
    );

    test('maps NexaBizPermissionDeniedException', () {
      final error = NexaBizPermissionDeniedException(
        permissionId: testPermissionId,
        contextScope: NexaBizRoleScope.company,
        decision: NexaBizPermissionDecision.deny,
      );

      expect(
        mapper.mapError(error: error, l10n: l10nEn),
        equals(l10nEn.authAdminErrorPermissionDenied),
      );
      expect(
        mapper.mapError(error: error, l10n: l10nAr),
        equals(l10nAr.authAdminErrorPermissionDenied),
      );
    });

    test('maps ArgumentError on role key validation', () {
      final errorValue = ArgumentError.value('Invalid Key!', 'value');
      final errorRoleId = ArgumentError.value('Invalid Key!', 'roleId');

      expect(
        mapper.mapError(error: errorValue, l10n: l10nEn),
        equals(l10nEn.authAdminErrorRoleKeyInvalid),
      );
      expect(
        mapper.mapError(error: errorValue, l10n: l10nAr),
        equals(l10nAr.authAdminErrorRoleKeyInvalid),
      );

      expect(
        mapper.mapError(error: errorRoleId, l10n: l10nEn),
        equals(l10nEn.authAdminErrorRoleKeyInvalid),
      );
      expect(
        mapper.mapError(error: errorRoleId, l10n: l10nAr),
        equals(l10nAr.authAdminErrorRoleKeyInvalid),
      );
    });

    test('maps unexpected or unhandled exceptions to generic error', () {
      final unhandled = StateError('Unknown unexpected error state');

      expect(
        mapper.mapError(error: unhandled, l10n: l10nEn),
        equals(l10nEn.authAdminErrorGeneric),
      );
      expect(
        mapper.mapError(error: unhandled, l10n: l10nAr),
        equals(l10nAr.authAdminErrorGeneric),
      );
    });
  });
}
