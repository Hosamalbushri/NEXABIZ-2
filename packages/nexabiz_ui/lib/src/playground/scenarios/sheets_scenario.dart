import 'package:flutter/material.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

import '../../theme/tokens/tokens.dart';
import '../../widgets/app_bottom_sheet.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_text_field.dart';
import '../playground_demo_models.dart';

class SheetsScenario extends StatefulWidget {
  const SheetsScenario({super.key, required this.isArabic});

  final bool isArabic;

  @override
  State<SheetsScenario> createState() => _SheetsScenarioState();
}

class _SheetsScenarioState extends State<SheetsScenario> {
  String? _selectedResult;

  void _openSearchableAccountSheet() {
    final isAr = widget.isArabic;
    final accounts = PlaygroundFixtures.accounts;

    AppBottomSheet.show<void>(
      context: context,
      title: isAr ? 'دليل الحسابات المالية' : 'Chart of Accounts',
      subtitle: isAr ? 'اختر حساباً لترحيل الحركة المالية' : 'Select an account to post entry',
      icon: shadcn.LucideIcons.bookOpen,
      child: StatefulBuilder(
        builder: (ctx, setSheetState) {
          return _SheetAccountSelectorBody(
            accounts: accounts,
            isArabic: isAr,
            onSelect: (acc) {
              setState(() {
                _selectedResult = '${acc.code} - ${acc.name(isAr)}';
              });
              Navigator.of(ctx).pop();
            },
          );
        },
      ),
    );
  }

  void _openActionSheet() {
    final isAr = widget.isArabic;

    AppBottomSheet.show<void>(
      context: context,
      title: isAr ? 'إجراءات السند JV-2026-001' : 'Actions for JV-2026-001',
      subtitle: isAr ? 'الخيارات المتاحة للتعامل مع هذا القيد' : 'Available actions for this voucher',
      icon: shadcn.LucideIcons.ellipsis,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildActionSheetTile(
            icon: shadcn.LucideIcons.printer,
            title: isAr ? 'طباعة إشعار السند (PDF)' : 'Print Voucher Receipt (PDF)',
            subtitle: isAr ? 'إنشاء ملف PDF جاهز للمصادقة' : 'Generate sign-ready PDF document',
            onTap: () {
              Navigator.of(context).pop();
              _setResult(isAr ? 'تم بدء طباعة السند' : 'Voucher printing initiated');
            },
          ),
          _buildActionSheetTile(
            icon: shadcn.LucideIcons.copy,
            title: isAr ? 'نسخ وإنشاء قيد مطابق' : 'Duplicate Voucher',
            subtitle: isAr ? 'إنشاء قيد جديد بنفس الحسابات' : 'Clone accounts into new voucher draft',
            onTap: () {
              Navigator.of(context).pop();
              _setResult(isAr ? 'تم نسخ القيد كمسودة' : 'Voucher duplicated as draft');
            },
          ),
          _buildActionSheetTile(
            icon: shadcn.LucideIcons.undo,
            title: isAr ? 'عكس القيد المحاسبي' : 'Reverse Journal Entry',
            subtitle: isAr ? 'إنشاء قيد عكسي تسوي معتمد' : 'Create balancing reversal voucher',
            onTap: () {
              Navigator.of(context).pop();
              _setResult(isAr ? 'تم إنشاء قيد عكسي' : 'Reversal voucher created');
            },
          ),
          _buildActionSheetTile(
            icon: shadcn.LucideIcons.history,
            title: isAr ? 'سجل التدقيق والتتبع' : 'Audit Trail & Change Log',
            subtitle: isAr ? 'عرض الحركات وتواريخ التعديل' : 'View modification timestamps & users',
            onTap: () {
              Navigator.of(context).pop();
              _setResult(isAr ? 'تم فتح سجل التدقيق' : 'Audit log opened');
            },
          ),
        ],
      ),
    );
  }

  void _openConfirmationSheet() {
    final isAr = widget.isArabic;

    AppBottomSheet.show<void>(
      context: context,
      title: isAr ? 'تأكيد إلغاء القيد المحاسبي' : 'Confirm Voucher Cancellation',
      icon: shadcn.LucideIcons.triangleAlert,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            isAr
                ? 'هل أنت متأكد من رغبتك في إلغاء القيد JV-2026-001؟ سيتم تحويل حالته إلى "ملغي" ولن يتم احتسابه في ميزان المراجعة.'
                : 'Are you sure you want to cancel voucher JV-2026-001? Its status will become "Cancelled" and excluded from Trial Balance.',
            style: const TextStyle(fontSize: 13, height: 1.4),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: AppButton(
                  label: isAr ? 'تأكيد الإلغاء' : 'Confirm Cancel',
                  variant: AppButtonVariant.destructive,
                  onPressed: () {
                    Navigator.of(context).pop();
                    _setResult(isAr ? 'تم إلغاء القيد بنجاح' : 'Voucher cancelled successfully');
                  },
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: AppButton(
                  label: isAr ? 'تراجع' : 'Keep Voucher',
                  variant: AppButtonVariant.outlined,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _setResult(String res) {
    setState(() => _selectedResult = res);
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
          Text(
            isAr ? 'معرض الصفائح السفلية (Bottom Sheets)' : 'Mobile Bottom Sheets',
            style: theme.typography.h3.copyWith(
              fontFamily: AppTypography.fontFamilyName,
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            isAr
                ? 'صفائح تفاعلية مصممة للهاتف لتقديم الخيارات والمدخلات بسلاسة'
                : 'Interactive phone-first bottom sheets for contextual selection and actions',
            style: theme.typography.small.copyWith(
              color: colorScheme.mutedForeground,
              fontSize: 12,
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          // Last Action / Selection feedback
          if (_selectedResult != null) ...[
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppRadii.sm),
                border: Border.all(color: colorScheme.primary.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(shadcn.LucideIcons.circleCheck, size: 16, color: colorScheme.primary),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Text(
                      _selectedResult!,
                      style: theme.typography.small.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
          ],

          // Launcher Cards
          _buildSheetLauncherCard(
            title: isAr ? '١. صفيحة اختيار الحساب المالي (مع بحث سريع)' : '1. Searchable Account Selector Sheet',
            description: isAr
                ? 'صفيحة مخصصة للبحث السريع والتمرير بين الحسابات وتصنيفاتها'
                : 'Modal sheet with instant search filtering across ledger accounts',
            icon: shadcn.LucideIcons.bookOpen,
            buttonLabel: isAr ? 'فتح صفيحة الحسابات' : 'Open Account Sheet',
            onTap: _openSearchableAccountSheet,
          ),

          const SizedBox(height: AppSpacing.sm),

          _buildSheetLauncherCard(
            title: isAr ? '٢. صفيحة إجراءات السند (Action Sheet)' : '2. Voucher Action Sheet',
            description: isAr
                ? 'قائمة خيارات وإجراءات سريعة للسند (طباعة، نسخ، عكس، تتبع)'
                : 'Contextual quick actions (Print PDF, Duplicate, Reverse, Audit)',
            icon: shadcn.LucideIcons.ellipsis,
            buttonLabel: isAr ? 'فتح صفيحة الإجراءات' : 'Open Action Sheet',
            onTap: _openActionSheet,
          ),

          const SizedBox(height: AppSpacing.sm),

          _buildSheetLauncherCard(
            title: isAr ? '٣. صفيحة التأكيد التحذيرية (Confirmation Sheet)' : '3. Destructive Confirmation Sheet',
            description: isAr
                ? 'صفيحة تحذيرية لإلغاء القيد مع زر إجراء خطر وزر تراجع'
                : 'Critical confirmation before performing irreversible changes',
            icon: shadcn.LucideIcons.triangleAlert,
            buttonLabel: isAr ? 'فتح صفيحة التأكيد' : 'Open Confirm Sheet',
            onTap: _openConfirmationSheet,
          ),

          const SizedBox(height: AppSpacing.lg),

          // Inline Static Preview of Account Sheet
          Text(
            isAr ? 'معاينة ثابتة لنمط الصفيحة السفلية:' : 'Static Inline Bottom Sheet Architecture:',
            style: theme.typography.small.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.mutedForeground,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          AppCard(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: colorScheme.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  isAr ? 'دليل الحسابات' : 'Chart of Accounts',
                  style: theme.typography.p.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  isAr ? 'تصميم مخصص للمس الإصبع، ارتفاع تكيفي، ودعم كامل للغة العربية.' : 'Touch-optimized drag handle, adaptive height, keyboard avoidance, and RTL.',
                  style: theme.typography.small.copyWith(color: colorScheme.mutedForeground),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSheetLauncherCard({
    required String title,
    required String description,
    required IconData icon,
    required String buttonLabel,
    required VoidCallback onTap,
  }) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(icon, size: 18),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            description,
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
          const SizedBox(height: AppSpacing.sm),
          AppButton(
            label: buttonLabel,
            variant: AppButtonVariant.outlined,
            isCompact: true,
            onPressed: onTap,
          ),
        ],
      ),
    );
  }

  Widget _buildActionSheetTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final theme = shadcn.Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: colorScheme.muted,
                borderRadius: BorderRadius.circular(AppRadii.xs),
              ),
              child: Icon(icon, size: 18, color: colorScheme.foreground),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.typography.p.copyWith(fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                  Text(
                    subtitle,
                    style: theme.typography.small.copyWith(color: colorScheme.mutedForeground, fontSize: 11),
                  ),
                ],
              ),
            ),
            Icon(shadcn.LucideIcons.chevronRight, size: 16, color: colorScheme.mutedForeground),
          ],
        ),
      ),
    );
  }
}

class _SheetAccountSelectorBody extends StatefulWidget {
  const _SheetAccountSelectorBody({
    required this.accounts,
    required this.isArabic,
    required this.onSelect,
  });

  final List<DemoAccountOption> accounts;
  final bool isArabic;
  final ValueChanged<DemoAccountOption> onSelect;

  @override
  State<_SheetAccountSelectorBody> createState() => _SheetAccountSelectorBodyState();
}

class _SheetAccountSelectorBodyState extends State<_SheetAccountSelectorBody> {
  String _search = '';

  @override
  Widget build(BuildContext context) {
    final theme = shadcn.Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isAr = widget.isArabic;

    final filtered = widget.accounts.where((a) {
      if (_search.isEmpty) return true;
      final q = _search.toLowerCase();
      return a.code.contains(q) || a.name(isAr).toLowerCase().contains(q);
    }).toList();

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppTextField(
          hint: isAr ? 'بحث برقم أو اسم الحساب...' : 'Search code or account name...',
          prefixIcon: Icon(shadcn.LucideIcons.search, size: 16, color: colorScheme.mutedForeground),
          onChanged: (v) => setState(() => _search = v),
        ),
        const SizedBox(height: AppSpacing.sm),
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 280),
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: filtered.length,
            separatorBuilder: (_, _) => Divider(color: colorScheme.border, height: 1),
            itemBuilder: (ctx, idx) {
              final acc = filtered[idx];
              return InkWell(
                onTap: () => widget.onSelect(acc),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: colorScheme.muted,
                          borderRadius: BorderRadius.circular(AppRadii.xs),
                        ),
                        child: Text(
                          acc.code,
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: colorScheme.foreground),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              acc.name(isAr),
                              style: theme.typography.p.copyWith(fontWeight: FontWeight.w600, fontSize: 13),
                            ),
                            Text(
                              acc.category(isAr),
                              style: theme.typography.small.copyWith(color: colorScheme.mutedForeground, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                      Icon(shadcn.LucideIcons.check, size: 16, color: colorScheme.primary),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

