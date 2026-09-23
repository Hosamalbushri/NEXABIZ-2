import 'package:flutter/material.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

import '../../theme/tokens/tokens.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_empty_state.dart';
import '../../widgets/app_status_badge.dart';
import '../../widgets/app_text_field.dart';
import '../playground_demo_models.dart';

class SearchScenario extends StatefulWidget {
  const SearchScenario({super.key, required this.isArabic});

  final bool isArabic;

  @override
  State<SearchScenario> createState() => _SearchScenarioState();
}

class _SearchScenarioState extends State<SearchScenario> {
  final TextEditingController _controller = TextEditingController();
  String _query = '';
  final List<String> _recentSearches = [
    'JV-2026-001',
    'Al-Noor',
    '101001',
    'Petty Cash',
    'موردين',
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _applySearch(String term) {
    _controller.text = term;
    setState(() {
      _query = term;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isAr = widget.isArabic;
    final theme = shadcn.Theme.of(context);
    final colorScheme = theme.colorScheme;
    final allVouchers = PlaygroundFixtures.vouchers;

    final results = _query.isEmpty
        ? <DemoVoucherItem>[]
        : allVouchers.where((v) {
            final q = _query.toLowerCase();
            return v.referenceNumber.toLowerCase().contains(q) ||
                v.title(isAr).toLowerCase().contains(q) ||
                v.subtitle(isAr).toLowerCase().contains(q);
          }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Search Toolbar
          Row(
            children: [
              Expanded(
                child: AppTextField(
                  controller: _controller,
                  hint: isAr
                      ? 'بحث برقم السند، الطرف، أو الحساب...'
                      : 'Search voucher, party, or account...',
                  prefixIcon: Icon(
                    shadcn.LucideIcons.search,
                    size: 16,
                    color: colorScheme.mutedForeground,
                  ),
                  suffixIcon: _query.isNotEmpty
                      ? GestureDetector(
                          onTap: () {
                            _controller.clear();
                            setState(() => _query = '');
                          },
                          child: Icon(
                            shadcn.LucideIcons.x,
                            size: 16,
                            color: colorScheme.mutedForeground,
                          ),
                        )
                      : null,
                  onChanged: (v) => setState(() => _query = v),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          // 2. Recent Searches (when query is empty)
          if (_query.isEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isAr ? 'عمليات البحث الأخيرة' : 'Recent Searches',
                  style: theme.typography.small.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.mutedForeground,
                    fontSize: 12,
                  ),
                ),
                GestureDetector(
                  onTap: () => setState(() => _recentSearches.clear()),
                  child: Text(
                    isAr ? 'مسح الكل' : 'Clear All',
                    style: theme.typography.small.copyWith(
                      color: colorScheme.destructive,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: _recentSearches.map((term) {
                return GestureDetector(
                  onTap: () => _applySearch(term),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.muted,
                      borderRadius: AppRadii.radiusPill,
                      border: Border.all(color: colorScheme.border),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          shadcn.LucideIcons.clock,
                          size: 12,
                          color: colorScheme.mutedForeground,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          term,
                          style: theme.typography.small.copyWith(fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: AppSpacing.lg),
            // Quick categories
            Text(
              isAr ? 'استكشاف سريع' : 'Quick Explore',
              style: theme.typography.small.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.mutedForeground,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            _buildExploreRow(
              shadcn.LucideIcons.fileSpreadsheet,
              isAr ? 'سندات اليوم' : "Today's Vouchers",
              '3',
            ),
            const SizedBox(height: AppSpacing.xs),
            _buildExploreRow(
              shadcn.LucideIcons.triangleAlert,
              isAr ? 'قيود غير متوازنة معلقة' : 'Pending Unbalanced',
              '0',
            ),
            const SizedBox(height: AppSpacing.xs),
            _buildExploreRow(
              shadcn.LucideIcons.users,
              isAr ? 'حسابات العملاء النشطة' : 'Active Customer Accounts',
              '14',
            ),
          ] else if (results.isEmpty) ...[
            // Empty search result
            AppEmptyState(
              icon: shadcn.LucideIcons.searchX,
              title: isAr ? 'لا توجد نتائج مطابقة' : 'No matching results',
              subtitle: isAr
                  ? 'لم يتم العثور على أي نتائج لكلمة "$_query". تحقق من الإملاء وحاول ثانية.'
                  : 'No entries matched "$_query". Check your spelling and try again.',
            ),
          ] else ...[
            // Search Results List
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isAr
                      ? 'النتائج (${results.length})'
                      : 'Results (${results.length})',
                  style: theme.typography.small.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.mutedForeground,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: results.length,
              separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
              itemBuilder: (context, index) {
                final item = results[index];
                return AppCard(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(AppRadii.sm),
                        ),
                        alignment: Alignment.center,
                        child: Icon(
                          shadcn.LucideIcons.fileText,
                          size: 18,
                          color: colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.referenceNumber,
                              style: theme.typography.p.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            Text(
                              item.title(isAr),
                              style: theme.typography.small.copyWith(
                                color: colorScheme.foreground,
                                fontSize: 12,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              item.subtitle(isAr),
                              style: theme.typography.small.copyWith(
                                color: colorScheme.mutedForeground,
                                fontSize: 11,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${item.amount.toStringAsFixed(2)} ${item.currency}',
                            style: AppTypography.numericValue(context).copyWith(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 2),
                          AppStatusBadge(
                            label: item.statusLabel(isAr),
                            tone: item.status == DemoVoucherStatus.posted
                                ? AppStatusTone.success
                                : (item.status == DemoVoucherStatus.pending
                                      ? AppStatusTone.warning
                                      : AppStatusTone.neutral),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildExploreRow(IconData icon, String title, String count) {
    final theme = shadcn.Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AppCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: colorScheme.primary),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              title,
              style: theme.typography.small.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: colorScheme.muted,
              borderRadius: AppRadii.radiusPill,
            ),
            child: Text(
              count,
              style: theme.typography.small.copyWith(
                fontSize: 11,
                color: colorScheme.mutedForeground,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
