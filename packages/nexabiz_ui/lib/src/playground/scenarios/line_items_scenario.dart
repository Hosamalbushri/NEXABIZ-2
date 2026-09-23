import 'package:flutter/material.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

import '../../theme/tokens/tokens.dart';
import '../../widgets/app_bottom_sheet.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_dropdown.dart';
import '../../widgets/app_number_field.dart';
import '../../widgets/app_status_badge.dart';
import '../../widgets/app_surface.dart';
import '../../widgets/app_text_field.dart';
import '../playground_demo_models.dart';

class LineItemsScenario extends StatefulWidget {
  const LineItemsScenario({super.key, required this.isArabic});

  final bool isArabic;

  @override
  State<LineItemsScenario> createState() => _LineItemsScenarioState();
}

class _LineItemsScenarioState extends State<LineItemsScenario> {
  late List<DemoJournalLine> _lines;

  @override
  void initState() {
    super.initState();
    _lines = List.from(PlaygroundFixtures.initialLines);
  }

  void _addLine(DemoJournalLine line) {
    setState(() {
      _lines.add(line);
    });
  }

  void _removeLine(int index) {
    setState(() {
      _lines.removeAt(index);
    });
  }

  void _openAddLineModal(BuildContext context) {
    final isAr = widget.isArabic;
    final accounts = PlaygroundFixtures.accounts;
    String selectedAccountCode = accounts.first.code;
    bool isDebit = true;
    double amount = 1000.0;
    final descController = TextEditingController();

    AppBottomSheet.show<void>(
      context: context,
      title: isAr ? 'إضافة بند قيد جديد' : 'Add Journal Line',
      child: StatefulBuilder(
        builder: (modalCtx, setModalState) {
          final theme = shadcn.Theme.of(modalCtx);
          final colorScheme = theme.colorScheme;

          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppDropdown<String>(
                label: isAr ? 'الحساب' : 'Account',
                value: selectedAccountCode,
                items: accounts.map((a) {
                  return AppDropdownItem(
                    value: a.code,
                    label: '${a.code} - ${a.name(isAr)}',
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setModalState(() => selectedAccountCode = val);
                  }
                },
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setModalState(() => isDebit = true),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: isDebit
                              ? colorScheme.primary
                              : colorScheme.muted,
                          borderRadius: BorderRadius.circular(AppRadii.xs),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          isAr ? 'مدين (Debit)' : 'Debit',
                          style: TextStyle(
                            color: isDebit
                                ? colorScheme.primaryForeground
                                : colorScheme.foreground,
                            fontWeight: isDebit
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setModalState(() => isDebit = false),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: !isDebit
                              ? colorScheme.primary
                              : colorScheme.muted,
                          borderRadius: BorderRadius.circular(AppRadii.xs),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          isAr ? 'دائن (Credit)' : 'Credit',
                          style: TextStyle(
                            color: !isDebit
                                ? colorScheme.primaryForeground
                                : colorScheme.foreground,
                            fontWeight: !isDebit
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              AppNumberField(
                label: isAr ? 'المبلغ' : 'Amount',
                value: amount,
                onChanged: (v) =>
                    setModalState(() => amount = (v ?? 0.0).toDouble()),
              ),
              const SizedBox(height: AppSpacing.sm),
              AppTextField(
                label: isAr ? 'البيان / الشرح' : 'Description',
                controller: descController,
                hint: isAr ? 'وصف البند...' : 'Line description...',
              ),
              const SizedBox(height: AppSpacing.lg),
              AppButton(
                label: isAr ? 'إضافة إلى القيد' : 'Add to Voucher',
                variant: AppButtonVariant.filled,
                onPressed: () {
                  final selectedAcc = accounts.firstWhere(
                    (a) => a.code == selectedAccountCode,
                  );
                  _addLine(
                    DemoJournalLine(
                      id: 'line-${DateTime.now().millisecondsSinceEpoch}',
                      accountCode: selectedAccountCode,
                      accountNameEn: selectedAcc.nameEn,
                      accountNameAr: selectedAcc.nameAr,
                      debit: isDebit ? amount : 0.0,
                      credit: !isDebit ? amount : 0.0,
                      descriptionEn: descController.text.isEmpty
                          ? 'Adjusting entry'
                          : descController.text,
                      descriptionAr: descController.text.isEmpty
                          ? 'قيد تسوية'
                          : descController.text,
                    ),
                  );
                  AppBottomSheet.close<void>(modalCtx);
                },
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isAr = widget.isArabic;
    final theme = shadcn.Theme.of(context);
    final colorScheme = theme.colorScheme;

    final totalDebit = _lines.fold<double>(0, (sum, l) => sum + l.debit);
    final totalCredit = _lines.fold<double>(0, (sum, l) => sum + l.credit);
    final diff = (totalDebit - totalCredit).abs();
    final isBalanced = diff < 0.001;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header + Add Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isAr ? 'بنود القيد المحاسبي' : 'Journal Lines',
                      style: theme.typography.h4.copyWith(
                        fontFamily: AppTypography.fontFamilyName,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      isAr
                          ? '${_lines.length} أسطر مسجلة'
                          : '${_lines.length} recorded lines',
                      style: theme.typography.small.copyWith(
                        color: colorScheme.mutedForeground,
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              AppButton(
                label: isAr ? 'إضافة سطر' : 'Add Line',
                icon: shadcn.LucideIcons.plus,
                isCompact: true,
                variant: AppButtonVariant.filled,
                onPressed: () => _openAddLineModal(context),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          // Financial Summary Dock Card
          AppSurface(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: _buildSummaryItem(
                        isAr ? 'إجمالي المدين' : 'Debit Total',
                        totalDebit,
                        colorScheme.primary,
                        context,
                      ),
                    ),
                    Expanded(
                      child: _buildSummaryItem(
                        isAr ? 'إجمالي الدائن' : 'Credit Total',
                        totalCredit,
                        colorScheme.foreground,
                        context,
                      ),
                    ),
                    Expanded(
                      child: _buildSummaryItem(
                        isAr ? 'الفرق' : 'Difference',
                        diff,
                        isBalanced
                            ? colorScheme.primary
                            : colorScheme.destructive,
                        context,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AppStatusBadge(
                      label: isBalanced
                          ? (isAr ? 'القيد متوازن تماماً' : 'Balanced Entry')
                          : (isAr
                                ? 'القيد غير متوازن: ${diff.toStringAsFixed(2)}'
                                : 'Unbalanced: ${diff.toStringAsFixed(2)}'),
                      tone: isBalanced
                          ? AppStatusTone.success
                          : AppStatusTone.error,
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          // List of Lines (Mobile Card Pattern)
          if (_lines.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Text(
                  isAr ? 'لا توجد أسطر في هذا القيد' : 'No lines added yet',
                  style: TextStyle(color: colorScheme.mutedForeground),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _lines.length,
              separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
              itemBuilder: (context, index) {
                final line = _lines[index];
                return _buildLineCard(context, line, index, isAr);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(
    String label,
    double value,
    Color color,
    BuildContext context,
  ) {
    final theme = shadcn.Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.typography.small.copyWith(
            color: colorScheme.mutedForeground,
            fontSize: 11,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Text(
          value.toStringAsFixed(2),
          style: AppTypography.numericValue(
            context,
          ).copyWith(fontWeight: FontWeight.w700, fontSize: 13, color: color),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildLineCard(
    BuildContext context,
    DemoJournalLine line,
    int index,
    bool isAr,
  ) {
    final theme = shadcn.Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDebit = line.debit > 0;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Indicator badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            decoration: BoxDecoration(
              color: isDebit
                  ? colorScheme.primary.withValues(alpha: 0.15)
                  : colorScheme.secondary,
              borderRadius: BorderRadius.circular(AppRadii.xs),
            ),
            child: Text(
              isDebit ? (isAr ? 'مدين' : 'DR') : (isAr ? 'دائن' : 'CR'),
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: isDebit
                    ? colorScheme.primary
                    : colorScheme.secondaryForeground,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          // Account & Description
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${line.accountCode} - ${line.accountName(isAr)}',
                  style: theme.typography.p.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  line.description(isAr),
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
          const SizedBox(width: AppSpacing.xs),
          // Amount & Delete button
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                isDebit
                    ? line.debit.toStringAsFixed(2)
                    : line.credit.toStringAsFixed(2),
                style: AppTypography.numericValue(
                  context,
                ).copyWith(fontWeight: FontWeight.w700, fontSize: 13),
              ),
              const SizedBox(height: 2),
              GestureDetector(
                onTap: () => _removeLine(index),
                child: Icon(
                  shadcn.LucideIcons.trash2,
                  size: 15,
                  color: colorScheme.destructive.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
