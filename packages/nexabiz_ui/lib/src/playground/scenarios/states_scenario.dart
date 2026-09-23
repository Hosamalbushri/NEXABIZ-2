import 'package:flutter/material.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

import '../../theme/tokens/tokens.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_empty_state.dart';
import '../../widgets/app_error_state.dart';
import '../../widgets/app_loading.dart';
import '../../widgets/app_text_field.dart';

enum StateDemoView { skeleton, empty, error, offline, disabled }

class StatesScenario extends StatefulWidget {
  const StatesScenario({super.key, required this.isArabic});

  final bool isArabic;

  @override
  State<StatesScenario> createState() => _StatesScenarioState();
}

class _StatesScenarioState extends State<StatesScenario> {
  StateDemoView _selectedView = StateDemoView.skeleton;
  late final TextEditingController _disabledTextController;

  @override
  void initState() {
    super.initState();
    _disabledTextController = TextEditingController(
      text: widget.isArabic ? 'قيمة غير قابلة للتعديل' : 'Non-editable value',
    );
  }

  @override
  void dispose() {
    _disabledTextController.dispose();
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
          // Header & View Selector
          Text(
            isAr
                ? 'حالات الشاشة والنظام (Screen States)'
                : 'Mobile Screen States',
            style: theme.typography.h3.copyWith(
              fontFamily: AppTypography.fontFamilyName,
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            isAr
                ? 'استعراض الحالات الشائعة (التحميل، الفراغ، الخطأ، عدم الاتصال، والتعطيل)'
                : 'Canonical presentation of loading, empty, error, offline, and disabled states',
            style: theme.typography.small.copyWith(
              color: colorScheme.mutedForeground,
              fontSize: 12,
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          // Horizontal view switcher
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildSelectorChip(
                  StateDemoView.skeleton,
                  isAr ? 'هيكل التحميل' : 'Skeleton',
                ),
                const SizedBox(width: AppSpacing.xs),
                _buildSelectorChip(
                  StateDemoView.empty,
                  isAr ? 'حالة فارغة' : 'Empty',
                ),
                const SizedBox(width: AppSpacing.xs),
                _buildSelectorChip(
                  StateDemoView.error,
                  isAr ? 'حالة خطأ' : 'Error',
                ),
                const SizedBox(width: AppSpacing.xs),
                _buildSelectorChip(
                  StateDemoView.offline,
                  isAr ? 'بدون اتصال' : 'Offline',
                ),
                const SizedBox(width: AppSpacing.xs),
                _buildSelectorChip(
                  StateDemoView.disabled,
                  isAr ? 'عناصر معطلة' : 'Disabled',
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          // Selected State Content
          AppCard(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: _buildStateContent(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectorChip(StateDemoView view, String label) {
    final isSelected = _selectedView == view;
    final theme = shadcn.Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: () => setState(() => _selectedView = view),
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

  Widget _buildStateContent(BuildContext context) {
    final isAr = widget.isArabic;
    final theme = shadcn.Theme.of(context);
    final colorScheme = theme.colorScheme;

    switch (_selectedView) {
      case StateDemoView.skeleton:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              isAr
                  ? 'نمط التحميل الهيكلي (Skeleton Loading)'
                  : 'Skeleton Placeholder Pattern',
              style: theme.typography.p.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            const SizedBox(
              height: 260,
              child: AppLoading(
                style: AppLoadingStyle.skeletonList,
                skeletonItemCount: 3,
              ),
            ),
          ],
        );

      case StateDemoView.empty:
        return AppEmptyState(
          icon: shadcn.LucideIcons.inbox,
          title: isAr
              ? 'لا توجد بيانات دفتر الأستاذ'
              : 'No ledger data recorded',
          subtitle: isAr
              ? 'لم يتم ترحيل أي قيود يومية في هذه الفترة المحاسبية حتى الآن.'
              : 'No journal entries have been posted to this financial period yet.',
          actionLabel: isAr ? 'إنشاء قيد جديد' : 'Create First Voucher',
          onAction: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  isAr ? 'بدء إنشاء قيد جديد' : 'Opening new voucher flow',
                ),
              ),
            );
          },
        );

      case StateDemoView.error:
        return AppErrorState(
          title: isAr ? 'تعذر مزامنة السجلات المالية' : 'Financial Sync Error',
          message: isAr
              ? 'حدث خطأ غير متوقع أثناء معالجة استعلام دفتر الحسابات. تم تسجيل الحادثة للمراجعة.'
              : 'An unexpected exception occurred while retrieving account balances.',
          retryLabel: isAr ? 'إعادة محاولة المزامنة' : 'Retry Sync',
          onRetry: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  isAr ? 'جارٍ إعادة المحاولة...' : 'Retrying connection...',
                ),
              ),
            );
          },
        );

      case StateDemoView.offline:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(AppRadii.sm),
                border: Border.all(color: Colors.amber.withValues(alpha: 0.4)),
              ),
              child: Row(
                children: [
                  const Icon(
                    shadcn.LucideIcons.wifiOff,
                    size: 16,
                    color: Colors.amber,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Text(
                      isAr
                          ? 'أنت تعمل في وضع عدم الاتصال (Offline Mode). التغييرات محفوظة محلياً.'
                          : 'You are working offline. Changes are saved locally and will sync when reconnected.',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.amber,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Center(
              child: Icon(
                shadcn.LucideIcons.cloudOff,
                size: 56,
                color: colorScheme.mutedForeground.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              isAr ? 'البيانات المحلية جاهزة' : 'Local Cache Active',
              textAlign: TextAlign.center,
              style: theme.typography.p.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              isAr
                  ? 'يمكنك متابعة استعراض السندات المحفوظة وإعداد قيود المسودات حتى عودة الاتصال.'
                  : 'You can continue browsing cached records and draft vouchers without interruption.',
              textAlign: TextAlign.center,
              style: theme.typography.small.copyWith(
                color: colorScheme.mutedForeground,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            AppButton(
              label: isAr ? 'فحص الاتصال الآن' : 'Check Connectivity Now',
              variant: AppButtonVariant.outlined,
              onPressed: () {},
            ),
          ],
        );

      case StateDemoView.disabled:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              isAr
                  ? 'نماذج العناصر المعطلة والقراءة فقط:'
                  : 'Disabled & Read-Only UI Controls:',
              style: theme.typography.p.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              label: isAr ? 'حقل معطل تماماً' : 'Disabled Text Field',
              controller: _disabledTextController,
              enabled: false,
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                const Expanded(
                  child: AppButton(
                    label: 'Disabled Filled',
                    variant: AppButtonVariant.filled,
                    onPressed: null,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                const Expanded(
                  child: AppButton(
                    label: 'Disabled Outlined',
                    variant: AppButtonVariant.outlined,
                    onPressed: null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: colorScheme.muted.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(AppRadii.sm),
                border: Border.all(
                  color: colorScheme.border.withValues(alpha: 0.5),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    shadcn.LucideIcons.lock,
                    size: 16,
                    color: colorScheme.mutedForeground,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Text(
                      isAr
                          ? 'تم إقفال الفترة المالية. لا يمكن إضافة أو تعديل القيود.'
                          : 'Financial period is closed. Voucher edits are locked.',
                      style: theme.typography.small.copyWith(
                        color: colorScheme.mutedForeground,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
    }
  }
}
