import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

import '../theme/tokens/app_icons.dart';
import '../theme/tokens/app_spacing.dart';
import '../theme/tokens/app_typography.dart';
import 'app_icon_button.dart';

double _resolveTitleFontSize(String title) {
  final length = title.trim().length;
  if (length <= 14) return 22.0;
  if (length <= 24) return 18.0;
  return 16.0;
}

@immutable
class AppCustomAppBarStyle {
  const AppCustomAppBarStyle({
    this.height = 64.0,
    this.borderRadius = 24.0,
    this.elevation = 8.0,
    this.backgroundColor,
    this.foregroundColor,
    this.centerTitle = true,
    this.horizontalPadding = 16.0,
    this.shadowColor,
  });

  final double height;
  final double borderRadius;
  final double elevation;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final bool centerTitle;
  final double horizontalPadding;
  final Color? shadowColor;

  factory AppCustomAppBarStyle.adaptive(BuildContext context) {
    final theme = shadcn.Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final scheme = theme.colorScheme;

    return AppCustomAppBarStyle(
      centerTitle: true,
      backgroundColor: isDark ? scheme.muted : scheme.card,
      foregroundColor: scheme.foreground,
      shadowColor: scheme.primary.withValues(alpha: isDark ? 0.18 : 0.12),
    );
  }
}

class AppCustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const AppCustomAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.style,
    this.bottom,
    this.actions,
    this.leading,
    this.showBackButton = false,
    this.onBack,
    this.showMenuButton = false,
    this.onMenu,
    this.showSearch = false,
    this.onSearch,
    this.showNotifications = false,
    this.notificationCount = 0,
    this.onNotifications,
    this.profileImage,
    this.profileInitials,
    this.onProfileTap,
    this.centerTitle,
  });

  final String title;
  final String? subtitle;
  final AppCustomAppBarStyle? style;
  final PreferredSizeWidget? bottom;
  final List<Widget>? actions;
  final Widget? leading;
  final bool showBackButton;
  final VoidCallback? onBack;
  final bool showMenuButton;
  final VoidCallback? onMenu;
  final bool showSearch;
  final VoidCallback? onSearch;
  final bool showNotifications;
  final int notificationCount;
  final VoidCallback? onNotifications;
  final ImageProvider<Object>? profileImage;
  final String? profileInitials;
  final VoidCallback? onProfileTap;
  final bool? centerTitle;

  @override
  Size get preferredSize {
    final resolvedStyle = style ?? const AppCustomAppBarStyle();
    final bottomHeight = bottom?.preferredSize.height ?? 0;
    return Size.fromHeight(resolvedStyle.height + bottomHeight);
  }

  @override
  Widget build(BuildContext context) {
    final theme = shadcn.Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final resolvedStyle = (style ?? AppCustomAppBarStyle.adaptive(context));
    final isCentered = centerTitle ?? resolvedStyle.centerTitle;

    final background =
        resolvedStyle.backgroundColor ??
        (isDark ? colorScheme.muted : colorScheme.card);
    final foreground = resolvedStyle.foregroundColor ?? colorScheme.foreground;
    final shadowColor =
        resolvedStyle.shadowColor ??
        colorScheme.primary.withValues(alpha: isDark ? 0.18 : 0.12);

    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final canPop = Navigator.canPop(context);
    final shouldShowBack = showBackButton || canPop;

    Widget? leadingWidget;
    if (leading != null) {
      leadingWidget = leading;
    } else if (shouldShowBack) {
      leadingWidget = AppIconButton(
        variant: AppIconButtonVariant.chip,
        iconSize: 18.0,
        icon: isRtl ? AppIcons.chevronRight : AppIcons.chevronLeft,
        tooltip: isRtl ? 'رجوع' : 'Back',
        onPressed: onBack ?? () => Navigator.of(context).maybePop(),
      );
    } else if (showMenuButton) {
      leadingWidget = AppIconButton(
        variant: AppIconButtonVariant.chip,
        iconSize: 18.0,
        icon: AppIcons.grid,
        tooltip: isRtl ? 'القائمة' : 'Menu',
        onPressed: onMenu,
      );
    }

    final trailingCluster = <Widget>[
      ...?actions,
      if (showSearch)
        AppIconButton(
          variant: AppIconButtonVariant.chip,
          iconSize: 18.0,
          icon: shadcn.LucideIcons.search,
          tooltip: isRtl ? 'بحث' : 'Search',
          onPressed: onSearch,
        ),
      if (showNotifications)
        AppIconButton(
          variant: AppIconButtonVariant.chip,
          iconSize: 18.0,
          icon: shadcn.LucideIcons.bell,
          tooltip: isRtl ? 'الإشعارات' : 'Notifications',
          badgeCount: notificationCount > 0 ? notificationCount : null,
          onPressed: onNotifications,
        ),
    ];

    final fontSize = _resolveTitleFontSize(title);

    final titleWidget = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: isCentered
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: isCentered
              ? Alignment.center
              : AlignmentDirectional.centerStart,
          child: Text(
            title,
            maxLines: 1,
            softWrap: false,
            overflow: TextOverflow.visible,
            textAlign: isCentered ? TextAlign.center : TextAlign.start,
            style: TextStyle(
              fontFamily: AppTypography.fontFamilyName,
              fontSize: fontSize,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.6,
              height: 1.05,
              color: foreground,
            ),
          ),
        ),
        if (subtitle != null && subtitle!.isNotEmpty) ...[
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: isCentered
                ? Alignment.center
                : AlignmentDirectional.centerStart,
            child: Text(
              subtitle!,
              textAlign: isCentered ? TextAlign.center : TextAlign.start,
              maxLines: 1,
              style: TextStyle(
                fontFamily: AppTypography.fontFamilyName,
                fontSize: 12.0,
                color: colorScheme.mutedForeground,
              ),
            ),
          ),
        ],
      ],
    );

    return PreferredSize(
      preferredSize: preferredSize,
      child: ClipRRect(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(resolvedStyle.borderRadius),
          bottomRight: Radius.circular(resolvedStyle.borderRadius),
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(resolvedStyle.borderRadius),
              bottomRight: Radius.circular(resolvedStyle.borderRadius),
            ),
            boxShadow: [
              BoxShadow(
                color: shadowColor,
                blurRadius: resolvedStyle.elevation * 2.4,
                offset: Offset(0, resolvedStyle.elevation * 0.45),
              ),
            ],
          ),
          child: SafeArea(
            bottom: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: resolvedStyle.horizontalPadding,
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        if (leadingWidget != null)
                          Align(
                            alignment: AlignmentDirectional.centerStart,
                            child: leadingWidget,
                          ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal:
                                leadingWidget != null ||
                                    trailingCluster.isNotEmpty
                                ? 52.0
                                : 0.0,
                          ),
                          child: titleWidget,
                        ),
                        if (trailingCluster.isNotEmpty)
                          Align(
                            alignment: AlignmentDirectional.centerEnd,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                for (
                                  var i = 0;
                                  i < trailingCluster.length;
                                  i++
                                ) ...[
                                  if (i > 0)
                                    const SizedBox(width: AppSpacing.xs),
                                  trailingCluster[i],
                                ],
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                ?bottom,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
