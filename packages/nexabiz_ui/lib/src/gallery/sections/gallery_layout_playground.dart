import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;
import '../../../nexabiz_ui.dart';
import '../gallery_preview_card.dart';

class GalleryLayoutPlayground extends StatefulWidget {
  final GalleryStateController controller;

  const GalleryLayoutPlayground({super.key, required this.controller});

  @override
  State<GalleryLayoutPlayground> createState() =>
      _GalleryLayoutPlaygroundState();
}

class _GalleryLayoutPlaygroundState extends State<GalleryLayoutPlayground> {
  bool _collapsibleOpen = false;

  @override
  Widget build(BuildContext context) {
    final cat = GalleryCategory.layout;
    final ctrl = widget.controller;

    final cards = <Widget>[];

    // 1. Card & SurfaceCard
    if (ctrl.isComponentMatching(
      'Card',
      'Container card and surface wrapper primitives',
      cat,
    )) {
      cards.add(
        GalleryPreviewCard(
          name: 'Card & SurfaceCard',
          category: cat,
          description:
              'Standardized surface containers for grouping controls and content sections.',
          usageNotes:
              'Use AppCard and AppSurface for consistent elevation and padding.',
          dartCode: '''
AppCard(
  child: Column(
    children: [
      Text('Card Title'),
      Text('Content body text...'),
    ],
  ),
)''',
          preview: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 340),
            child: AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: AppSpacing.xs,
                    runSpacing: AppSpacing.xs,
                    children: [
                      Text(
                        'General Ledger Card',
                        style: AppTypography.bodyBold(context),
                      ),
                      const AppStatusBadge(
                        label: 'Active',
                        tone: AppStatusTone.success,
                        animate: false,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Real-time transaction posting engine connected to financial capability registry.',
                    style: AppTypography.caption(context),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    // 2. Accordion & Collapsible
    if (ctrl.isComponentMatching(
      'Accordion / Collapsible',
      'Expandable content panel container',
      cat,
    )) {
      cards.add(
        GalleryPreviewCard(
          name: 'Accordion / Collapsible',
          category: cat,
          description: 'Expandable/collapsible content containers.',
          usageNotes:
              'Use for expandable form sections or FAQ accordion panels.',
          dartCode: '''
shadcn.Collapsible(
  open: _collapsibleOpen,
  onOpenChanged: (open) {},
  header: Text('Tax Configuration'),
  children: [Text('VAT Rate: 15%')],
)''',
          preview: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 340),
            child: AppCard(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'Tax Settings & VAT Rates',
                          style: AppTypography.bodyBold(context),
                        ),
                      ),
                      shadcn.GhostButton(
                        onPressed: () => setState(
                          () => _collapsibleOpen = !_collapsibleOpen,
                        ),
                        child: Icon(
                          _collapsibleOpen
                              ? AppIcons.chevronUp
                              : AppIcons.chevronDown,
                          size: 16,
                        ),
                      ),
                    ],
                  ),
                  if (_collapsibleOpen) ...[
                    const AppDivider(),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Standard VAT Rate: 15.0% • Tax Registration Number: 300129048100003',
                      style: AppTypography.caption(context),
                    ),
                  ],
                ],
              ),
            ),
          ),
          controls: Row(
            children: [
              AppSwitch(
                value: _collapsibleOpen,
                onChanged: (val) => setState(() => _collapsibleOpen = val),
              ),
              const SizedBox(width: AppSpacing.xs),
              const Flexible(child: Text('Expanded State')),
            ],
          ),
        ),
      );
    }

    // 3. Resizable Panels
    if (ctrl.isComponentMatching(
      'Resizable',
      'Resizable split view panel containers',
      cat,
    )) {
      cards.add(
        GalleryPreviewCard(
          name: 'Resizable Panels',
          category: cat,
          description: 'Split container with drag-to-resize divider.',
          usageNotes:
              'Use for master-detail split views and side-by-side transaction views.',
          dartCode: '''
shadcn.ResizablePanelGroup(
  direction: Axis.horizontal,
  children: [
    shadcn.ResizablePanel(child: Text('Navigation Master')),
    shadcn.ResizablePanel(child: Text('Transaction Detail')),
  ],
)''',
          preview: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: SizedBox(
              height: 120,
              child: AppSurface(
                padding: const EdgeInsets.all(AppSpacing.xs),
                child: Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Container(
                        color: AppColors.primaryBlue.withValues(alpha: 0.1),
                        child: Center(
                          child: Text(
                            'Left Pane (30%)',
                            style: AppTypography.caption(context),
                          ),
                        ),
                      ),
                    ),
                    const AppDivider(),
                    Expanded(
                      flex: 2,
                      child: Container(
                        color: AppColors.secondaryTeal.withValues(alpha: 0.1),
                        child: Center(
                          child: Text(
                            'Main Content Pane (70%)',
                            style: AppTypography.caption(context),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    // 4. Timeline
    if (ctrl.isComponentMatching(
      'Timeline',
      'Sequential step or transaction audit trail timeline',
      cat,
    )) {
      cards.add(
        GalleryPreviewCard(
          name: 'Timeline',
          category: cat,
          description:
              'Sequential event timeline for audit logs and document tracking.',
          usageNotes:
              'Use for invoice status progression or approval workflow history.',
          dartCode: '''
shadcn.Timeline(
  children: [
    shadcn.TimelineItem(title: Text('Voucher Drafted')),
    shadcn.TimelineItem(title: Text('Supervisor Approved')),
    shadcn.TimelineItem(title: Text('Ledger Posted')),
  ],
)''',
          preview: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 320),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTimelineNode(
                  context,
                  '1. Invoice Drafted',
                  'Created by Hosam • 09:15 AM',
                  isDone: true,
                ),
                _buildTimelineNode(
                  context,
                  '2. Supervisor Signature',
                  'Approved by Financial Controller • 10:30 AM',
                  isDone: true,
                ),
                _buildTimelineNode(
                  context,
                  '3. Treasury Settlement',
                  'Pending bank confirmation',
                  isDone: false,
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

  Widget _buildTimelineNode(
    BuildContext context,
    String title,
    String subtitle, {
    required bool isDone,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        children: [
          Icon(
            isDone ? AppIcons.check : AppIcons.chevronRight,
            size: 16,
            color: isDone ? AppColors.success : AppColors.mutedTextLight,
          ),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: isDone
                      ? AppTypography.bodyBold(context)
                      : AppTypography.body(context),
                ),
                Text(subtitle, style: AppTypography.caption(context)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
