# 05 — Basic module boundaries and sequencing

Authority: [Project Constitution](../architecture/00_PROJECT_CONSTITUTION.md) and [Package Contract](../architecture/01_PACKAGE_CONTRACT.md). This file sets scope and order; it does not authorize implementation or define new package contracts.

## Basic modules for later phases

- Identity and authentication
- Tenancy and company context
- System setup
- Permissions
- Administration
- Currency
- Document numbering

Each proposed runtime module follows [Capability Creation Rules](01_CAPABILITY_CREATION_RULES.md). Decide its domain owner, dependencies, data authority, security boundary, and completion criteria in its own approved implementation phase. Do not assume the current navigation registry provides authentication or authorization.

## Framework-neutral runtime contracts

`lib/core/company/`, `session/`, `setup/`, and `permissions/` define only identifiers and immutable state or intent. `NexaBizCompanyScope.systemSetup()` is the unscoped state for global initialization; company-bound operations should call `requireCompany()` to reject it. An active or locked `NexaBizSession` always has exactly one validated company ID. A later company switch must end that session and establish a new one. `NexaBizSetupReadiness` cannot be `ready` until the explicit Core requirements for company and administrator are complete. Business configuration does not determine Core readiness. `NexaBizPermissionDecision.unknown` means no configured decision and is distinct from `deny`.

`NexaBizRouteDefinition.accessRequirement` may describe session, company, setup, and permission requirements. It is metadata only: neither the navigation registry nor `NexaBizGoRouterAdapter` enforces it. No protected production route should rely on this field alone until a later authorized phase implements and tests an actual guard at the canonical router boundary. These contracts add no storage, role model, provider, or UI.

## Core persistence foundation

SQLite is the storage engine; Drift is the sole relational access and schema layer for Core. The application opens one database file in its support directory before capability registration. `NexaBizCoreInstallationStore` keeps the readiness contract independent of Drift. The Core-owned schema contains companies, users, company memberships, and schema migration metadata only. Core must not import business tables; future capabilities own their own schemas and migrations. A shared database composition boundary can be extended later without making Core depend on business implementations.

The relational database is authoritative for Company, User, Membership, and Core readiness. Readiness requires an active owner/admin membership linking an active, identified user to an active, identified company. Disconnected v1 marker rows remain incomplete. `SharedPreferences` remains for preferences such as locale and is not an identity authority. Hive is not a Core identity authority. Storage open, migration, and read failures propagate instead of appearing fresh.

The new database has its own version history: v1 was the direct SQLite foundation; v2 uses Drift. Its v1→v2 migration preserves existing IDs and the historical administrator marker but does not invent missing company, user, or membership facts. Migration and future company/administrator writes run in transactions. Credentials and sessions remain outside this step. The current database file is not claimed to be encrypted; secure database handling is deferred. Tests inject isolated temporary paths.

## Deferred business modules

- Accounting
- Sales
- Purchases
- Inventory
- Customers
- Receipts and payments
- Business reports

Do not build a business module before the basic modules it depends on are completed and their boundaries are verified. Existing dashboard, services, and reports navigation surfaces are not evidence that a business module is complete. The old project is a conceptual requirements reference only: do not copy its code, packages, dependencies, persistence design, or navigation structure into NEXABIZ-2.
