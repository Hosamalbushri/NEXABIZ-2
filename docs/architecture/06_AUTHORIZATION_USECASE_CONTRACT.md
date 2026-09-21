# 06 — USECASE AUTHORIZATION SECURITY BOUNDARY CONTRACT

## 1. PURPOSE & PRINCIPLE

This document establishes the **MANDATORY SECURITY ENFORCEMENT CONTRACT** for all application and business operations in NexaBiz.

### Fundamental Principle
The **UseCase** is the authoritative, non-bypassable **Security Enforcement Boundary** for all business operations in NexaBiz:
`UI -> UseCase -> PermissionGuard -> PermissionEvaluator -> Persistence`.

```text
UI Layer (Presentation)
       ↓  (passes trusted AuthorizationContext)
Application / Business UseCase
       ↓  (MUST invoke requirePermission FIRST)
NexaBizPermissionGuard
       ↓  (evaluates against active session snapshot)
NexaBizPermissionEvaluator
       ↓  (explicit ALLOW)
Domain Mutation / Repository Persistence
```

---

## 2. NON-NEGOTIABLE INVARIANTS

1. **UI `PermissionGate` is UX only**:
   - Conditional UI rendering, hidden action buttons, and disabled inputs improve user experience.
   - They **NEVER** constitute security enforcement.
   - The UI layer MUST NOT call repositories directly to perform mutations or privileged queries.

2. **Router Permission Checks are Defense-in-Depth only**:
   - Route guards and redirection protect screen navigation and URL deep linking.
   - Route access checks **NEVER** replace or bypass UseCase-level authorization.

3. **Protected Business UseCases MUST call `NexaBizPermissionGuard` before side effects**:
   - Every protected business operation MUST take `NexaBizPermissionGuard` as a required, non-nullable constructor dependency.
   - Authorization MUST be evaluated **before** executing any mutation, sequence reservation, ledger posting, inventory movement, audit record creation, or external dispatch.

4. **Role names NEVER authorize operations**:
   - UseCases MUST NOT evaluate role names (`role == 'owner'`, `role == 'admin'`, `isAdmin`, `isOwner`, `systemAdmin`).
   - Operation permission is governed solely by explicit canonical permission grants (`NexaBizPermissionId`).

5. **Missing or failed authorization MUST fail closed**:
   - If authorization produces `DENY` or `UNKNOWN`, the guard throws `NexaBizPermissionDeniedException`.
   - The UseCase MUST NOT catch or suppress this exception to execute fallback mutations.
   - An uninitialized or optional guard (`PermissionGuard?`) is strictly forbidden.

6. **Denial = ZERO Side Effects**:
   - Under `DENY`, `UNKNOWN`, expired session, stale session, or mismatched tenancy, the UseCase aborts instantly.
   - Zero database rows are inserted/updated/deleted.
   - Zero sequence numbers or document numbers are consumed.
   - Zero session states are altered.
   - Zero business callbacks or domain events are fired.

---

## 3. CANONICAL PROTECTED USECASE PATTERN

Every future business UseCase MUST follow this exact structural pattern:

```dart
final class UpdateCompanyProfileUseCase {
  const UpdateCompanyProfileUseCase({
    required NexaBizPermissionGuard permissionGuard,
    required CompanyRepository repository,
  })  : _guard = permissionGuard,
        _repository = repository;

  final NexaBizPermissionGuard _guard;
  final CompanyRepository _repository;

  Future<void> execute({
    required NexaBizAuthorizationContext context,
    required CompanyProfileUpdate input,
  }) async {
    // 1. Authoritative Guard Check BEFORE any business logic or mutations
    await _guard.requirePermission(
      context: context,
      permissionId: const NexaBizPermissionId('company.profile.manage'),
    );

    // 2. Business Mutation (ONLY executed if permission is explicitly ALLOWED)
    await _repository.updateProfile(input);
  }
}
```

---

## 4. AUTHORIZATION CONTEXT PROVENANCE

To prevent UI callers from constructing arbitrary or forged authorization contexts from raw strings:
- The Application Layer acquires the authoritative context from the active session:
  ```dart
  final context = NexaBizAuthorizationContext.fromSession(sessionController.currentSession);
  ```
- If the session is inactive, missing, or lacks required tenant bindings, `fromSession` throws a `StateError` immediately, preventing unauthenticated operations from reaching evaluation.

---

## 5. BOUNDARY CLASSIFICATION: FOUNDATION VS BUSINESS

Not all operations require `NexaBizPermissionGuard`. The architecture defines two distinct categories:

### A. Foundation / Security Bootstrap Operations (Pre-Authorization Boundary)
These operations precede or manage the security context itself:
- **System Setup / Core Initialization (`InitializeNexaBizCore`)**:
  Initializes the system before any user, company, or session exists.
- **Local User Authentication (`AuthenticateLocalUser`)**:
  Verifies credentials before a session is granted.
- **Session Lifecycle & Company Selection (`CoreSessionController`)**:
  Manages session establishment, logout, and company switching. Company switching is governed strictly by **valid active company membership eligibility**, not by commercial permissions.

### B. Protected Business Operations (Authorization Boundary)
All domain and business actions executed within an established session:
- Viewing or modifying company details / profiles.
- User management and membership administration.
- Future commercial domains: Accounting postings, inventory adjustments, sales, purchasing, customer management.
- All protected operations MUST enforce `NexaBizPermissionGuard`.

---

## 6. TOCTOU (TIME-OF-CHECK TO TIME-OF-USE) BOUNDARY CLASSIFICATION

Because permission evaluation and business mutation are currently distinct asynchronous calls, operations are classified as follows:

### Ordinary Business Operations
- Standard operations (e.g. updating profile details, viewing reports, creating drafts).
- The `Guard-before-execute` pattern provides sufficient security.

### Security-Critical & Financial Irreversible Operations
- High-impact operations:
  * Accounting Ledger Posting
  * Reversal Transactions
  * Fiscal Period Close
  * Role Creation, Assignment, & Permission Policy Modification
- **Future Architectural Invariant**:
  These operations will require coordinated transactional boundaries where authorization state is validated within the same atomic database transaction as the business mutation.

---

## 7. AUTHORIZATION OF AUTHORIZATION CHANGES

Any future UseCase that modifies:
- `core_roles`
- `core_membership_roles`
- `core_role_permissions`
- Permission policies

MUST itself be protected by an explicit administrative permission (e.g. `permissions.policy.manage`).
The role name `owner` or `admin` MUST NEVER be used as an implicit bypass.
