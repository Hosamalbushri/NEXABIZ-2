import '../../../../core/permissions/nexabiz_permission_intent.dart';
import '../../../../l10n/app_localizations.dart';

/// Stable, typed presentation grouping for capability permissions.
///
/// This enum provides a strongly-typed, language-neutral identity for presentation
/// sections without inspecting or splitting permission string identifiers.
enum NexaBizPermissionPresentationGroup {
  company(order: 0),
  identity(order: 1),
  authorization(order: 2),
  other(order: 3);

  const NexaBizPermissionPresentationGroup({required this.order});

  /// Deterministic sort order for group sections in presentation UI.
  final int order;

  /// Resolves the human-readable, localized title for this presentation group.
  String resolveTitle(AppLocalizations l10n) => switch (this) {
    company => l10n.authAdminGroupCompany,
    identity => l10n.authAdminGroupIdentity,
    authorization => l10n.authAdminGroupAuthorization,
    other => l10n.authAdminGroupOther,
  };
}

/// Language-neutral descriptor that defines group assignment, within-group sort order,
/// and localization resolution closures for a single permission.
///
/// This class carries ZERO security authority. It is strictly a presentation mapping
/// primitive from `NexaBizPermissionId` to UI presentation metadata.
final class NexaBizPermissionPresentationDescriptor {
  const NexaBizPermissionPresentationDescriptor({
    required this.permissionId,
    required this.group,
    required this.sortOrder,
    required this.titleResolver,
    required this.descriptionResolver,
    this.isExplicit = true,
  });

  /// Canonical security identity of the permission.
  final NexaBizPermissionId permissionId;

  /// Structural presentation group.
  final NexaBizPermissionPresentationGroup group;

  /// Deterministic presentation sort order within [group].
  final int sortOrder;

  /// Closure resolving the localized title from [AppLocalizations].
  final String Function(AppLocalizations l10n) titleResolver;

  /// Closure resolving the localized description from [AppLocalizations].
  final String Function(AppLocalizations l10n) descriptionResolver;

  /// True when this permission has an explicitly registered catalog mapping;
  /// false when constructed dynamically via the unknown-permission fallback.
  final bool isExplicit;

  String resolveTitle(AppLocalizations l10n) => titleResolver(l10n);

  String resolveDescription(AppLocalizations l10n) => descriptionResolver(l10n);
}

/// Fully resolved permission metadata model ready for consumption by presentation widgets.
final class NexaBizResolvedPermissionPresentation {
  const NexaBizResolvedPermissionPresentation({
    required this.permissionId,
    required this.group,
    required this.groupTitle,
    required this.title,
    required this.description,
    required this.sortOrder,
    required this.isExplicit,
  });

  final NexaBizPermissionId permissionId;
  final NexaBizPermissionPresentationGroup group;
  final String groupTitle;
  final String title;
  final String description;
  final int sortOrder;
  final bool isExplicit;
}
