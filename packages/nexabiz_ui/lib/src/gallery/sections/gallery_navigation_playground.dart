import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;
import '../../../nexabiz_ui.dart';
import '../gallery_state_controller.dart';
import '../gallery_preview_card.dart';

class GalleryNavigationPlayground extends StatefulWidget {
  final GalleryStateController controller;

  const GalleryNavigationPlayground({super.key, required this.controller});

  @override
  State<GalleryNavigationPlayground> createState() =>
      _GalleryNavigationPlaygroundState();
}

class _GalleryNavigationPlaygroundState
    extends State<GalleryNavigationPlayground> {
  int _activeTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final cat = GalleryCategory.navigation;
    final ctrl = widget.controller;

    final cards = <Widget>[];

    // 1. Tabs
    if (ctrl.isComponentMatching(
      'Tabs',
      'Tabbed container navigation primitive',
      cat,
    )) {
      cards.add(
        GalleryPreviewCard(
          name: 'Tabs (TabContainer / TabList / TabPane)',
          category: cat,
          description: 'Tabbed navigation container primitive.',
          usageNotes:
              'Use for switching views (Overview, Ledger Items, Attachments, Audit Log).',
          dartCode: '''
shadcn.Tabs(
  index: _activeTabIndex,
  onChanged: (idx) {},
  tabs: [
    shadcn.Tab(child: Text('Overview')),
    shadcn.Tab(child: Text('Transactions')),
  ],
)''',
          preview: SizedBox(
            width: 340,
            child: AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: AppSpacing.xs,
                    runSpacing: AppSpacing.xs,
                    children: [
                      shadcn.GhostButton(
                        onPressed: () => setState(() => _activeTabIndex = 0),
                        child: Text(
                          'Overview',
                          style: _activeTabIndex == 0
                              ? AppTypography.bodyBold(context)
                              : AppTypography.body(context),
                        ),
                      ),
                      shadcn.GhostButton(
                        onPressed: () => setState(() => _activeTabIndex = 1),
                        child: Text(
                          'Ledger Entries',
                          style: _activeTabIndex == 1
                              ? AppTypography.bodyBold(context)
                              : AppTypography.body(context),
                        ),
                      ),
                    ],
                  ),
                  const AppDivider(),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    _activeTabIndex == 0
                        ? 'Overview Pane: Displays executive financial metrics and active ledger totals.'
                        : 'Ledger Entries Pane: Displays individual posted transactions and journal entries.',
                    style: AppTypography.caption(context),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    // 2. Breadcrumb
    if (ctrl.isComponentMatching(
      'Breadcrumb',
      'Hierarchy trail breadcrumb widget',
      cat,
    )) {
      cards.add(
        GalleryPreviewCard(
          name: 'Breadcrumb',
          category: cat,
          description:
              'Navigational breadcrumb trail representing page location.',
          usageNotes:
              'Use inside AppPageHeader for deep ERP navigation tracks.',
          dartCode: '''
shadcn.Breadcrumb(
  children: [
    Text('Financials'),
    Text('General Ledger'),
    Text('Chart of Accounts'),
  ],
)''',
          preview: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 4,
            runSpacing: 4,
            children: [
              Text('Financials', style: AppTypography.caption(context)),
              const Icon(AppIcons.chevronRight, size: 12),
              Text('General Ledger', style: AppTypography.caption(context)),
              const Icon(AppIcons.chevronRight, size: 12),
              Text('Chart of Accounts', style: AppTypography.label(context)),
            ],
          ),
        ),
      );
    }

    // 3. Pagination
    if (ctrl.isComponentMatching(
      'Pagination',
      'Page navigation control for multi-page data tables',
      cat,
    )) {
      cards.add(
        GalleryPreviewCard(
          name: 'Pagination',
          category: cat,
          description: 'Pagination control for navigating multi-page datasets.',
          usageNotes: 'Use for large ledger tables and item catalogs.',
          dartCode: '''
shadcn.Pagination(
  page: 1,
  totalPages: 12,
  onPageChanged: (p) {},
)''',
          preview: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: [
              shadcn.OutlineButton(
                density: shadcn.ButtonDensity.compact,
                onPressed: () {},
                child: const Icon(AppIcons.chevronLeft, size: 14),
              ),
              Text(
                'Page 1 of 12 (120 Records)',
                style: AppTypography.caption(context),
              ),
              shadcn.OutlineButton(
                density: shadcn.ButtonDensity.compact,
                onPressed: () {},
                child: const Icon(AppIcons.chevronRight, size: 14),
              ),
            ],
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
