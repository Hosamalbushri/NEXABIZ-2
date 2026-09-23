/// Scope of a role in the system: either global system-level or company-tenant-level.
enum NexaBizRoleScope {
  system,
  company;

  bool get isSystem => this == NexaBizRoleScope.system;
  bool get isCompany => this == NexaBizRoleScope.company;
}
