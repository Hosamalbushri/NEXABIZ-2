import 'package:flutter/material.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

import '../../theme/tokens/tokens.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_date_field.dart';
import '../../widgets/app_select_field.dart';
import '../../widgets/app_number_field.dart';

class FiltersScenario extends StatefulWidget {
  const FiltersScenario({super.key, required this.isArabic});

  final bool isArabic;

  @override
  State<FiltersScenario> createState() => _FiltersScenarioState();
}

class _FiltersScenarioState extends State<FiltersScenario> {
  final Set<String> _selectedStatuses = {'posted', 'draft'};
  DateTime? _fromDate = DateTime(2026, 3, 1);
  DateTime? _toDate = DateTime(2026, 3, 31);
  double _minAmount = 0.0;
  double _maxAmount = 50000.0;
  String _currency = 'SAR';

  void _resetFilters() {
    setState(() {
      _selectedStatuses
        ..clear()
        ..addAll(['posted', 'draft']);
      _fromDate = DateTime(2026, 3, 1);
      _toDate = DateTime(2026, 3, 31);
      _minAmount = 0.0;
      _maxAmount = 50000.0;
      _currency = 'SAR';
    });
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
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  isAr ? 'مرشحات متقدمة' : 'Advanced Filters',
                  style: theme.typography.h3.copyWith(
                    fontFamily: AppTypography.fontFamilyName,
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              GestureDetector(
                onTap: _resetFilters,
                child: Text(
                  isAr ? 'إعادة ضبط الكل' : 'Reset All',
                  style: theme.typography.small.copyWith(
                    color: colorScheme.destructive,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),

          // Active Filter Chips Summary
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: [
              ..._selectedStatuses.map((s) {
                return _buildFilterChip(
                  label: s.toUpperCase(),
                  onRemove: () => setState(() => _selectedStatuses.remove(s)),
                );
              }),
              _buildFilterChip(
                label: '>= ${_minAmount.toStringAsFixed(0)} $currencyLabel',
                onRemove: () => setState(() => _minAmount = 0),
              ),
              _buildFilterChip(
                label: '<= ${_maxAmount.toStringAsFixed(0)} $currencyLabel',
                onRemove: () => setState(() => _maxAmount = 100000),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          // 1. Status Filter Section
          _buildCardSection(
            title: isAr ? 'حالة القيد / السند' : 'Voucher Status',
            children: [
              Wrap(
                spacing: AppSpacing.xs,
                runSpacing: AppSpacing.xs,
                children: [
                  _buildStatusCheckbox(
                    'draft',
                    isAr ? 'مسودة (Draft)' : 'Draft',
                  ),
                  _buildStatusCheckbox(
                    'posted',
                    isAr ? 'مرحل (Posted)' : 'Posted',
                  ),
                  _buildStatusCheckbox(
                    'pending',
                    isAr ? 'قيد الاعتماد' : 'Pending',
                  ),
                  _buildStatusCheckbox('voided', isAr ? 'ملغى (Void)' : 'Void'),
                ],
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          // 2. Date Range Section
          _buildCardSection(
            title: isAr ? 'الفترة الزمنية' : 'Date Range',
            children: [
              Row(
                children: [
                  Expanded(
                    child: AppDateField(
                      label: isAr ? 'من تاريخ' : 'From Date',
                      value: _fromDate,
                      onChanged: (d) => setState(() => _fromDate = d),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: AppDateField(
                      label: isAr ? 'إلى تاريخ' : 'To Date',
                      value: _toDate,
                      onChanged: (d) => setState(() => _toDate = d),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              // Presets
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildPresetButton(isAr ? 'اليوم' : 'Today', () {
                      final now = DateTime.now();
                      setState(() {
                        _fromDate = now;
                        _toDate = now;
                      });
                    }),
                    const SizedBox(width: AppSpacing.xs),
                    _buildPresetButton(isAr ? 'هذا الشهر' : 'This Month', () {
                      final now = DateTime.now();
                      setState(() {
                        _fromDate = DateTime(now.year, now.month, 1);
                        _toDate = DateTime(now.year, now.month + 1, 0);
                      });
                    }),
                    const SizedBox(width: AppSpacing.xs),
                    _buildPresetButton(
                      isAr ? 'الربع الأول' : 'Q1 (Jan-Mar)',
                      () {
                        setState(() {
                          _fromDate = DateTime(2026, 1, 1);
                          _toDate = DateTime(2026, 3, 31);
                        });
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          // 3. Amount Range Section
          _buildCardSection(
            title: isAr ? 'نطاق المبلغ المالي' : 'Amount Range',
            children: [
              Row(
                children: [
                  Expanded(
                    child: AppNumberField(
                      label: isAr ? 'الحد الأدنى' : 'Min Amount',
                      value: _minAmount,
                      onChanged: (v) =>
                          setState(() => _minAmount = (v ?? 0).toDouble()),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: AppNumberField(
                      label: isAr ? 'الحد الأقصى' : 'Max Amount',
                      value: _maxAmount,
                      onChanged: (v) =>
                          setState(() => _maxAmount = (v ?? 0).toDouble()),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              AppSelectField<String>(
                label: isAr ? 'عملة التصفية' : 'Currency Filter',
                value: _currency,
                items: const [
                  AppSelectOption(value: 'SAR', label: 'SAR (Saudi Riyal)'),
                  AppSelectOption(value: 'USD', label: 'USD (US Dollar)'),
                  AppSelectOption(value: 'EUR', label: 'EUR (Euro)'),
                ],
                onChanged: (v) {
                  if (v != null) setState(() => _currency = v);
                },
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.lg),

          // Apply Button
          AppButton(
            label: isAr
                ? 'تطبيق المرشحات (١٤ نتيجة)'
                : 'Apply Filters (14 results)',
            variant: AppButtonVariant.filled,
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    isAr
                        ? 'تم تطبيق معايير التصفية المحددة!'
                        : 'Filters applied successfully!',
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  String get currencyLabel => _currency;

  Widget _buildCardSection({
    required String title,
    required List<Widget> children,
  }) {
    final theme = shadcn.Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: theme.typography.p.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 13,
              color: colorScheme.foreground,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          ...children,
        ],
      ),
    );
  }

  Widget _buildStatusCheckbox(String statusKey, String label) {
    final isSelected = _selectedStatuses.contains(statusKey);
    final theme = shadcn.Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            _selectedStatuses.remove(statusKey);
          } else {
            _selectedStatuses.add(statusKey);
          }
        });
      },
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
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildPresetButton(String label, VoidCallback onTap) {
    final theme = shadcn.Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: 4,
        ),
        decoration: BoxDecoration(
          color: colorScheme.secondary,
          borderRadius: BorderRadius.circular(AppRadii.xs),
          border: Border.all(color: colorScheme.border),
        ),
        child: Text(
          label,
          style: theme.typography.small.copyWith(
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required VoidCallback onRemove,
  }) {
    final theme = shadcn.Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: AppRadii.radiusPill,
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: theme.typography.small.copyWith(
              color: colorScheme.primary,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child: Icon(
              shadcn.LucideIcons.x,
              size: 12,
              color: colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}
