import 'package:flutter/material.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

import '../../theme/tokens/tokens.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_status_badge.dart';
import '../../widgets/app_surface.dart';
import '../playground_demo_models.dart';

class DetailsScenario extends StatefulWidget {
  const DetailsScenario({super.key, required this.isArabic, this.voucher});

  final bool isArabic;
  final DemoVoucherItem? voucher;

  @override
  State<DetailsScenario> createState() => _DetailsScenarioState();
}

class _DetailsScenarioState extends State<DetailsScenario> {
  bool _isAuditOpen = false;
  bool _isLinesOpen = true;

  @override
  Widget build(BuildContext context) {
    final isAr = widget.isArabic;
    final theme = shadcn.Theme.of(context);
    final colorScheme = theme.colorScheme;
    final item = widget.voucher ?? PlaygroundFixtures.vouchers.first;
    final lines = PlaygroundFixtures.initialLines;

    final totalDebit = lines.fold<double>(0, (sum, l) => sum + l.debit);
    final totalCredit = lines.fold<double>(0, (sum, l) => sum + l.credit);
    final isBalanced = (totalDebit - totalCredit).abs() < 0.001;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Identity & Status Header Card
          AppCard(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        item.referenceNumber,
                        style: theme.typography.h4.copyWith(
                          fontFamily: AppTypography.fontFamilyName,
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
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
                const SizedBox(height: AppSpacing.xs),
                Text(
                  item.title(isAr),
                  style: theme.typography.p.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.subtitle(isAr),
                  style: theme.typography.small.copyWith(
                    color: colorScheme.mutedForeground,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Icon(
                      shadcn.LucideIcons.calendar,
                      size: 14,
                      color: colorScheme.mutedForeground,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      item.date,
                      style: theme.typography.small.copyWith(
                        color: colorScheme.mutedForeground,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Icon(
                      shadcn.LucideIcons.building,
                      size: 14,
                      color: colorScheme.mutedForeground,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: Text(
                        item.branch(isAr),
                        style: theme.typography.small.copyWith(
                          color: colorScheme.mutedForeground,
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          // 2. Financial Totals & Balance Card
          AppSurface(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        isAr ? 'إجمالي المدين' : 'Total Debit',
                        style: theme.typography.small.copyWith(
                          color: colorScheme.mutedForeground,
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      '${totalDebit.toStringAsFixed(2)} ${item.currency}',
                      style: AppTypography.numericValue(
                        context,
                      ).copyWith(fontWeight: FontWeight.w700, fontSize: 14),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        isAr ? 'إجمالي الدائن' : 'Total Credit',
                        style: theme.typography.small.copyWith(
                          color: colorScheme.mutedForeground,
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      '${totalCredit.toStringAsFixed(2)} ${item.currency}',
                      style: AppTypography.numericValue(
                        context,
                      ).copyWith(fontWeight: FontWeight.w700, fontSize: 14),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                  child: Divider(color: colorScheme.border),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Icon(
                            isBalanced
                                ? shadcn.LucideIcons.circleCheck
                                : shadcn.LucideIcons.circleAlert,
                            size: 16,
                            color: isBalanced
                                ? colorScheme.primary
                                : colorScheme.destructive,
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Expanded(
                            child: Text(
                              isBalanced
                                  ? (isAr ? 'القيد متزن' : 'Balanced Entry')
                                  : (isAr
                                        ? 'القيد غير متزن'
                                        : 'Unbalanced Entry'),
                              style: theme.typography.small.copyWith(
                                fontWeight: FontWeight.w600,
                                color: isBalanced
                                    ? colorScheme.primary
                                    : colorScheme.destructive,
                                fontSize: 12,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      '${(totalDebit - totalCredit).abs().toStringAsFixed(2)} ${item.currency}',
                      style: AppTypography.numericValue(context).copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: isBalanced
                            ? colorScheme.primary
                            : colorScheme.destructive,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          // 3. Journal Lines Collapsible Section
          AppCard(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                InkWell(
                  onTap: () => setState(() => _isLinesOpen = !_isLinesOpen),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          isAr
                              ? 'بنود القيد المحاسبي (${lines.length})'
                              : 'Journal Lines (${lines.length})',
                          style: theme.typography.p.copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Icon(
                        _isLinesOpen
                            ? shadcn.LucideIcons.chevronUp
                            : shadcn.LucideIcons.chevronDown,
                        size: 18,
                        color: colorScheme.mutedForeground,
                      ),
                    ],
                  ),
                ),
                if (_isLinesOpen) ...[
                  const SizedBox(height: AppSpacing.sm),
                  ...lines.map((line) => _buildLineRow(context, line, isAr)),
                ],
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          // 4. Audit Trail Collapsible Section
          AppCard(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                InkWell(
                  onTap: () => setState(() => _isAuditOpen = !_isAuditOpen),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          isAr
                              ? 'سجل التدقيق والتتبع'
                              : 'Audit Trail & Integrity',
                          style: theme.typography.p.copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Icon(
                        _isAuditOpen
                            ? shadcn.LucideIcons.chevronUp
                            : shadcn.LucideIcons.chevronDown,
                        size: 18,
                        color: colorScheme.mutedForeground,
                      ),
                    ],
                  ),
                ),
                if (_isAuditOpen) ...[
                  const SizedBox(height: AppSpacing.sm),
                  _buildAuditItem(
                    icon: shadcn.LucideIcons.filePlus,
                    title: isAr ? 'إنشاء المستند' : 'Document Created',
                    subtitle: '2026-03-15 08:30:12 • admin@nexabiz.com',
                    isAr: isAr,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  _buildAuditItem(
                    icon: shadcn.LucideIcons.squareCheck,
                    title: isAr ? 'المراجعة المحاسبية' : 'Accounting Reviewed',
                    subtitle: '2026-03-15 09:14:02 • chief.accountant',
                    isAr: isAr,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  _buildAuditItem(
                    icon: shadcn.LucideIcons.stamp,
                    title: isAr
                        ? 'الترحيل المالي النهائي'
                        : 'Posted to General Ledger',
                    subtitle: '2026-03-15 09:15:00 • Batch #98210',
                    isAr: isAr,
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          // 5. Action Buttons
          Row(
            children: [
              Expanded(
                child: AppButton(
                  label: isAr ? 'طباعة السند' : 'Print PDF',
                  icon: shadcn.LucideIcons.printer,
                  variant: AppButtonVariant.filled,
                  onPressed: () {},
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: AppButton(
                  label: isAr ? 'عكس القيد' : 'Reverse',
                  icon: shadcn.LucideIcons.undo,
                  variant: AppButtonVariant.outlined,
                  onPressed: () {},
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLineRow(BuildContext context, DemoJournalLine line, bool isAr) {
    final theme = shadcn.Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDebit = line.debit > 0;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.xs),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: colorScheme.muted.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(AppRadii.xs),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  line.accountName(isAr),
                  style: theme.typography.small.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  line.accountCode,
                  style: theme.typography.small.copyWith(
                    color: colorScheme.mutedForeground,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Text(
            isDebit
                ? line.debit.toStringAsFixed(2)
                : line.credit.toStringAsFixed(2),
            style: AppTypography.numericValue(
              context,
            ).copyWith(fontWeight: FontWeight.w700, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildAuditItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isAr,
  }) {
    final theme = shadcn.Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: colorScheme.mutedForeground),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.typography.small.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
              Text(
                subtitle,
                style: theme.typography.small.copyWith(
                  color: colorScheme.mutedForeground,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
