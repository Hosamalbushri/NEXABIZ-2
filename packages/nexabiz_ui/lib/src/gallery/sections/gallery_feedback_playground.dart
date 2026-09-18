import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;
import '../../../nexabiz_ui.dart';
import '../gallery_preview_card.dart';

class GalleryFeedbackPlayground extends StatefulWidget {
  final GalleryStateController controller;

  const GalleryFeedbackPlayground({super.key, required this.controller});

  @override
  State<GalleryFeedbackPlayground> createState() =>
      _GalleryFeedbackPlaygroundState();
}

class _GalleryFeedbackPlaygroundState extends State<GalleryFeedbackPlayground> {
  double _progressValue = 65.0;

  @override
  Widget build(BuildContext context) {
    final cat = GalleryCategory.feedback;
    final ctrl = widget.controller;

    final cards = <Widget>[];

    // 1. Alert Banner
    if (ctrl.isComponentMatching(
      'Alert / AlertBanner',
      'Contextual warning and status alert banners',
      cat,
    )) {
      cards.add(
        GalleryPreviewCard(
          name: 'Alert / AlertBanner',
          category: cat,
          description:
              'Contextual alert banners for informative, success, or warning notifications.',
          usageNotes:
              'Use shadcn.Alert for page-level status banners or validation warnings.',
          dartCode: '''
shadcn.Alert(
  title: Text('Database Synchronization Delayed'),
  content: Text('Off-line local queue contains 14 pending vouchers awaiting cloud sync.'),
)''',
          preview: Column(
            children: const [
              shadcn.Alert(
                title: Text('Database Synchronization Delayed'),
                content: Text(
                  'Off-line local queue contains 14 pending vouchers awaiting cloud sync.',
                ),
              ),
              SizedBox(height: AppSpacing.xs),
              shadcn.Alert(
                title: Text('Fiscal Year Period Closed'),
                content: Text(
                  'General ledger postings for Q4 2025 are locked.',
                ),
              ),
            ],
          ),
        ),
      );
    }

    // 2. Badge & StatusBadge
    if (ctrl.isComponentMatching(
      'Badge',
      'Semantic status and metric badge indicators',
      cat,
    )) {
      cards.add(
        GalleryPreviewCard(
          name: 'Badge & StatusBadge',
          category: cat,
          description:
              'Compact semantic badges representing entity status or counts.',
          usageNotes:
              'Use AppStatusBadge for voucher status (Draft, Posted, Voided).',
          dartCode: '''
AppStatusBadge(
  label: 'Posted',
  tone: AppStatusTone.success,
)''',
          preview: Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: const [
              AppStatusBadge(label: 'Draft', tone: AppStatusTone.neutral),
              AppStatusBadge(
                label: 'Pending Approval',
                tone: AppStatusTone.warning,
              ),
              AppStatusBadge(label: 'Posted', tone: AppStatusTone.success),
              AppStatusBadge(label: 'Rejected', tone: AppStatusTone.error),
            ],
          ),
        ),
      );
    }

    // 3. Progress Bar & Circular Progress
    if (ctrl.isComponentMatching(
      'Progress',
      'Determinate and indeterminate progress indicator',
      cat,
    )) {
      cards.add(
        GalleryPreviewCard(
          name: 'Progress & CircularProgress',
          category: cat,
          description:
              'Linear and circular progress indicators for asynchronous operations.',
          usageNotes:
              'Use shadcn.Progress for file uploads, report generation, or sync progress.',
          dartCode: '''
shadcn.Progress(
  progress: _progressValue / 100,
)''',
          preview: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 320),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Batch Ledger Sync:',
                        style: AppTypography.caption(context),
                      ),
                    ),
                    Text(
                      '${_progressValue.round()}%',
                      style: AppTypography.numericValue(context),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                shadcn.Progress(progress: _progressValue / 100),
              ],
            ),
          ),
          controls: shadcn.PrimaryButton(
            onPressed: () {
              setState(() {
                _progressValue = (_progressValue + 15) % 105;
              });
            },
            child: const Text('Simulate Progress'),
          ),
        ),
      );
    }

    // 4. Skeleton Loader
    if (ctrl.isComponentMatching(
      'Skeleton',
      'Shimmer skeleton loader for async data fetching',
      cat,
    )) {
      cards.add(
        GalleryPreviewCard(
          name: 'Skeleton Loader',
          category: cat,
          description:
              'Placeholder shimmer skeleton primitives for loading data states.',
          usageNotes:
              'Use skeleton placeholder shapes while fetching ledger tables or detail views.',
          dartCode: '''
Container(
  width: 220,
  height: 18,
  decoration: BoxDecoration(color: AppColors.mutedTextLight.withValues(alpha: 0.2)),
)''',
          preview: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 320),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 220,
                  height: 18,
                  decoration: BoxDecoration(
                    color: AppColors.mutedTextLight.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Container(
                  width: 280,
                  height: 14,
                  decoration: BoxDecoration(
                    color: AppColors.mutedTextLight.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Container(
                  width: 140,
                  height: 14,
                  decoration: BoxDecoration(
                    color: AppColors.mutedTextLight.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Column(
      children: cards
          .map(
            (card) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: card,
            ),
          )
          .toList(),
    );
  }
}
