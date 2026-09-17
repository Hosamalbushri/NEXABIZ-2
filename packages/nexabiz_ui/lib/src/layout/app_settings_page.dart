import 'package:flutter/widgets.dart';

import '../widgets/app_custom_app_bar.dart';
import '../widgets/app_error_state.dart';
import '../widgets/app_loading.dart';
import 'app_layout_tokens.dart';
import 'app_page.dart';

/// Canonical Settings Page layout component for NexaBiz screens.
class AppSettingsPage extends StatelessWidget {
  const AppSettingsPage({
    super.key,
    required this.title,
    required this.sections,
    this.subtitle,
    this.breadcrumbs,
    this.headerActions,
    this.actions,
    this.showBackButton,
    this.onBack,
    this.isLoading = false,
    this.errorText,
    this.onRetry,
    this.maxWidth = AppLayoutTokens.maxSettingsWidth,
  });

  final String title;
  final String? subtitle;
  final List<String>? breadcrumbs;
  final List<Widget>? headerActions;
  final bool? showBackButton;
  final VoidCallback? onBack;

  final List<Widget> sections;
  final List<Widget>? actions;
  final bool isLoading;
  final String? errorText;
  final VoidCallback? onRetry;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final appBarWidget = AppCustomAppBar(
      title: title,
      subtitle: subtitle,
      actions: headerActions,
      showBackButton: showBackButton ?? false,
      onBack: onBack,
    );

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
          for (int i = 0; i < sections.length; i++) ...[
            sections[i],
            if (i < sections.length - 1)
              const SizedBox(height: AppLayoutTokens.sectionGap),
          ],
          if (actions != null && actions!.isNotEmpty) ...[
            const SizedBox(height: AppLayoutTokens.sectionGap),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: actions!,
            ),
          ],
        ],
      ),
    );
  }
}
