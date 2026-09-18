import 'package:flutter/widgets.dart';

import '../widgets/app_custom_app_bar.dart';
import '../widgets/app_error_state.dart';
import '../widgets/app_loading.dart';
import 'app_layout_tokens.dart';
import 'app_page.dart';

/// Canonical Dashboard Page layout component for NexaBiz screens.
class AppDashboardPage extends StatelessWidget {
  const AppDashboardPage({
    super.key,
    this.title = '',
    this.subtitle,
    this.breadcrumbs,
    this.headerActions,
    this.statsGrid = const SizedBox.shrink(),
    this.carousel,
    required this.content,
    this.quickActions,
    this.recentActivity,
    this.isLoading = false,
    this.errorText,
    this.onRetry,
    this.maxWidth = AppLayoutTokens.maxDashboardWidth,
  });

  final String title;
  final String? subtitle;
  final List<String>? breadcrumbs;
  final List<Widget>? headerActions;

  final Widget statsGrid;
  final Widget? carousel;
  final Widget content;
  final Widget? quickActions;
  final Widget? recentActivity;
  final bool isLoading;
  final String? errorText;
  final VoidCallback? onRetry;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final hasHeader =
        title.isNotEmpty ||
        (subtitle != null && subtitle!.isNotEmpty) ||
        (headerActions != null && headerActions!.isNotEmpty);

    final appBarWidget = hasHeader
        ? AppCustomAppBar(
            title: title,
            subtitle: subtitle,
            actions: headerActions,
          )
        : null;

    if (isLoading) {
      return AppPage(
        maxWidth: maxWidth,
        scrollable: true,
        appBar: appBarWidget,
        child: const AppLoading(),
      );
    }

    if (errorText != null) {
      return AppPage(
        maxWidth: maxWidth,
        scrollable: true,
        appBar: appBarWidget,
        child: AppErrorState(message: errorText, onRetry: onRetry),
      );
    }

    return AppPage(
      maxWidth: maxWidth,
      scrollable: true,
      appBar: appBarWidget,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          statsGrid,
          if (statsGrid is! SizedBox)
            const SizedBox(height: AppLayoutTokens.dashboardSectionGap),
          if (carousel != null) ...[
            carousel!,
            const SizedBox(height: AppLayoutTokens.dashboardSectionGap),
          ],
          if (quickActions != null) ...[
            quickActions!,
            const SizedBox(height: AppLayoutTokens.dashboardSectionGap),
          ],
          content,
          if (recentActivity != null) ...[
            const SizedBox(height: AppLayoutTokens.dashboardSectionGap),
            recentActivity!,
          ],
        ],
      ),
    );
  }
}
