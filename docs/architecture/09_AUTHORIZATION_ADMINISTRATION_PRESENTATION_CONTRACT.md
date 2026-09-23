# 09 — AUTHORIZATION ADMINISTRATION PRESENTATION CONTRACT

## 1. Scope & Layer Boundaries

This contract governs the Presentation layer architecture, localization foundations, and UX semantics for Authorization Administration within NexaBiz.

```text
       Security & Intent Authority: Capability Registry & NexaBizPermissionId
                                      ↓
      Application Execution Layer: NexaBizAuthorizationAdministration Facade
                                      ↓
  Presentation Support Layer: NexaBizPermissionPresentationResolver & ErrorMapper
                                      ↓
        UI Presentation Components: Canonical AppPage, List, and Detail Scaffolds
```

### Mandatory Invariants:

1. **Metadata is Presentation-Only**: Presentation descriptors and resolvers hold ZERO security authority. `NexaBizPermissionId` remains the sole technical security identity, and `NexaBizCapabilityRegistry` remains the sole declaration authority.
2. **Zero Localization in Core Domain**: Core domain models, application use cases, and persistence stores MUST NEVER import `AppLocalizations` or Flutter UI libraries.
3. **No Direct Persistence Access**: Presentation layers MUST NEVER import `NexaBizAuthorizationAdministrationMutationStore`, `NexaBizAuthorizationAdministrationQueryStore`, or Drift database implementations. Presentation code interacts strictly with `NexaBizAuthorizationAdministration` use cases.
4. **Zero Hardcoded Strings**: All user-visible titles, descriptions, helper texts, placeholders, errors, confirmations, and counts MUST be resolved through strongly-typed `AppLocalizations`.

---

## 2. Permission Presentation & Grouping Model

### 2.1 Group Identity

Presentation grouping is strongly-typed via `NexaBizPermissionPresentationGroup`:

| Group Enum      | Canonical Purpose                                               | Default Sort Order | Localized Title Key           |
| :-------------- | :-------------------------------------------------------------- | :----------------- | :---------------------------- |
| `company`       | Company profile, workspace, and membership visibility           | `0`                | `authAdminGroupCompany`       |
| `identity`      | Local authentication, sessions, and credential safety           | `1`                | `authAdminGroupIdentity`      |
| `authorization` | Access control, custom roles, policies, and role assignment     | `2`                | `authAdminGroupAuthorization` |
| `other`         | Fail-safe fallback for unmapped or future capability extensions | `3`                | `authAdminGroupOther`         |

Widgets MUST NOT group permissions using string splitting (e.g. `id.split('.')`).

### 2.2 Canonical Permission Catalog Mapping

The 10 canonical permissions declared by NexaBiz capabilities are mapped as follows:

| Permission ID                   | Owner Capability | Group           | Sort Order | Title Key                                 | Description Key                          |
| :------------------------------ | :--------------- | :-------------- | :--------- | :---------------------------------------- | :--------------------------------------- |
| `company.profile.view`          | `company`        | `company`       | `0`        | `authAdminPermCompanyProfileViewTitle`    | `authAdminPermCompanyProfileViewDesc`    |
| `company.profile.manage`        | `company`        | `company`       | `1`        | `authAdminPermCompanyProfileManageTitle`  | `authAdminPermCompanyProfileManageDesc`  |
| `company.membership.view`       | `company`        | `company`       | `2`        | `authAdminPermCompanyMembershipViewTitle` | `authAdminPermCompanyMembershipViewDesc` |
| `identity.session.view`         | `identity`       | `identity`      | `0`        | `authAdminPermIdentitySessionViewTitle`   | `authAdminPermIdentitySessionViewDesc`   |
| `identity.user.manage`          | `identity`       | `identity`      | `1`        | `authAdminPermIdentityUserManageTitle`    | `authAdminPermIdentityUserManageDesc`    |
| `permissions.catalog.view`      | `permissions`    | `authorization` | `0`        | `authAdminPermCatalogViewTitle`           | `authAdminPermCatalogViewDesc`           |
| `permissions.policy.review`     | `permissions`    | `authorization` | `1`        | `authAdminPermPolicyReviewTitle`          | `authAdminPermPolicyReviewDesc`          |
| `permissions.role.manage`       | `permissions`    | `authorization` | `2`        | `authAdminPermRoleManageTitle`            | `authAdminPermRoleManageDesc`            |
| `permissions.policy.manage`     | `permissions`    | `authorization` | `3`        | `authAdminPermPolicyManageTitle`          | `authAdminPermPolicyManageDesc`          |
| `permissions.assignment.manage` | `permissions`    | `authorization` | `4`        | `authAdminPermAssignmentManageTitle`      | `authAdminPermAssignmentManageDesc`      |

### 2.3 Deterministic Presentation Ordering

`NexaBizPermissionPresentationResolver.resolveCatalog` deterministically sorts permissions by:

1. `group.order` ascending.
2. `descriptor.sortOrder` ascending.
3. `permissionId.value` alphabetical tie-breaker.

No UI component may rely on `Set` iteration, accidental registration order, or localized translation alphabetization for ordering.

### 2.4 Fail-Safe Unknown Fallback

When a capability declares a permission that has not yet been registered in presentation metadata:

- The system MUST NOT throw or crash.
- The permission is assigned to `NexaBizPermissionPresentationGroup.other` with `sortOrder: 999` and `isExplicit: false`.
- The canonical identifier (`permissionId.value`) is displayed as primary title so that administrators can still identify and manage the capability.
- The description uses `authAdminUnknownPermissionDesc(permissionId)`.

---

## 3. Role Key & Creation UX Contract

### 3.1 Role Identifier Contract (Forensic Finding from Step 02)

- **No Automatic Generation**: The system does NOT synthesize role identifiers from display names (no `toSlug` or synthetic hashing). Display names are localizable metadata; role keys are immutable relational identities.
- **Explicit User Entry on Creation**: On the Create Role screen, the role identifier is an explicit user input field.
- **Format Validation**: Must match `^[a-z][a-z0-9_]*\.[a-z][a-z0-9_]*$` with the mandatory prefix `company.` (e.g., `company.accountant`).
- **Post-Creation Immutability**: Once created, the role identifier is strictly immutable. In Edit Role screens, the identifier is displayed as read-only informative text, never an editable input.

---

## 4. Mutation Semantics: Commit-Confirmed UX

All authorization administration mutations (creating roles, modifying metadata, deleting roles, granting/revoking permissions, and assigning/unassigning members) MUST adhere to **Commit-Confirmed UX**:

1. **Current Committed State Maintained**: The UI displays exclusively committed data returned from application queries.
2. **Pending Indication**: When the user triggers an action (e.g. toggling a permission switch or submitting a form), the associated control or dialog is marked `pending` (e.g., loading spinner or disabled state).
3. **Optimistic Updates Strictly Prohibited**: The UI MUST NOT assume success. Permission switches or role lists must not prematurely update prior to transaction commit.
4. **Application of Result**: Upon successful return of `NexaBizAuthorizationAdministrationMutationResult`, the returned `after` projection is applied to the local view state, and pending state is cleared.
5. **Rollback on Error**: If the UseCase throws an exception:
   - Prior committed state is retained unmodified.
   - Pending state is cleared.
   - The localized error message from `NexaBizAuthorizationPresentationErrorMapper` is surfaced via the canonical user notification mechanism.

---

## 5. Typed Presentation Error Mapping

UI code MUST NOT parse exception messages or use string matching (`e.toString().contains(...)`). All errors must be routed through `NexaBizAuthorizationPresentationErrorMapper`:

| Typed Exception                                       | Sub-reason / Action                   | Localized Resolution                     |
| :---------------------------------------------------- | :------------------------------------ | :--------------------------------------- |
| `NexaBizRoleNotFoundException`                        | —                                     | `authAdminErrorRoleNotFound`             |
| `NexaBizMembershipNotFoundException`                  | —                                     | `authAdminErrorMembershipNotFound`       |
| `NexaBizAuthorizationCrossCompanyException`           | —                                     | `authAdminErrorCrossCompany`             |
| `NexaBizBuiltInRoleProtectedException`                | `create`                              | `authAdminErrorBuiltInCreate`            |
| `NexaBizBuiltInRoleProtectedException`                | `updateMetadata`                      | `authAdminErrorBuiltInUpdate`            |
| `NexaBizBuiltInRoleProtectedException`                | `delete`                              | `authAdminErrorBuiltInDelete`            |
| `NexaBizBuiltInRoleProtectedException`                | `grantPermission`, `revokePermission` | `authAdminErrorBuiltInPermissions`       |
| `NexaBizLastOwnerProtectedException`                  | —                                     | `authAdminErrorLastOwnerProtected`       |
| `NexaBizUndeclaredPermissionException`                | —                                     | `authAdminErrorUndeclaredPermission`     |
| `NexaBizAuthorizationAdministrationConflictException` | `duplicateRoleKey`                    | `authAdminErrorDuplicateRoleKey`         |
| `NexaBizAuthorizationAdministrationConflictException` | `duplicateRoleDisplayName`            | `authAdminErrorDuplicateRoleDisplayName` |
| `NexaBizAuthorizationAdministrationConflictException` | `roleHasMembershipAssignments`        | `authAdminErrorRoleHasAssignments`       |
| `NexaBizMembershipIneligibleException`                | `inactiveMembership`                  | `authAdminErrorMembershipInactive`       |
| `NexaBizMembershipIneligibleException`                | `inactiveUser`                        | `authAdminErrorUserInactive`             |
| `NexaBizCompanyIneligibleException`                   | —                                     | `authAdminErrorCompanyInactive`          |
| `NexaBizInvalidRoleDisplayNameException`              | `empty`                               | `authAdminErrorRoleNameEmpty`            |
| `NexaBizInvalidRoleDisplayNameException`              | `tooLong`                             | `authAdminErrorRoleNameTooLong`          |
| `NexaBizPermissionDeniedException`                    | —                                     | `authAdminErrorPermissionDenied`         |
| `ArgumentError` (role key format)                     | —                                     | `authAdminErrorRoleKeyInvalid`           |
| Unhandled Exceptions                                  | —                                     | `authAdminErrorGeneric`                  |

---

## 6. Confirmation & Destructive Action Contract

- **Role Deletion**: Requires an explicit confirmation dialog displaying the role's display name (`authAdminDeleteRoleConfirm`) and irreversible warning message (`authAdminDeleteRoleConfirmMessage`).
- **Member Unassignment**: Requires explicit confirmation (`authAdminUnassignMemberConfirm`).
- **Permission Toggles**: Permission grant/revoke switches do NOT prompt a modal confirmation on every toggle; instead, they operate under commit-confirmed pending states with immediate error rollback.
- **Last Owner Actionability**: The error message for attempting to remove the last company owner MUST explicitly guide the user to assign another owner first (`authAdminErrorLastOwnerProtected`).

---

## 7. Presentation Controller & State Management Architecture

### 7.1 Single Presentation Authority

`RolesAdministrationController` serves as the sole presentation entry point for authorization administration:

```text
Widget → RolesAdministrationController → NexaBizAuthorizationAdministration facade → UseCases → PermissionGuard → Stores
```

### 7.2 Controller is NOT a Security Authority

`RolesAdministrationController` manages purely UX-state, concurrency safety, and view-model composition. It MUST NOT:

- Cache or calculate effective permissions for authorization decisions.
- Bypass permission checks or grant/revoke validations.
  The `NexaBizPermissionGuard` inside each UseCase remains the sole authoritative gatekeeper.

### 7.3 Granular Loading & State Isolation

The presentation state (`RolesAdministrationState`) uses granular, independent loading flags:

- `isLoadingRoles` / `isLoadingMoreRoles`: Scoped strictly to role list retrieval and pagination.
- `isLoadingRoleDetails` / `isLoadingRolePermissions`: Scoped strictly to selected role details.
- `isLoadingAssignedMembers` / `isLoadingMoreAssignedMembers`: Scoped to assigned members list.
- `isLoadingAssignableMembers` / `isLoadingMoreAssignableMembers`: Scoped to candidate assignment search.
- `isCreatingRole`, `isUpdatingRole`, `isDeletingRole`: Scoped to role CRUD mutations.
- `pendingPermissionIds`: Per-permission mutation sequencing guard.
- `pendingMembershipIds`: Per-membership assignment sequencing guard.

### 7.4 Locale-Neutral State

The state model carries ZERO hardcoded localized strings. It stores stable IDs, `NexaBizPermissionPresentationDescriptor` references, and `NexaBizAuthorizationPresentationError` instances. Localized messages are resolved on-demand during widget rendering via `resolveTitle(l10n)` and `resolveMessage(l10n)`, enabling instant, zero-reload locale switching.

---

## 8. Race Condition & Concurrency Defense

1. **Epoch Tracking (`_epoch`)**:
   - Increments on company switch or session logout.
   - Any in-flight asynchronous query returning with an epoch older than `_epoch` is discarded immediately without mutating state or triggering notifications.
2. **Generation Counters (`_roleListGeneration`, `_roleDetailsGeneration`, `_assignableMembersGeneration`)**:
   - Each search, filter, or selection change increments its corresponding generation counter.
   - Late responses from earlier searches or selection operations are discarded, preventing out-of-order response corruption.
3. **Double-Submit Prevention**:
   - Create, update, and delete mutations are guarded by active pending flags. Duplicate invocations while an action is pending return `false` without dispatching duplicate UseCase calls.
4. **Per-Action Sequencing Guards**:
   - Permission toggling and member assignment/unassignment track active IDs in sets (`pendingPermissionIds`, `pendingMembershipIds`). Actions on the same entity are sequenced/debounced, while independent entities may be manipulated concurrently.
5. **Dispose Safety**:
   - `RolesAdministrationController` maintains `_isDisposed`. Async completions after disposal trigger neither state mutations nor `notifyListeners()`.
6. **Invalidation Signal Coalescing**:
   - Invalidation signals from `NexaBizAuthorizationInvalidationSignal` are treated as hints to refresh rather than events to be conditionally suppressed via fragile booleans or counters.
   - When an invalidation signal arrives during an ongoing refresh, a follow-up refresh is scheduled (`_refreshRequestedWhileActive = true`), ensuring zero lost external signals and collapsing rapid cascades into at most two query cycles.
   - Query operations never emit invalidation signals, guaranteeing complete immunity to reload loops.

---

## 9. Data Gap Analysis & Resolution

1. **Role Sorting Semantics**:
   - Relational persistence in `DriftAuthorizationAdministrationStore` orders roles by `core_roles.role_key ASC` with cursor-based pagination `r.role_key > ?`.
   - The Controller adheres strictly to relational ordering. It does NOT perform local alphabetical re-sorting of partial pages, which would corrupt cursor pagination boundaries.
2. **Role Count Projections**:
   - Forensic analysis confirmed that `NexaBizCompanyRoleSummary` includes `membershipAssignmentCount`, and `NexaBizCompanyRoleDetails` includes both `membershipAssignmentCount` and `permissionAssignmentCount`.
   - Counts are computed via SQL aggregation (`COUNT`) in the relational query store without N+1 queries.
3. **Search & Kind Filtering**:
   - Forensic analysis confirmed that `ListCompanyRolesUseCase` and `listCompanyRoles` query store natively support `NexaBizCompanyRoleFilter(search, kind)`.
   - Search evaluates `normalized_name` and `role_key`; kind filtering evaluates `is_builtin`. No data gap exists.
