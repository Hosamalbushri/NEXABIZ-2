import 'package:flutter/widgets.dart';
import '../../../nexabiz_ui.dart';
import '../gallery_preview_card.dart';

class GalleryDataPlayground extends StatefulWidget {
  final GalleryStateController controller;

  const GalleryDataPlayground({super.key, required this.controller});

  @override
  State<GalleryDataPlayground> createState() => _GalleryDataPlaygroundState();
}

class _GalleryDataPlaygroundState extends State<GalleryDataPlayground> {
  int _selectedRowIndex = 0;

  final List<Map<String, dynamic>> _ledgerRows = [
    {'voucher': 'RCV-2026-001', 'account': '1010 - Main Cash', 'debit': '\$4,500.00', 'credit': '\$0.00', 'status': 'Posted'},
    {'voucher': 'PAY-2026-014', 'account': '2010 - Accounts Payable', 'debit': '\$0.00', 'credit': '\$2,150.00', 'status': 'Approved'},
    {'voucher': 'JRN-2026-089', 'account': '4010 - Sales Revenue', 'debit': '\$0.00', 'credit': '\$8,900.00', 'status': 'Posted'},
    {'voucher': 'RCV-2026-002', 'account': '1020 - Treasury Bank', 'debit': '\$12,000.00', 'credit': '\$0.00', 'status': 'Draft'},
  ];

  @override
  Widget build(BuildContext context) {
    final cat = GalleryCategory.dataDisplay;
    final ctrl = widget.controller;

    final cards = <Widget>[];

    // 1. Table Playground (Accounting / Ledger Data Table)
    if (ctrl.isComponentMatching('Table', 'Data table with headers, rows, and alignment', cat)) {
      cards.add(
        GalleryPreviewCard(
          name: 'Table / Data Grid',
          category: cat,
          description: 'Data grid table primitive for accounting ledgers and ERP reports.',
          usageNotes: 'Use Table with AppTypography.tableHeader and tableCell for financial statement grids.',
          dartCode: '''
shadcn.Table(
  rows: [
    shadcn.TableRow(
      cells: [
        shadcn.TableCell(child: Text('Voucher #')),
        shadcn.TableCell(child: Text('Account Name')),
        shadcn.TableCell(child: Text('Debit Amount')),
      ],
    ),
  ],
)''',
          preview: SizedBox(
            width: 480,
            child: AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  Container(
                    color: AppThemeController.isDark(context) ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                    child: Row(
                      children: [
                        Expanded(flex: 2, child: Text('Voucher #', style: AppTypography.tableHeader(context))),
                        Expanded(flex: 3, child: Text('Account', style: AppTypography.tableHeader(context))),
                        Expanded(flex: 2, child: Text('Debit', style: AppTypography.tableHeader(context))),
                        Expanded(flex: 2, child: Text('Status', style: AppTypography.tableHeader(context))),
                      ],
                    ),
                  ),
                  const AppDivider(),
                  ...List.generate(_ledgerRows.length, (index) {
                    final row = _ledgerRows[index];
                    final isSelected = index == _selectedRowIndex;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedRowIndex = index),
                      child: Container(
                        color: isSelected
                            ? (AppThemeController.isDark(context) ? const Color(0xFF334155) : const Color(0xFFE2E8F0))
                            : null,
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                        child: Row(
                          children: [
                            Expanded(flex: 2, child: Text(row['voucher'], style: AppTypography.tableCell(context))),
                            Expanded(flex: 3, child: Text(row['account'], style: AppTypography.tableCell(context))),
                            Expanded(flex: 2, child: Text(row['debit'], style: AppTypography.numericValue(context))),
                            Expanded(
                              flex: 2,
                              child: AppStatusBadge(
                                label: row['status'],
                                tone: row['status'] == 'Posted'
                                    ? AppStatusTone.success
                                    : (row['status'] == 'Approved' ? AppStatusTone.info : AppStatusTone.neutral),
                                animate: false,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
          controls: Text(
            'Selected Voucher: ${_ledgerRows[_selectedRowIndex]['voucher']} (${_ledgerRows[_selectedRowIndex]['account']})',
            style: AppTypography.caption(context),
          ),
        ),
      );
    }

    // 2. CodeSnippet / CodeBlock
    if (ctrl.isComponentMatching('CodeSnippet', 'Syntax highlighted code display primitive', cat)) {
      cards.add(
        GalleryPreviewCard(
          name: 'CodeSnippet / CodeBlock',
          category: cat,
          description: 'Syntax-highlighted code block component.',
          usageNotes: 'Use AppCard code container for API responses, formula previews, and audit code.',
          dartCode: '''
AppCard(
  child: Text('final ledger = NexaBizLedger();'),
)''',
          preview: SizedBox(
            width: 320,
            child: AppCard(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Text(
                '''
// NexaBiz General Ledger Posting Example
final voucher = ReceiptVoucher(
  id: "RCV-2026-001",
  amount: 4500.00,
  currency: "USD",
);
await ledger.postTransaction(voucher);''',
                style: AppTypography.codeSnippet(context),
              ),
            ),
          ),
        ),
      );
    }

    // 3. Carousel
    if (ctrl.isComponentMatching('Carousel', 'Smooth sliding carousel widget', cat)) {
      cards.add(
        GalleryPreviewCard(
          name: 'Carousel',
          category: cat,
          description: 'Sliding carousel for highlight banners and KPI metric summary slides.',
          usageNotes: 'Use AppCarousel on executive dashboard screens.',
          dartCode: '''
AppCarousel<String>(
  items: ['Slide 1', 'Slide 2'],
  height: 120,
  itemBuilder: (context, item, index) => AppSurface(child: Text(item)),
)''',
          preview: SizedBox(
            width: 320,
            child: AppCarousel<String>(
              items: const [
                'Q3 Revenue Target Reached (+18.4%)',
                'Tax Audit Clearance Verified',
                'Treasury Bank Balance: \$1,240,500',
              ],
              height: 100,
              autoplay: false,
              itemBuilder: (context, item, index) {
                return AppSurface(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const AppStatusBadge(label: 'Executive Insight', tone: AppStatusTone.info, animate: false),
                      const SizedBox(height: AppSpacing.xs),
                      Text(item, style: AppTypography.bodyBold(context)),
                    ],
                  ),
                );
              },
            ),
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
