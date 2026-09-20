import 'package:flutter/material.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

import '../../theme/tokens/tokens.dart';
import '../../widgets/app_dropdown.dart';
import '../../widgets/app_form.dart';
import '../../widgets/app_stepper.dart';
import '../../widgets/app_switch.dart';
import '../../widgets/app_text_field.dart';

class StepperScenario extends StatefulWidget {
  const StepperScenario({super.key, required this.isArabic});

  final bool isArabic;

  @override
  State<StepperScenario> createState() => _StepperScenarioState();
}

class _StepperScenarioState extends State<StepperScenario> {
  int _currentStep = 0;
  bool _isSubmitting = false;

  // Form Controllers
  final _companyNameController = TextEditingController(text: 'شركة الأمل للتجارة');
  final _crNumberController = TextEditingController(text: '1010892019');
  final _taxNumberController = TextEditingController(text: '310928102900003');
  String _selectedCurrency = 'SAR';
  String _fiscalYearStart = '01-01';
  bool _agreeTerms = true;

  @override
  void dispose() {
    _companyNameController.dispose();
    _crNumberController.dispose();
    _taxNumberController.dispose();
    super.dispose();
  }

  void _handleComplete() {
    final isAr = widget.isArabic;
    setState(() => _isSubmitting = true);

    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      setState(() => _isSubmitting = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isAr
                ? 'تم إكمال معالج تهيئة المؤسسة بنجاح!'
                : 'Enterprise Onboarding Wizard completed successfully!',
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final isAr = widget.isArabic;
    final theme = shadcn.Theme.of(context);
    final colorScheme = theme.colorScheme;

    final steps = [
      // Step 1: Enterprise Info
      AppStepItem(
        title: Text(isAr ? 'بيانات المؤسسة' : 'Company Info'),
        icon: const Icon(shadcn.LucideIcons.building, size: 16),
        contentBuilder: (ctx) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              isAr ? 'الخطوة الأولى: المعلومات الأساسية للمؤسسة' : 'Step 1: Basic Enterprise Information',
              style: theme.typography.p.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              label: isAr ? 'اسم المنشأة / الشركة' : 'Company Name',
              controller: _companyNameController,
              required: true,
              hint: isAr ? 'أدخل اسم الشركة' : 'Enter company name',
            ),
            const SizedBox(height: AppSpacing.md),
            AppFormRow(
              children: [
                AppTextField(
                  label: isAr ? 'السجل التجاري' : 'CR Number',
                  controller: _crNumberController,
                  required: true,
                  hint: '1010892019',
                ),
                AppTextField(
                  label: isAr ? 'الرقم الضريبي' : 'Tax Registration ID',
                  controller: _taxNumberController,
                  required: true,
                  hint: '310928102900003',
                ),
              ],
            ),
          ],
        ),
      ),

      // Step 2: Financial Settings
      AppStepItem(
        title: Text(isAr ? 'الإعدادات المالية' : 'Financial Settings'),
        icon: const Icon(shadcn.LucideIcons.landmark, size: 16),
        contentBuilder: (ctx) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              isAr ? 'الخطوة الثانية: العملة وبداية السنة المالية' : 'Step 2: Currency & Fiscal Period',
              style: theme.typography.p.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            AppFormRow(
              children: [
                AppDropdown<String>(
                  label: isAr ? 'العملة الرئيسية' : 'Base Currency',
                  value: _selectedCurrency,
                  items: const [
                    AppDropdownItem(value: 'SAR', label: 'SAR - ريال سعودي'),
                    AppDropdownItem(value: 'USD', label: 'USD - دولار أمريكي'),
                    AppDropdownItem(value: 'AED', label: 'AED - درهم إماراتي'),
                  ],
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedCurrency = val);
                  },
                ),
                AppDropdown<String>(
                  label: isAr ? 'بداية السنة المالية' : 'Fiscal Year Start',
                  value: _fiscalYearStart,
                  items: [
                    AppDropdownItem(
                      value: '01-01',
                      label: isAr ? '١ يناير (تقويم ميلادي)' : 'Jan 1st (Gregorian)',
                    ),
                    AppDropdownItem(
                      value: '01-07',
                      label: isAr ? '١ يوليو (نصف سنوي)' : 'Jul 1st (Mid-year)',
                    ),
                  ],
                  onChanged: (val) {
                    if (val != null) setState(() => _fiscalYearStart = val);
                  },
                ),
              ],
            ),
          ],
        ),
      ),

      // Step 3: Confirmation
      AppStepItem(
        title: Text(isAr ? 'التأكيد والتفعيل' : 'Confirmation'),
        icon: const Icon(shadcn.LucideIcons.circleCheck, size: 16),
        contentBuilder: (ctx) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              isAr ? 'الخطوة الثالثة: مراجعة البيانات والتأكيد' : 'Step 3: Review & Final Confirmation',
              style: theme.typography.p.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: colorScheme.muted.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(theme.radiusMd),
                border: Border.all(color: colorScheme.border.withValues(alpha: 0.4)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(isAr ? 'اسم المنشأة:' : 'Company:', style: const TextStyle(fontWeight: FontWeight.w500)),
                      Text(_companyNameController.text, style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(isAr ? 'السجل التجاري:' : 'CR Number:', style: const TextStyle(fontWeight: FontWeight.w500)),
                      Text(_crNumberController.text),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(isAr ? 'العملة الرئيسية:' : 'Base Currency:', style: const TextStyle(fontWeight: FontWeight.w500)),
                      Text(_selectedCurrency, style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            AppSwitch(
              label: isAr ? 'الموافقة على شروط تفعيل النظام والتكافؤ المالي' : 'Agree to system activation terms & compliance',
              value: _agreeTerms,
              onChanged: (val) => setState(() => _agreeTerms = val),
            ),
          ],
        ),
      ),
    ];

    return Column(
      children: [
        // Scenario Title Bar
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: colorScheme.card,
            border: Border(
              bottom: BorderSide(
                color: colorScheme.border.withValues(alpha: 0.4),
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isAr ? 'معالج التهيئة متعدد الخطوات (AppStepper)' : 'Multi-Step Onboarding Stepper Flow',
                style: theme.typography.h4.copyWith(
                  fontFamily: AppTypography.fontFamilyName,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                isAr
                    ? 'إدارة الخطوات والتنقل المتسلسل بين المراحل بنمط شاشات الجوال'
                    : 'Manage step lifecycle and sequential form flow for mobile',
                style: theme.typography.small.copyWith(
                  color: colorScheme.mutedForeground,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),

        // Stepper Interactive View
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: AppStepper(
              steps: steps,
              currentStep: _currentStep,
              onStepChanged: (step) => setState(() => _currentStep = step),
              onComplete: _handleComplete,
              isSubmitting: _isSubmitting,
              nextLabel: isAr ? 'التالي' : 'Next',
              previousLabel: isAr ? 'السابق' : 'Previous',
              completeLabel: isAr ? 'تأكيد وإكمال' : 'Complete Setup',
            ),
          ),
        ),
      ],
    );
  }
}
