import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexabiz/app/authorization/nexabiz_authorization_invalidation_signal.dart';
import 'package:nexabiz/app/authorization/use_cases/create_company_role_use_case.dart';
import 'package:nexabiz/core/authorization/administration/nexabiz_authorization_administration_models.dart';
import 'package:nexabiz/core/authorization/administration/nexabiz_authorization_administration_store.dart';
import 'package:nexabiz/core/authorization/nexabiz_authorization_context.dart';
import 'package:nexabiz/core/authorization/nexabiz_membership_id.dart';
import 'package:nexabiz/core/authorization/nexabiz_permission_guard.dart';
import 'package:nexabiz/core/company/nexabiz_company_scope.dart';
import 'package:nexabiz/core/permissions/nexabiz_permission_intent.dart';
import 'package:nexabiz/core/roles/nexabiz_role_id.dart';
import 'package:nexabiz/core/session/nexabiz_session.dart';

final class _AlwaysAllowPermissionGuard implements NexaBizPermissionGuard {
  @override
  Future<void> requirePermission({
    required NexaBizAuthorizationContext context,
    required NexaBizPermissionId permissionId,
  }) async {}
}

final class _MockMutationStore
    implements NexaBizAuthorizationAdministrationMutationStore {
  bool committed = false;

  @override
  Future<
    NexaBizAuthorizationAdministrationMutationResult<NexaBizCompanyRoleDetails>
  >
  createCompanyRole({
    required NexaBizCompanyId companyId,
    required NexaBizRoleId roleId,
    required NexaBizRoleMetadata metadata,
  }) async {
    committed = true;
    return NexaBizAuthorizationAdministrationMutationResult(
      outcome: NexaBizAuthorizationAdministrationMutationOutcome.changed,
      before: null,
      after: NexaBizCompanyRoleDetails(
        companyId: companyId,
        roleId: roleId,
        metadata: metadata,
        kind: NexaBizCompanyRoleKind.custom,
        membershipAssignmentCount: 0,
        permissionAssignmentCount: 0,
        createdAt: DateTime.utc(2026, 1, 1),
        updatedAt: DateTime.utc(2026, 1, 1),
      ),
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('NexaBizAuthorizationInvalidationSignal exception isolation invariants', () {
    late NexaBizAuthorizationInvalidationSignal signal;
    late FlutterExceptionHandler? originalOnError;
    late List<FlutterErrorDetails> reportedErrors;

    setUp(() {
      signal = NexaBizAuthorizationInvalidationSignal();
      reportedErrors = [];
      originalOnError = FlutterError.onError;
      FlutterError.onError = (details) {
        reportedErrors.add(details);
      };
    });

    tearDown(() {
      FlutterError.onError = originalOnError;
      signal.dispose();
    });

    test(
      'Signal isolates throwing listener: does not throw to caller and reports to FlutterError',
      () {
        var listener1Executed = false;
        var listener2Executed = false;

        signal.addListener(() {
          listener1Executed = true;
          throw StateError('Simulated listener crash in UI router');
        });

        signal.addListener(() {
          listener2Executed = true;
        });

        // Invoking notifyAuthorizationChanged must not bubble the listener StateError
        expect(() => signal.notifyAuthorizationChanged(), returnsNormally);

        // Both listeners ran (isolation protects subsequent listeners)
        expect(listener1Executed, isTrue);
        expect(listener2Executed, isTrue);

        // Error was reported to FlutterError
        expect(reportedErrors, hasLength(1));
        expect(
          reportedErrors.single.exception,
          isA<StateError>().having(
            (e) => e.message,
            'message',
            contains('Simulated listener crash in UI router'),
          ),
        );
      },
    );

    test(
      'Committed mutation remains successful when invalidation listener throws',
      () async {
        final store = _MockMutationStore();
        final guard = _AlwaysAllowPermissionGuard();
        final useCase = CreateCompanyRoleUseCase(
          permissionGuard: guard,
          mutationStore: store,
          invalidationSignal: signal,
        );

        // Register failing listener (e.g. router rebuild crash or disposed widget)
        signal.addListener(() {
          throw Exception(
            'Router listener crash on authorization invalidation',
          );
        });

        final context = NexaBizCompanyAuthorizationContext(
          companyId: NexaBizCompanyId('company-alpha'),
          membershipId: NexaBizMembershipId('mem-1'),
          userId: NexaBizUserId('usr-1'),
        );

        final result = await useCase.execute(
          context: context,
          roleId: NexaBizRoleId('company.auditor'),
          metadata: NexaBizRoleMetadata(
            displayName: NexaBizRoleDisplayName('Auditor'),
          ),
        );

        // Invariant 1: Committed transaction state is intact
        expect(store.committed, isTrue);

        // Invariant 2: Result returned normally to caller without throwing
        expect(
          result.outcome,
          NexaBizAuthorizationAdministrationMutationOutcome.changed,
        );
        expect(result.after?.roleId, NexaBizRoleId('company.auditor'));

        // Invariant 3: Error was isolated and reported through standard Flutter diagnostic pipeline
        expect(reportedErrors, hasLength(1));
        expect(
          reportedErrors.single.exception.toString(),
          contains('Router listener crash on authorization invalidation'),
        );
      },
    );
  });
}
