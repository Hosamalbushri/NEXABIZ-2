# 07 — AUTHORIZATION ADMINISTRATION CONTRACT

## 1. Scope

This contract governs future company-scoped administration of roles, role
permissions, and membership-role assignments. It defines pure Domain and
Application contracts only. UI, routes, UseCase implementations, Drift
implementations, system roles, and audit infrastructure remain outside Step 01.

System authorization remains deferred and fail-closed.

## 2. Security boundary

Every protected mutation MUST follow this order:

```text
trusted NexaBizCompanyAuthorizationContext
  -> required administration permission
  -> NexaBizPermissionGuard (explicit ALLOW only)
  -> catalog and tenant validation
  -> one atomic repository transaction
  -> mutation
  -> successful commit
  -> authorization invalidation notification
```

DENY, UNKNOWN, validation failure, transaction failure, and commit failure MUST
produce zero mutation and zero invalidation notification. PermissionGate and the
router remain UX and defense-in-depth boundaries only.

Every operation is explicitly bound to `NexaBizCompanyId`. UI callers cannot
substitute raw user, company, or membership strings for the trusted context.

## 3. Permission model

The Permissions capability and locked capability registry remain the only
declaration authority. Database rows cannot declare permissions.

| Operation                              | Required permission             | Tenant scope     | Transaction | Invalidation |
| :------------------------------------- | :------------------------------ | :--------------- | :---------- | :----------- |
| List declared permission catalog       | `permissions.catalog.view`      | Company context  | No          | No           |
| Read/list company roles                | `permissions.policy.review`     | Explicit company | No          | No           |
| Inspect role permissions               | `permissions.policy.review`     | Explicit company | No          | No           |
| Inspect membership-role assignments    | `permissions.policy.review`     | Explicit company | No          | No           |
| List memberships assigned to a role    | `permissions.policy.review`     | Explicit company | No          | No           |
| List assignable memberships for a role | `permissions.assignment.manage` | Explicit company | No          | No           |
| Inspect effective permissions          | `permissions.policy.review`     | Explicit company | No          | No           |
| Create/update/delete custom roles      | `permissions.role.manage`       | Explicit company | Yes         | After commit |
| Grant/revoke role permissions          | `permissions.policy.manage`     | Explicit company | Yes         | After commit |
| Assign/unassign membership roles       | `permissions.assignment.manage` | Explicit company | Yes         | After commit |

`view` and `review` permissions never authorize writes. No aggregate
`permissions.admin.all` permission exists.

## 4. Existing database compatibility

Step 01 declares the three new write permissions in the capability catalog but
does not change schema v5 or owner grants:

- `permissions.role.manage`
- `permissions.policy.manage`
- `permissions.assignment.manage`

Fresh and existing schema-v5 databases therefore both lack these grants. This
is intentional while no administration UseCases exist and avoids giving fresh
installs authority that existing installs do not receive.

Before any administration mutation UseCase is enabled, the persistence step
MUST ship one migration that:

1. backfills all three grants to every valid built-in `company.owner` role;
2. updates the fresh-install owner seed in the same release;
3. is idempotent and preserves all existing grants; and
4. verifies that every migrated owner role belongs to its company.

Partial seed-only rollout is forbidden.

## 5. Role identity and metadata

`NexaBizRoleId` is the stable canonical role key (`company.name`). Persistence
row UUIDs are internal and never cross the administration contract. Custom role
keys are generated or selected once by the trusted Application layer, validated
by `NexaBizRoleId`, company-scoped, and immutable. Display-name changes never
change role identity or permission mappings.

`NexaBizRoleDisplayName`:

- trims leading and trailing whitespace;
- rejects empty values;
- permits Unicode and preserves the entered Unicode text;
- is limited to 100 Unicode scalar values; and
- uses the lowercased trimmed value as its company-local duplicate key.

Duplicate display names within one company are typed conflicts. The same name
may exist in different companies. A future persistence implementation needs a
normalized company-local uniqueness strategy; exception-text matching is not
allowed.

Role scope, role key, and built-in status are immutable and absent from the
metadata-update API. No role status is introduced.

## 6. Built-in roles and last owner

Known built-in identities are centralized in `NexaBizBuiltInCompanyRoles`.
UseCases must not scatter `company.owner` comparisons.

For every built-in company role:

- creation through the custom-role API is forbidden;
- rename and metadata updates are forbidden;
- deletion is forbidden;
- scope, role key, and built-in status are immutable;
- permission grants and revocations are forbidden through Application
  administration; and
- built-in permission changes are reserved for explicit, versioned migrations.

The `company.owner` assignment may be removed only when at least one other
active owner membership remains after the mutation. Active means company,
membership, and user are all active. The check and unassignment MUST occur in
the same write-serialized transaction.

Self-demotion is allowed when company safety remains intact. No username,
display name, or current-actor special case is used. Removing the last active
owner is forbidden even when the actor is attempting to remove another user.

## 7. Tenant and membership rules

Application and persistence layers both validate tenant ownership. A Company A
context cannot inspect or mutate a Company B role or membership. SQLite foreign
keys and triggers remain defense-in-depth rather than the sole policy.

New role assignment requires an active company, active membership, and active
user. Unassignment from an inactive membership is allowed for cleanup, subject
to tenant ownership and the last-active-owner invariant.

The legacy `core_company_memberships.role` column is not part of any new query,
policy, identity, or authorization decision. New contracts use
`core_membership_roles` and `core_roles` semantics only.

## 8. Idempotency and deletion

| Mutation                            | Repeated/missing state        |
| :---------------------------------- | :---------------------------- |
| Assign an already assigned role     | Successful `unchanged` result |
| Grant an already granted permission | Successful `unchanged` result |
| Revoke a missing permission         | Successful `unchanged` result |
| Unassign a missing role             | Successful `unchanged` result |
| Update with identical metadata      | Successful `unchanged` result |
| Create duplicate role key/name      | Typed conflict                |
| Delete missing role                 | Typed role-not-found error    |

A custom role can be deleted only when it has zero membership assignments.
Assigned permissions are removed explicitly within the same transaction as the
role. Cascades may provide defense-in-depth but do not define business policy.

## 9. Transaction and concurrency requirements

Every mutation-store call is one atomic validation-and-write operation. The
implementation must not expose a read/leave-transaction/write sequence.

Last-owner removal and duplicate role-name enforcement require write
serialization. The Step 02 design must use an immediate write transaction or an
equivalent serialization mechanism and add database-level protection for the
last-owner aggregate invariant. This prevents two administrators from both
observing another owner and committing removals that leave zero owners.

`NexaBizAuthorizationInvalidationSignal` remains an Application composition
dependency. Drift must not depend on it. The UseCase notifies exactly once after
a changed commit and never before or during the transaction. An idempotent
`unchanged` result does not require invalidation.

## 10. Query and audit preparation

Queries return typed summaries, details, permission assignments, membership
assignments, and effective-permission inspection projections. They never expose
Drift rows. Listings use bounded cursor requests and optional role search/kind
filters; no contract requires loading an entire database.

Mutation results expose changed/unchanged state plus before/after projections.
Combined with the trusted authorization context, this permits future audit
records for actor, company, operation, target, and before/after data without
coupling Step 01 to audit infrastructure.

Effective-permission inspection is an immutable query projection. It must not be
stored in `NexaBizSession` and is not an effective-permission cache.

## 11. Error model

Expected outcomes use `NexaBizAuthorizationAdministrationException` subtypes:

- role or membership not found;
- cross-company mismatch;
- protected built-in role;
- last-owner protection;
- undeclared permission;
- typed conflict;
- ineligible membership/user/company; and
- invalid role display name.

Permission denial remains `NexaBizPermissionDeniedException`. UI code must not
interpret SQLite exception messages, and no layer may classify outcomes using
exception-string matching.
