import '../../company/nexabiz_company_scope.dart';
import '../../permissions/nexabiz_permission_intent.dart';
import '../../roles/nexabiz_role_id.dart';
import '../../session/nexabiz_session.dart';
import '../nexabiz_membership_id.dart';
import 'nexabiz_authorization_administration_errors.dart';

/// Validated, user-visible role name. It is metadata, never role identity.
final class NexaBizRoleDisplayName {
  static const int maxLength = 100;

  factory NexaBizRoleDisplayName(String value) {
    final normalized = value.trim();
    if (normalized.isEmpty) {
      throw const NexaBizInvalidRoleDisplayNameException(
        NexaBizRoleDisplayNameValidationReason.empty,
      );
    }
    if (normalized.runes.length > maxLength) {
      throw const NexaBizInvalidRoleDisplayNameException(
        NexaBizRoleDisplayNameValidationReason.tooLong,
      );
    }
    return NexaBizRoleDisplayName._(normalized);
  }

  const NexaBizRoleDisplayName._(this.value);

  final String value;

  /// Company-local duplicate detection is case-insensitive after trimming.
  String get comparisonKey => value.toLowerCase();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NexaBizRoleDisplayName && value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value;
}

/// Editable presentation metadata, independent from the stable role identity.
final class NexaBizRoleMetadata {
  factory NexaBizRoleMetadata({
    required NexaBizRoleDisplayName displayName,
    String? description,
  }) {
    final normalizedDescription = description?.trim();
    return NexaBizRoleMetadata._(
      displayName: displayName,
      description:
          normalizedDescription == null || normalizedDescription.isEmpty
          ? null
          : normalizedDescription,
    );
  }

  const NexaBizRoleMetadata._({
    required this.displayName,
    required this.description,
  });

  final NexaBizRoleDisplayName displayName;
  final String? description;
}

enum NexaBizCompanyRoleKind { builtIn, custom }

/// Lightweight projection for company role listings.
final class NexaBizCompanyRoleSummary {
  const NexaBizCompanyRoleSummary({
    required this.companyId,
    required this.roleId,
    required this.metadata,
    required this.kind,
    required this.membershipAssignmentCount,
  });

  final NexaBizCompanyId companyId;
  final NexaBizRoleId roleId;
  final NexaBizRoleMetadata metadata;
  final NexaBizCompanyRoleKind kind;
  final int membershipAssignmentCount;

  bool get isBuiltIn => kind == NexaBizCompanyRoleKind.builtIn;
}

/// Complete company-role projection without exposing persistence rows.
final class NexaBizCompanyRoleDetails {
  const NexaBizCompanyRoleDetails({
    required this.companyId,
    required this.roleId,
    required this.metadata,
    required this.kind,
    required this.membershipAssignmentCount,
    required this.permissionAssignmentCount,
    required this.createdAt,
    required this.updatedAt,
  });

  final NexaBizCompanyId companyId;
  final NexaBizRoleId roleId;
  final NexaBizRoleMetadata metadata;
  final NexaBizCompanyRoleKind kind;
  final int membershipAssignmentCount;
  final int permissionAssignmentCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isBuiltIn => kind == NexaBizCompanyRoleKind.builtIn;
}

final class NexaBizRolePermissionAssignment {
  const NexaBizRolePermissionAssignment({
    required this.companyId,
    required this.roleId,
    required this.permissionId,
    required this.assignedAt,
  });

  final NexaBizCompanyId companyId;
  final NexaBizRoleId roleId;
  final NexaBizPermissionId permissionId;
  final DateTime assignedAt;
}

/// Company-bound assignment projection used for both membership and role views.
final class NexaBizMembershipRoleAssignment {
  const NexaBizMembershipRoleAssignment({
    required this.companyId,
    required this.membershipId,
    required this.userId,
    required this.roleId,
    this.userName,
    this.userEmail,
    required this.membershipIsActive,
    required this.userIsActive,
    required this.assignedAt,
  });

  final NexaBizCompanyId companyId;
  final NexaBizMembershipId membershipId;
  final NexaBizUserId userId;
  final NexaBizRoleId roleId;
  final String? userName;
  final String? userEmail;
  final bool membershipIsActive;
  final bool userIsActive;
  final DateTime assignedAt;

  bool get isEligible => membershipIsActive && userIsActive;
}

/// Lightweight candidate projection for assigning active company members to roles.
final class NexaBizAssignableMembership {
  const NexaBizAssignableMembership({
    required this.companyId,
    required this.membershipId,
    required this.userId,
    this.userName,
    this.userEmail,
    required this.membershipIsActive,
    required this.userIsActive,
    this.joinedAt,
  });

  final NexaBizCompanyId companyId;
  final NexaBizMembershipId membershipId;
  final NexaBizUserId userId;
  final String? userName;
  final String? userEmail;
  final bool membershipIsActive;
  final bool userIsActive;
  final DateTime? joinedAt;

  bool get isEligible => membershipIsActive && userIsActive;
}

/// Administrative inspection projection. This is an immutable query result,
/// not a session field or an effective-permission cache.
final class NexaBizMembershipEffectivePermissionInfo {
  NexaBizMembershipEffectivePermissionInfo({
    required this.companyId,
    required this.membershipId,
    required this.userId,
    required Set<NexaBizRoleId> roleIds,
    required Set<NexaBizPermissionId> permissionIds,
    required this.isEligible,
  }) : roleIds = Set.unmodifiable(roleIds),
       permissionIds = Set.unmodifiable(permissionIds);

  final NexaBizCompanyId companyId;
  final NexaBizMembershipId membershipId;
  final NexaBizUserId userId;
  final Set<NexaBizRoleId> roleIds;
  final Set<NexaBizPermissionId> permissionIds;
  final bool isEligible;
}

/// Cursor page request. Stores may cap [limit] further but must preserve order.
final class NexaBizAuthorizationAdministrationPageRequest {
  factory NexaBizAuthorizationAdministrationPageRequest({
    String? cursor,
    int limit = 50,
  }) {
    if (limit < 1 || limit > 100) {
      throw ArgumentError.value(limit, 'limit', 'Must be between 1 and 100.');
    }
    if (cursor != null && (cursor.isEmpty || cursor.trim() != cursor)) {
      throw ArgumentError.value(
        cursor,
        'cursor',
        'Cursor must be non-empty and unpadded.',
      );
    }
    return NexaBizAuthorizationAdministrationPageRequest._(
      cursor: cursor,
      limit: limit,
    );
  }

  const NexaBizAuthorizationAdministrationPageRequest._({
    required this.cursor,
    required this.limit,
  });

  final String? cursor;
  final int limit;
}

final class NexaBizAuthorizationAdministrationPage<T> {
  NexaBizAuthorizationAdministrationPage({
    required List<T> items,
    required this.nextCursor,
  }) : items = List.unmodifiable(items);

  final List<T> items;
  final String? nextCursor;

  bool get hasMore => nextCursor != null;
}

final class NexaBizCompanyRoleFilter {
  factory NexaBizCompanyRoleFilter({
    String? search,
    NexaBizCompanyRoleKind? kind,
  }) {
    final normalizedSearch = search?.trim();
    return NexaBizCompanyRoleFilter._(
      search: normalizedSearch == null || normalizedSearch.isEmpty
          ? null
          : normalizedSearch,
      kind: kind,
    );
  }

  const NexaBizCompanyRoleFilter._({required this.search, required this.kind});

  final String? search;
  final NexaBizCompanyRoleKind? kind;
}

enum NexaBizAuthorizationAdministrationMutationOutcome { changed, unchanged }

/// Commit result that can later be combined with actor context for audit events.
final class NexaBizAuthorizationAdministrationMutationResult<T> {
  const NexaBizAuthorizationAdministrationMutationResult({
    required this.outcome,
    required this.before,
    required this.after,
  });

  final NexaBizAuthorizationAdministrationMutationOutcome outcome;
  final T? before;
  final T? after;

  bool get changed =>
      outcome == NexaBizAuthorizationAdministrationMutationOutcome.changed;
}
