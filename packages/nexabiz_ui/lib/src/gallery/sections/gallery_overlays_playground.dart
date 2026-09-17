import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;
import '../../../nexabiz_ui.dart';
import '../gallery_preview_card.dart';

class GalleryOverlaysPlayground extends StatefulWidget {
  final GalleryStateController controller;

  const GalleryOverlaysPlayground({super.key, required this.controller});

  @override
  State<GalleryOverlaysPlayground> createState() => _GalleryOverlaysPlaygroundState();
}

class _GalleryOverlaysPlaygroundState extends State<GalleryOverlaysPlayground> {
  String _sheetResult = 'No action selected';

  @override
  Widget build(BuildContext context) {
    final cat = GalleryCategory.overlays;
    final ctrl = widget.controller;

    final cards = <Widget>[];

    // 1. Bottom Sheet / Drawer Playground (shadcn_flutter native openDrawerOverlay)
    if (ctrl.isComponentMatching('Sheet / Drawer', 'Bottom sheet and slide-over drawer overlay primitive', cat)) {
      cards.add(
        GalleryPreviewCard(
          name: 'Bottom Sheet / Drawer (shadcn_flutter native)',
          category: cat,
          description: 'Native shadcn_flutter drawer overlay supporting bottom sheet presentation, scrollable content, and form inputs.',
          usageNotes: 'Uses shadcn_flutter openDrawerOverlay. Absolutely NO Material showModalBottomSheet.',
          dartCode: '''
shadcn.openDrawerOverlay(
  context: context,
  position: shadcn.OverlayPosition.bottom,
  builder: (context) => Padding(
    padding: EdgeInsets.all(16),
    child: Column(
      children: [
        Text('Quick Ledger Voucher Actions'),
        shadcn.PrimaryButton(onPressed: () => Navigator.of(context).pop('Created Invoice'), child: Text('Confirm')),
      ],
    ),
  ),
);''',
          preview: Column(
            children: [
              Wrap(
                spacing: AppSpacing.xs,
                runSpacing: AppSpacing.xs,
                children: [
                  shadcn.PrimaryButton(
                    onPressed: () async {
                      final completer = shadcn.openDrawerOverlay<String>(
                        context: context,
                        position: shadcn.OverlayPosition.bottom,
                        builder: (context) {
                          return Padding(
                            padding: const EdgeInsets.all(AppSpacing.lg),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Quick Action Sheet', style: AppTypography.sectionTitle(context)),
                                    shadcn.GhostButton(
                                      onPressed: () => Navigator.of(context).pop('Closed Sheet'),
                                      child: const Icon(AppIcons.close, size: 16),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: AppSpacing.sm),
                                Text(
                                  'Select a quick capability transaction to initiate:',
                                  style: AppTypography.body(context),
                                ),
                                const SizedBox(height: AppSpacing.md),
                                AppListTile(
                                  leading: const Icon(AppIcons.receipt, color: AppColors.primaryBlue),
                                  title: const Text('Create Receipt Voucher'),
                                  subtitle: const Text('Receive customer payment into treasury'),
                                  onTap: () => Navigator.of(context).pop('Created Receipt Voucher'),
                                ),
                                const AppDivider(),
                                AppListTile(
                                  leading: const Icon(AppIcons.box, color: AppColors.secondaryTeal),
                                  title: const Text('Stock Transfer Order'),
                                  subtitle: const Text('Initiate inter-warehouse inventory dispatch'),
                                  onTap: () => Navigator.of(context).pop('Created Stock Transfer'),
                                ),
                                const SizedBox(height: AppSpacing.md),
                                shadcn.SecondaryButton(
                                  onPressed: () => Navigator.of(context).pop('Cancelled'),
                                  child: const Text('Cancel'),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                      final result = await completer.future;
                      if (result != null) {
                        setState(() => _sheetResult = result);
                      }
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(AppIcons.layers, size: 16),
                        SizedBox(width: 4),
                        Text('Open Bottom Sheet'),
                      ],
                    ),
                  ),
                  shadcn.OutlineButton(
                    onPressed: () async {
                      final completer = shadcn.openDrawerOverlay<String>(
                        context: context,
                        position: shadcn.OverlayPosition.right,
                        builder: (context) {
                          return SizedBox(
                            width: 320,
                            child: Padding(
                              padding: const EdgeInsets.all(AppSpacing.lg),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Filter Drawer', style: AppTypography.sectionTitle(context)),
                                  const SizedBox(height: AppSpacing.md),
                                  const AppTextField(label: 'Account Code', hint: '1001-00'),
                                  const SizedBox(height: AppSpacing.sm),
                                  const AppTextField(label: 'Currency', hint: 'USD'),
                                  const Spacer(),
                                  shadcn.PrimaryButton(
                                    onPressed: () => Navigator.of(context).pop('Filters Applied'),
                                    child: const Text('Apply Filters'),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                      final result = await completer.future;
                      if (result != null) {
                        setState(() => _sheetResult = result);
                      }
                    },
                    child: const Text('Open Right Drawer'),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              Text('Last Action Result: $_sheetResult', style: AppTypography.caption(context)),
            ],
          ),
        ),
      );
    }

    // 2. Dialog & AlertDialog Playground
    if (ctrl.isComponentMatching('Dialog / AlertDialog', 'Modal dialog overlay primitive', cat)) {
      cards.add(
        GalleryPreviewCard(
          name: 'Dialog / AlertDialog',
          category: cat,
          description: 'Native modal dialog overlay for confirmation actions and data prompts.',
          usageNotes: 'Use AppDialog.confirm for modal confirmations.',
          dartCode: '''
AppDialog.confirm(
  context: context,
  title: 'Post Voucher Confirmation',
  message: 'Are you sure you want to post voucher #RCV-1021?',
  confirmLabel: 'Confirm Post',
  onConfirm: () {},
);''',
          preview: shadcn.OutlineButton(
            onPressed: () {
              AppDialog.confirm(
                context: context,
                title: 'Confirm Journal Posting',
                message: 'Posting this voucher will permanently lock ledger entry #INV-2026-0042 and update general ledger balances.',
                confirmLabel: 'Post Ledger',
                onConfirm: () {},
              );
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(AppIcons.command, size: 16),
                SizedBox(width: 4),
                Text('Open Confirmation Dialog'),
              ],
            ),
          ),
        ),
      );
    }

    // 3. Popover & Tooltip
    if (ctrl.isComponentMatching('Popover / Tooltip', 'Contextual popup overlay and tooltip', cat)) {
      cards.add(
        GalleryPreviewCard(
          name: 'Popover & Tooltip',
          category: cat,
          description: 'Floating contextual popovers and tooltip hints.',
          usageNotes: 'Use Tooltip and Popover for inline field hints or popover controls.',
          dartCode: '''
shadcn.Tooltip(
  tooltip: (context) => const shadcn.TooltipContainer(
    child: Text('Functional currency code'),
  ),
  child: const Icon(AppIcons.info),
)''',
          preview: Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.xs,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              shadcn.Tooltip(
                tooltip: (context) => const shadcn.TooltipContainer(
                  child: Text('Functional currency used for General Ledger reporting'),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('USD Currency Info', style: AppTypography.body(context)),
                    const SizedBox(width: 4),
                    const Icon(AppIcons.info, size: 16, color: AppColors.primaryBlue),
                  ],
                ),
              ),
              shadcn.OutlineButton(
                onPressed: () {},
                child: const Text('Interactive Tooltip Active'),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: cards
          .map((card) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: card,
              ))
          .toList(),
    );
  }
}
