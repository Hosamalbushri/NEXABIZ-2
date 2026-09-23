import 'package:flutter/material.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

import '../../theme/tokens/tokens.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_checkbox.dart';
import '../../widgets/app_number_field.dart';
import '../../widgets/app_status_badge.dart';
import '../../widgets/app_surface.dart';
import '../../widgets/app_switch.dart';
import '../../widgets/app_text_field.dart';

class FoundationScenario extends StatefulWidget {
  const FoundationScenario({super.key, required this.isArabic});

  final bool isArabic;

  @override
  State<FoundationScenario> createState() => _FoundationScenarioState();
}

class _FoundationScenarioState extends State<FoundationScenario> {
  bool _switchVal = true;
  bool _checkVal = true;
  bool _buttonLoading = false;
  double _numberVal = 1250.0;

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
          // 1. Typography Hierarchy
          _buildSectionHeader(
            isAr
                ? 'التدرج الطباعي المالي (Cairo)'
                : 'Financial Typography (Cairo)',
          ),
          const SizedBox(height: AppSpacing.xs),
          AppCard(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTypeRow(
                  'screenTitle (20sp bold)',
                  'NexaBiz ERP',
                  'نكسا بيز المحاسبي',
                  theme.typography.h3.copyWith(
                    fontFamily: AppTypography.fontFamilyName,
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                  ),
                ),
                _buildDivider(),
                _buildTypeRow(
                  'sectionTitle (16sp semiBold)',
                  'General Ledger Operations',
                  'عمليات دفتر الأستاذ العام',
                  theme.typography.p.copyWith(
                    fontFamily: AppTypography.fontFamilyName,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                _buildDivider(),
                _buildTypeRow(
                  'cardTitle (15sp semiBold)',
                  'Commercial Account 101001',
                  'حساب تجاري رئيسي ١٠١٠٠١',
                  theme.typography.p.copyWith(
                    fontFamily: AppTypography.fontFamilyName,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                _buildDivider(),
                _buildTypeRow(
                  'body (14sp regular)',
                  'Transaction balance verified against bank statement.',
                  'تم التحقق من رصيد المعاملة ومطابقته كشف الحساب.',
                  theme.typography.p.copyWith(
                    fontFamily: AppTypography.fontFamilyName,
                    fontSize: 14,
                  ),
                ),
                _buildDivider(),
                _buildTypeRow(
                  'amount (15sp semiBold tabular)',
                  '12,450.00 USD',
                  '١٢,٤٥٠.٠٠ ر.س',
                  AppTypography.numericValue(
                    context,
                  ).copyWith(fontSize: 15, fontWeight: FontWeight.w600),
                ),
                _buildDivider(),
                _buildTypeRow(
                  'largeAmount (22sp bold tabular)',
                  '1,450,280.75 SAR',
                  '١,٤٥٠,٢٨٠.٧٥ ر.س',
                  AppTypography.numericValue(
                    context,
                  ).copyWith(fontSize: 22, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          // 2. Buttons & Actions
          _buildSectionHeader(
            isAr ? 'الأزرار والإجراءات' : 'Buttons & Interactive Controls',
          ),
          const SizedBox(height: AppSpacing.xs),
          AppCard(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        label: isAr ? 'إجراء أساسي' : 'Primary Action',
                        variant: AppButtonVariant.filled,
                        onPressed: () {},
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: AppButton(
                        label: isAr ? 'إجراء ثانوي' : 'Secondary Action',
                        variant: AppButtonVariant.outlined,
                        onPressed: () {},
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        label: isAr ? 'إجراء خافت' : 'Text Action',
                        variant: AppButtonVariant.text,
                        onPressed: () {},
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: AppButton(
                        label: isAr ? 'إجراء تدميري' : 'Destructive',
                        variant: AppButtonVariant.destructive,
                        onPressed: () {},
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                AppButton(
                  label: isAr
                      ? (_buttonLoading
                            ? 'جارٍ التحميل...'
                            : 'اضغط لاختبار التحميل')
                      : (_buttonLoading
                            ? 'Loading...'
                            : 'Tap for Loading Test'),
                  variant: AppButtonVariant.filled,
                  isLoading: _buttonLoading,
                  onPressed: () =>
                      setState(() => _buttonLoading = !_buttonLoading),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          // 3. Status Badges
          _buildSectionHeader(
            isAr ? 'شارات الحالة المحاسبية' : 'Status & Tone Badges',
          ),
          const SizedBox(height: AppSpacing.xs),
          AppSurface(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                AppStatusBadge(
                  label: isAr ? 'مرحل (Posted)' : 'Posted',
                  tone: AppStatusTone.success,
                  animate: false,
                ),
                AppStatusBadge(
                  label: isAr ? 'قيد المراجعة (Pending)' : 'Pending Review',
                  tone: AppStatusTone.warning,
                  animate: false,
                ),
                AppStatusBadge(
                  label: isAr ? 'ملغى (Void)' : 'Void',
                  tone: AppStatusTone.error,
                  animate: false,
                ),
                AppStatusBadge(
                  label: isAr ? 'مسودة (Draft)' : 'Draft',
                  tone: AppStatusTone.neutral,
                  animate: false,
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          // 4. Form Inputs & Toggles
          _buildSectionHeader(
            isAr ? 'حقول الإدخال والمفاتيح' : 'Form Inputs & Toggles',
          ),
          const SizedBox(height: AppSpacing.xs),
          AppCard(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppTextField(
                  label: isAr ? 'البيان المحاسبي' : 'Narration / Memo',
                  hint: isAr ? 'أدخل تفاصيل القيد...' : 'Enter voucher memo...',
                ),
                const SizedBox(height: AppSpacing.sm),
                AppNumberField(
                  label: isAr ? 'المبلغ المالي' : 'Monetary Amount',
                  value: _numberVal,
                  onChanged: (val) =>
                      setState(() => _numberVal = (val ?? 0).toDouble()),
                  allowDecimals: true,
                  prefix: Padding(
                    padding: const EdgeInsetsDirectional.only(
                      start: AppSpacing.sm,
                      end: AppSpacing.xs,
                    ),
                    child: Text(
                      'USD',
                      style: TextStyle(
                        color: colorScheme.mutedForeground,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    AppSwitch(
                      value: _switchVal,
                      onChanged: (v) => setState(() => _switchVal = v),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        isAr
                            ? 'ترحيل فوري إلى الأستاذ العام'
                            : 'Auto-post to General Ledger',
                        style: AppTypography.body(context),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    AppCheckbox(
                      value: _checkVal,
                      onChanged: (v) => setState(() => _checkVal = v ?? false),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        isAr
                            ? 'تأكيد احتساب الضريبة (15%)'
                            : 'Apply Standard Tax (15%)',
                        style: AppTypography.body(context),
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

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontFamily: AppTypography.fontFamilyName,
        fontSize: 14.0,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.2,
      ),
    );
  }

  Widget _buildTypeRow(
    String role,
    String sampleEn,
    String sampleAr,
    TextStyle style,
  ) {
    final text = widget.isArabic ? sampleAr : sampleEn;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            role,
            style: const TextStyle(
              fontSize: 11.0,
              color: AppColors.mutedTextLight,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(text, style: style),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 6.0),
      child: Divider(height: 1, thickness: 0.5),
    );
  }
}
