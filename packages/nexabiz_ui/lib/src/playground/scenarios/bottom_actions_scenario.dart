import 'package:flutter/material.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

import '../../theme/tokens/tokens.dart';
import '../../widgets/app_bottom_actions.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_icon_button.dart';

class BottomActionsScenario extends StatefulWidget {
  const BottomActionsScenario({super.key, required this.isArabic});

  final bool isArabic;

  @override
  State<BottomActionsScenario> createState() => _BottomActionsScenarioState();
}

class _BottomActionsScenarioState extends State<BottomActionsScenario> {
  String? _lastAction;

  void _setAction(String msg) {
    setState(() => _lastAction = msg);
  }

  @override
  Widget build(BuildContext context) {
    final isAr = widget.isArabic;
    final theme = shadcn.Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  isAr ? 'شريط الإجراءات السفلية (Bottom Actions)' : 'Mobile Bottom Actions Showcase',
                  style: theme.typography.h3.copyWith(
                    fontFamily: AppTypography.fontFamilyName,
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isAr
                      ? 'شريط إجراءات سفلي ملتصق يدعم التكيف المحمول وهامش منطقة الأمان والأولوية البصرية'
                      : 'Sticky bottom actions bar with SafeArea awareness, priority hierarchy, and phone responsiveness',
                  style: theme.typography.small.copyWith(
                    color: colorScheme.mutedForeground,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                if (_lastAction != null) ...[
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppRadii.sm),
                      border: Border.all(color: colorScheme.primary.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      _lastAction!,
                      style: theme.typography.small.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],

                // Composition 1: Save Draft + Post
                _buildCard(
                  title: isAr ? '١. حفظ مسودة + ترحيل نهائي' : '1. Save Draft + Post',
                  desc: isAr ? 'إجراء فرعي (مسودة) وإجراء رئيسي بارز (ترحيل)' : 'Secondary draft action + Prominent primary post action',
                  widget: AppBottomActions(
                    showBorder: true,
                    primaryAction: AppButton(
                      label: isAr ? 'ترحيل القيد' : 'Post Voucher',
                      variant: AppButtonVariant.filled,
                      onPressed: () => _setAction(isAr ? 'تم ترحيل القيد' : 'Voucher Posted'),
                    ),
                    secondaryAction: AppButton(
                      label: isAr ? 'حفظ مسودة' : 'Save Draft',
                      variant: AppButtonVariant.outlined,
                      onPressed: () => _setAction(isAr ? 'تم حفظ المسودة' : 'Draft Saved'),
                    ),
                  ),
                ),

                const SizedBox(height: AppSpacing.md),

                // Composition 2: Cancel + Save
                _buildCard(
                  title: isAr ? '٢. إلغاء + حفظ المستند' : '2. Cancel + Save Document',
                  desc: isAr ? 'شريط عادي لصفحات إنشاء وتعديل البيانات' : 'Standard creation/edit form actions',
                  widget: AppBottomActions(
                    primaryAction: AppButton(
                      label: isAr ? 'حفظ البيانات' : 'Save Changes',
                      variant: AppButtonVariant.filled,
                      onPressed: () => _setAction(isAr ? 'تم حفظ البيانات' : 'Changes Saved'),
                    ),
                    secondaryAction: AppButton(
                      label: isAr ? 'إلغاء' : 'Cancel',
                      variant: AppButtonVariant.outlined,
                      onPressed: () => _setAction(isAr ? 'تم الإلغاء' : 'Cancelled'),
                    ),
                  ),
                ),

                const SizedBox(height: AppSpacing.md),

                // Composition 3: Delete + Save + Overflow
                _buildCard(
                  title: isAr ? '٣. حذف خطر + حفظ + إجراءات إضافية' : '3. Delete + Save + Overflow Action',
                  desc: isAr ? 'إجراء خطير في الطرف الفرعي مع زر رئيسي للإنهاء' : 'Destructive action on leading side with primary finish',
                  widget: AppBottomActions(
                    extraActions: [
                      AppIconButton(
                        icon: shadcn.LucideIcons.trash2,
                        variant: AppIconButtonVariant.destructive,
                        tooltip: isAr ? 'حذف القيد' : 'Delete Entry',
                        onPressed: () => _setAction(isAr ? 'تم الحذف' : 'Deleted'),
                      ),
                    ],
                    primaryAction: AppButton(
                      label: isAr ? 'حفظ التعديلات' : 'Save Entry',
                      variant: AppButtonVariant.filled,
                      onPressed: () => _setAction(isAr ? 'تم الحفظ' : 'Saved'),
                    ),
                    secondaryAction: AppButton(
                      label: isAr ? 'إلغاء' : 'Cancel',
                      variant: AppButtonVariant.outlined,
                      onPressed: () => _setAction(isAr ? 'تم الإلغاء' : 'Cancelled'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Live Active Bottom Actions Demonstration bar attached to bottom
        AppBottomActions(
          primaryAction: AppButton(
            label: isAr ? 'تأكيد وحفظ القيد' : 'Confirm & Save Voucher',
            variant: AppButtonVariant.filled,
            onPressed: () => _setAction(isAr ? 'تم الضغط على الشريط المباشر السفلي' : 'Live bottom actions triggered'),
          ),
          secondaryAction: AppButton(
            label: isAr ? 'تراجع' : 'Back',
            variant: AppButtonVariant.outlined,
            onPressed: () => _setAction(isAr ? 'تم الضغط على التراجع' : 'Back triggered'),
          ),
        ),
      ],
    );
  }

  Widget _buildCard({
    required String title,
    required String desc,
    required Widget widget,
  }) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(height: 2),
          Text(desc, style: const TextStyle(color: Colors.grey, fontSize: 11)),
          const SizedBox(height: AppSpacing.xs),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadii.sm),
            child: widget,
          ),
        ],
      ),
    );
  }
}
