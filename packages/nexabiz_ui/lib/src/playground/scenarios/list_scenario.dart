import 'package:flutter/material.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

import '../../theme/tokens/tokens.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_empty_state.dart';
import '../../widgets/app_error_state.dart';
import '../../widgets/app_loading.dart';
import '../../widgets/app_status_badge.dart';
import '../../widgets/app_text_field.dart';
import '../playground_demo_models.dart';

enum ListDemoState { normal, loading, empty, error }

class ListScenario extends StatefulWidget {
  const ListScenario({super.key, required this.isArabic, this.onSelectVoucher});

  final bool isArabic;
  final ValueChanged<DemoVoucherItem>? onSelectVoucher;

  @override
  State<ListScenario> createState() => _ListScenarioState();
}

class _ListScenarioState extends State<ListScenario> {
  String _searchQuery = '';
  String _selectedFilter = 'all';
  ListDemoState _currentDemoState = ListDemoState.normal;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isAr = widget.isArabic;
    final theme = shadcn.Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Simulation controls
          Row(
            children: [
              Text(
                isAr ? 'حالة القائمة:' : 'List State:',
                style: theme.typography.small.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.mutedForeground,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildStateChip(
                        ListDemoState.normal,
                        isAr ? 'طبيعي' : 'Normal',
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      _buildStateChip(
                        ListDemoState.loading,
                        isAr ? 'تحميل' : 'Loading',
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      _buildStateChip(
                        ListDemoState.empty,
                        isAr ? 'فارغ' : 'Empty',
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      _buildStateChip(
                        ListDemoState.error,
                        isAr ? 'خطأ' : 'Error',
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          // 2. Search Field
          AppTextField(
            controller: _searchController,
            hint: isAr
                ? 'بحث برقم السند أو الحساب...'
                : 'Search voucher # or account...',
            prefixIcon: Icon(
              shadcn.LucideIcons.search,
              size: 16,
              color: colorScheme.mutedForeground,
            ),
            onChanged: (val) {
              setState(() {
                _searchQuery = val;
              });
            },
          ),

          const SizedBox(height: AppSpacing.sm),

          // 3. Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('all', isAr ? 'الكل' : 'All'),
                const SizedBox(width: AppSpacing.xs),
                _buildFilterChip('posted', isAr ? 'مرحل' : 'Posted'),
                const SizedBox(width: AppSpacing.xs),
                _buildFilterChip('pending', isAr ? 'قيد الاعتماد' : 'Pending'),
                const SizedBox(width: AppSpacing.xs),
                _buildFilterChip('draft', isAr ? 'مسودة' : 'Draft'),
                const SizedBox(width: AppSpacing.xs),
                _buildFilterChip('voided', isAr ? 'ملغى' : 'Void'),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          // 4. Content based on current demo state
          _buildListBody(context),
        ],
      ),
    );
  }

  Widget _buildStateChip(ListDemoState state, String label) {
    final isSelected = _currentDemoState == state;
    final theme = shadcn.Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: () => setState(() => _currentDemoState = state),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: 4,
        ),
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.primary : colorScheme.secondary,
          borderRadius: AppRadii.radiusPill,
        ),
        child: Text(
          label,
          style: theme.typography.small.copyWith(
            color: isSelected
                ? colorScheme.primaryForeground
                : colorScheme.secondaryForeground,
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String key, String label) {
    final isSelected = _selectedFilter == key;
    final theme = shadcn.Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = key),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.primary : colorScheme.muted,
          borderRadius: AppRadii.radiusPill,
          border: Border.all(
            color: isSelected ? colorScheme.primary : colorScheme.border,
          ),
        ),
        child: Text(
          label,
          style: theme.typography.small.copyWith(
            color: isSelected
                ? colorScheme.primaryForeground
                : colorScheme.foreground,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildListBody(BuildContext context) {
    final isAr = widget.isArabic;

    switch (_currentDemoState) {
      case ListDemoState.loading:
        return const SizedBox(
          height: 280,
          child: AppLoading(
            style: AppLoadingStyle.skeletonList,
            skeletonItemCount: 4,
          ),
        );
      case ListDemoState.empty:
        return AppEmptyState(
          title: isAr ? 'لا توجد سندات مطابقة' : 'No matching vouchers',
          subtitle: isAr
              ? 'جرّب تغيير كلمات البحث أو المرشحات لعرض السندات.'
              : 'Try changing your search terms or filters to view vouchers.',
          actionLabel: isAr ? 'إعادة التعيين' : 'Reset Filters',
          onAction: () {
            setState(() {
              _searchQuery = '';
              _selectedFilter = 'all';
              _searchController.clear();
              _currentDemoState = ListDemoState.normal;
            });
          },
        );
      case ListDemoState.error:
        return AppErrorState(
          title: isAr
              ? 'فشل تحميل بيانات السندات'
              : 'Failed to load voucher records',
          message: isAr
              ? 'تعذر الاتصال بخادم دفتر الأستاذ. يرجى التحقق والمحاولة ثانية.'
              : 'Unable to connect to the ledger service. Please verify and retry.',
          retryLabel: isAr ? 'إعادة المحاولة' : 'Retry',
          onRetry: () {
            setState(() {
              _currentDemoState = ListDemoState.normal;
            });
          },
        );
      case ListDemoState.normal:
        return _buildVoucherItems(context);
    }
  }

  Widget _buildVoucherItems(BuildContext context) {
    final isAr = widget.isArabic;
    final allItems = PlaygroundFixtures.vouchers;

    final filtered = allItems.where((v) {
      if (_selectedFilter != 'all' && v.status.name != _selectedFilter) {
        return false;
      }
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final matchCode = v.referenceNumber.toLowerCase().contains(q);
        final matchTitle = v.title(isAr).toLowerCase().contains(q);
        final matchSub = v.subtitle(isAr).toLowerCase().contains(q);
        if (!matchCode && !matchTitle && !matchSub) return false;
      }
      return true;
    }).toList();

    if (filtered.isEmpty) {
      return AppEmptyState(
        title: isAr ? 'لا توجد نتائج' : 'No records found',
        subtitle: isAr
            ? 'لم يتم العثور على سندات تطابق البحث المحدد.'
            : 'No vouchers match the active filters.',
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: filtered.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (context, index) {
        final item = filtered[index];
        return _buildVoucherCard(context, item, isAr);
      },
    );
  }

  Widget _buildVoucherCard(
    BuildContext context,
    DemoVoucherItem item,
    bool isAr,
  ) {
    final theme = shadcn.Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isNegative = item.amount < 0;

    AppStatusTone tone;
    switch (item.status) {
      case DemoVoucherStatus.posted:
        tone = AppStatusTone.success;
        break;
      case DemoVoucherStatus.pending:
        tone = AppStatusTone.warning;
        break;
      case DemoVoucherStatus.draft:
        tone = AppStatusTone.neutral;
        break;
      case DemoVoucherStatus.voided:
        tone = AppStatusTone.error;
        break;
    }

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: InkWell(
        onTap: () {
          widget.onSelectVoucher?.call(item);
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Row 1: Reference + Badge + Date
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: AppSpacing.xs,
                    runSpacing: 2,
                    children: [
                      Text(
                        item.referenceNumber,
                        style: theme.typography.p.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                      AppStatusBadge(label: item.statusLabel(isAr), tone: tone),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  item.date,
                  style: theme.typography.small.copyWith(
                    color: colorScheme.mutedForeground,
                    fontSize: 11,
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.xs),

            // Row 2: Title & Subtitle
            Text(
              item.title(isAr),
              style: theme.typography.small.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.foreground,
                fontSize: 13,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              item.subtitle(isAr),
              style: theme.typography.small.copyWith(
                color: colorScheme.mutedForeground,
                fontSize: 12,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: AppSpacing.sm),

            // Row 3: Branch Tag & Tabular Amount
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.muted,
                      borderRadius: BorderRadius.circular(AppRadii.xs),
                    ),
                    child: Text(
                      item.branch(isAr),
                      style: theme.typography.small.copyWith(
                        color: colorScheme.mutedForeground,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                Flexible(
                  child: Text(
                    '${item.amount.toStringAsFixed(2)} ${item.currency}',
                    style: AppTypography.numericValue(context).copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: isNegative
                          ? colorScheme.destructive
                          : colorScheme.foreground,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: isAr ? TextAlign.left : TextAlign.right,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
