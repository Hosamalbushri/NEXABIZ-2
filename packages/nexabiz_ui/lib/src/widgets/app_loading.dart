import 'package:flutter/material.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

import '../theme/tokens/app_spacing.dart';
import 'app_card.dart';

enum AppLoadingStyle { circular, linear, skeletonList }

/// Loading indicator with optional skeleton placeholders backed by shadcn_flutter.
class AppLoading extends StatelessWidget {
  const AppLoading({
    super.key,
    this.style = AppLoadingStyle.circular,
    this.message,
    this.progress,
    this.skeletonItemCount = 6,
    this.showMessage = true,
  });

  final AppLoadingStyle style;
  final String? message;
  final double? progress;
  final int skeletonItemCount;
  final bool showMessage;

  @override
  Widget build(BuildContext context) {
    final label = message ?? 'Loading...';

    switch (style) {
      case AppLoadingStyle.circular:
        final spinner = shadcn.CircularProgressIndicator(value: progress);
        if (!showMessage) {
          return Center(child: spinner);
        }
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              spinner,
              const SizedBox(height: AppSpacing.md),
              Text(label),
            ],
          ),
        );
      case AppLoadingStyle.linear:
        return Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(label),
              const SizedBox(height: AppSpacing.sm),
              shadcn.Progress(progress: progress),
            ],
          ),
        );
      case AppLoadingStyle.skeletonList:
        return shadcn.SkeletonExtension(
          ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.md),
            itemCount: skeletonItemCount,
            separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
            itemBuilder: (context, index) {
              return AppCard(
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: shadcn.Theme.of(context).colorScheme.muted,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('Loading item title placeholder'),
                          SizedBox(height: AppSpacing.xxs),
                          Text('Secondary loading line placeholder'),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ).asSkeleton();
    }
  }
}
