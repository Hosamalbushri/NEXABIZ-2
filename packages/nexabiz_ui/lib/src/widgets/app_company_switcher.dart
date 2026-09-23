import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

import '../theme/tokens/tokens.dart';

/// Canonical enterprise company and branch switcher primitive for NexaBiz ERP.
///
/// Designed to reside within [AppSidebar] header or [AppTopHeader]. Provides
/// a prominent active-company anchor with branch and financial period indication.
class AppCompanySwitcher extends StatelessWidget {
  /// Active company name.
  final String companyName;

  /// Optional active branch or division name.
  final String? branchName;

  /// Optional company logo or avatar icon.
  final Widget? logo;

  /// Callback when the switcher is tapped (e.g. to open the company switch dialog).
  final VoidCallback? onTap;

  /// Whether the switcher is in collapsed/icon-only mode.
  final bool isCollapsed;

  const AppCompanySwitcher({
    super.key,
    required this.companyName,
    this.branchName,
    this.logo,
    this.onTap,
    this.isCollapsed = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = shadcn.Theme.of(context);
    final colorScheme = theme.colorScheme;

    final defaultLogo = Container(
      width: 32.0,
      height: 32.0,
      decoration: BoxDecoration(
        color: colorScheme.primary,
        borderRadius: BorderRadius.circular(AppRadii.xs),
      ),
      alignment: Alignment.center,
      child: Text(
        companyName.isNotEmpty
            ? companyName.substring(0, 1).toUpperCase()
            : 'N',
        style: TextStyle(
          color: colorScheme.primaryForeground,
          fontWeight: FontWeight.w700,
          fontSize: 14.0,
        ),
      ),
    );

    final avatar = logo ?? defaultLogo;

    if (isCollapsed) {
      return shadcn.Tooltip(
        tooltip: (context) => Text(
          branchName != null ? '$companyName — $branchName' : companyName,
        ),
        child: shadcn.Button(
          style: const shadcn.ButtonStyle.ghost(),
          alignment: Alignment.center,
          onPressed: onTap,
          child: avatar,
        ),
      );
    }

    return shadcn.Button(
      style: const shadcn.ButtonStyle.ghost(),
      alignment: AlignmentDirectional.centerStart,
      onPressed: onTap,
      child: Row(
        children: [
          avatar,
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  companyName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.typography.small.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colorScheme.foreground,
                  ),
                ),
                if (branchName != null)
                  Text(
                    branchName!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.typography.xSmall.copyWith(
                      color: colorScheme.mutedForeground,
                      fontSize: 11.0,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          Icon(
            shadcn.LucideIcons.chevronsUpDown,
            size: 14.0,
            color: colorScheme.mutedForeground,
          ),
        ],
      ),
    );
  }
}
