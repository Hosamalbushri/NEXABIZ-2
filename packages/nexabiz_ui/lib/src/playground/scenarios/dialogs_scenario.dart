import 'package:flutter/material.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

import '../../theme/tokens/tokens.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_dialog.dart';
import '../../widgets/app_icon_avatar.dart';

class DialogsScenario extends StatefulWidget {
  const DialogsScenario({super.key, required this.isArabic});

  final bool isArabic;

  @override
  State<DialogsScenario> createState() => _DialogsScenarioState();
}

class _DialogsScenarioState extends State<DialogsScenario> {
  String? _dialogFeedback;

  void _showWarningDialog() {
    final isAr = widget.isArabic;
    AppDialog.confirm(
      context: context,
      title: isAr ? 'ترحيل القيد المالي' : 'Post Voucher to Ledger',
      message: isAr
          ? 'هل ترغب في ترحيل القيد JV-2026-001 بصفة نهائية؟ لا يمكن التعديل المباشر بعد الترحيل.'
          : 'Are you sure you want to permanently post voucher JV-2026-001? Direct modification is locked after posting.',
      confirmLabel: isAr ? 'تأكيد الترحيل' : 'Confirm Post',
      cancelLabel: isAr ? 'إلغاء' : 'Cancel',
      tone: AppDialogTone.primary,
      onConfirm: () {
        setState(() {
          _dialogFeedback = isAr ? 'تم ترحيل القيد المالي بنجاح!' : 'Voucher posted successfully!';
        });
      },
    );
  }

  void _showDestructiveDialog() {
    final isAr = widget.isArabic;
    AppDialog.confirm(
      context: context,
      title: isAr ? 'حذف مسودة القيد' : 'Delete Voucher Draft',
      message: isAr
          ? 'سيتم حذف مسودة القيد JV-2026-006 بشكل دائم. هذا الإجراء لا يمكن التراجع عنه.'
          : 'Voucher draft JV-2026-006 will be deleted permanently. This action cannot be undone.',
      confirmLabel: isAr ? 'حذف نهائي' : 'Delete Permanently',
      cancelLabel: isAr ? 'احتفاظ' : 'Keep',
      tone: AppDialogTone.danger,
      onConfirm: () {
        setState(() {
          _dialogFeedback = isAr ? 'تم حذف مسودة القيد.' : 'Voucher draft deleted.';
        });
      },
    );
  }

  void _showDecisionDialog() {
    final isAr = widget.isArabic;
    final theme = shadcn.Theme.of(context);
    final colorScheme = theme.colorScheme;

    AppDialog.show<void>(
      context: context,
      title: isAr ? 'خيارات حفظ المستند' : 'Document Save Options',
      size: AppDialogSize.small,
      leading: const AppIconAvatar(
        icon: shadcn.LucideIcons.fileText,
        tone: AppIconAvatarTone.primary,
        size: AppIconAvatarSize.md,
      ),
      actions: [
        AppButton(
          label: isAr ? 'إلغاء' : 'Cancel',
          variant: AppButtonVariant.text,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            isAr
                ? 'حدد طريقة المعالجة المناسبة لهذا القيد:'
                : 'Choose processing method for this journal entry:',
            style: theme.typography.small.copyWith(color: colorScheme.mutedForeground),
          ),
          const SizedBox(height: AppSpacing.md),
          AppButton(
            label: isAr ? 'ترحيل مباشر لدفتر الأستاذ' : 'Post Directly to Ledger',
            icon: shadcn.LucideIcons.checkCheck,
            variant: AppButtonVariant.filled,
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _dialogFeedback = isAr ? 'تم الحفظ والترحيل المباشر' : 'Saved and posted directly';
              });
            },
          ),
          const SizedBox(height: AppSpacing.xs),
          AppButton(
            label: isAr ? 'حفظ كمسودة فقط' : 'Save as Draft Only',
            icon: shadcn.LucideIcons.fileClock,
            variant: AppButtonVariant.outlined,
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _dialogFeedback = isAr ? 'تم الحفظ كمسودة' : 'Saved as draft only';
              });
            },
          ),
        ],
      ),
    );
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
            isAr ? 'معرض مربعات الحوار (Dialogs)' : 'Mobile Dialogs Showcase',
            style: theme.typography.h3.copyWith(
              fontFamily: AppTypography.fontFamilyName,
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            isAr
                ? 'مربعات حوار سريعة ومحكمة مخصصة لشاشات الهاتف دون فيضان أفقي'
                : 'Compact, touch-friendly dialogs designed for phone screens without horizontal overflow',
            style: theme.typography.small.copyWith(
              color: colorScheme.mutedForeground,
              fontSize: 12,
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          // Feedback banner
          if (_dialogFeedback != null) ...[
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppRadii.sm),
                border: Border.all(color: colorScheme.primary.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(shadcn.LucideIcons.info, size: 16, color: colorScheme.primary),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Text(
                      _dialogFeedback!,
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

          // Dialog Launchers
          _buildLauncher(
            title: isAr ? '١. تأكيد ترحيل القيد (إجراء أساسي)' : '1. Standard Confirmation Dialog',
            desc: isAr ? 'حوار تأكيد مع أيقونة أساسية وزري تأكيد وتراجع' : 'Voucher posting confirmation with primary icon and twin buttons',
            btnLabel: isAr ? 'عرض حوار الترحيل' : 'Show Post Dialog',
            onTap: _showWarningDialog,
          ),

          const SizedBox(height: AppSpacing.sm),

          _buildLauncher(
            title: isAr ? '٢. حوار الحذف الخطر (Destructive)' : '2. Destructive Confirmation Dialog',
            desc: isAr ? 'تنبيه خطر بلون أحمر تحذيري لمنع الحذف العرضي' : 'High-risk action with danger tone to prevent accidental deletion',
            btnLabel: isAr ? 'عرض حوار الحذف' : 'Show Delete Dialog',
            onTap: _showDestructiveDialog,
          ),

          const SizedBox(height: AppSpacing.sm),

          _buildLauncher(
            title: isAr ? '٣. حوار القرار متعدد الخيارات' : '3. Multi-Option Decision Dialog',
            desc: isAr ? 'خيارات حفظ كمسودة أو ترحيل فوري لدفتر الأستاذ' : 'Modal decision between draft save and instant ledger posting',
            btnLabel: isAr ? 'عرض حوار الخيارات' : 'Show Decision Dialog',
            onTap: _showDecisionDialog,
          ),

          const SizedBox(height: AppSpacing.lg),

          // Inline Static Preview
          Text(
            isAr ? 'معاينة هيكلية لتصميم مربع الحوار المحمول:' : 'Mobile Dialog Anatomical Preview:',
            style: theme.typography.small.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.mutedForeground,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          AppCard(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const AppIconAvatar(
                  icon: shadcn.LucideIcons.triangleAlert,
                  tone: AppIconAvatarTone.warning,
                  size: AppIconAvatarSize.md,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  isAr ? 'تأكيد العملية المالية' : 'Financial Operation Notice',
                  style: theme.typography.p.copyWith(fontWeight: FontWeight.bold, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  isAr
                      ? 'تم تحسين المسافات وهوامش اللمس لتناسب الشاشات بعرض ٣٢٠ إلى ٤٣٠ بكسل دون أي قص.'
                      : 'Margins, paddings, and touch targets are strictly tuned for 320–430px phones.',
                  style: theme.typography.small.copyWith(
                    color: colorScheme.mutedForeground,
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        label: isAr ? 'موافق' : 'Confirm',
                        variant: AppButtonVariant.filled,
                        isCompact: true,
                        onPressed: () {},
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: AppButton(
                        label: isAr ? 'تراجع' : 'Cancel',
                        variant: AppButtonVariant.outlined,
                        isCompact: true,
                        onPressed: () {},
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLauncher({
    required String title,
    required String desc,
    required String btnLabel,
    required VoidCallback onTap,
  }) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
          const SizedBox(height: 2),
          Text(desc, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: AppSpacing.sm),
          AppButton(
            label: btnLabel,
            variant: AppButtonVariant.outlined,
            isCompact: true,
            onPressed: onTap,
          ),
        ],
      ),
    );
  }
}

