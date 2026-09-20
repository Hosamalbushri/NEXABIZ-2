import 'package:flutter/material.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

import '../../theme/tokens/tokens.dart';
import '../../widgets/app_amount_field.dart';
import '../../widgets/app_date_field.dart';
import '../../widgets/app_dropdown.dart';
import '../../widgets/app_form.dart';
import '../../widgets/app_form_actions.dart';
import '../../widgets/app_text_field.dart';
import '../playground_demo_models.dart';

class FormScenario extends StatefulWidget {
  const FormScenario({super.key, required this.isArabic});

  final bool isArabic;

  @override
  State<FormScenario> createState() => _FormScenarioState();
}

class _FormScenarioState extends State<FormScenario> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _codeController = TextEditingController(
    text: 'JV-2026-006',
  );
  final TextEditingController _memoController = TextEditingController();
  final TextEditingController _amountController = TextEditingController(text: '2500.00');

  DateTime? _selectedDate = DateTime(2026, 3, 20);
  String? _selectedAccountCode = '101001';
  String _selectedCurrency = 'SAR';
  final bool _isDebit = true;
  String? _amountError;
  String? _accountError;

  @override
  void dispose() {
    _codeController.dispose();
    _memoController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _validateAndSubmit() {
    final amountVal = double.tryParse(_amountController.text) ?? 0;
    setState(() {
      _amountError = amountVal <= 0
          ? (widget.isArabic
                ? 'المبلغ يجب أن يكون أكبر من الصفر'
                : 'Amount must be greater than zero')
          : null;
      _accountError = _selectedAccountCode == null
          ? (widget.isArabic
                ? 'يرجى اختيار الحساب'
                : 'Account selection is required')
          : null;
    });

    if (_amountError == null && _accountError == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.isArabic
                ? 'تم حفظ مسودة القيد بنجاح!'
                : 'Voucher draft saved successfully!',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAr = widget.isArabic;
    final theme = shadcn.Theme.of(context);
    final colorScheme = theme.colorScheme;
    final accounts = PlaygroundFixtures.accounts;

    return Column(
      children: [
        Expanded(
          child: AppForm(
            formKey: _formKey,
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
                // 1. Header info
                Text(
                  isAr ? 'إنشاء قيد يومية جديد' : 'New Journal Voucher',
                  style: theme.typography.h3.copyWith(
                    fontFamily: AppTypography.fontFamilyName,
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ),
                ),
                  const SizedBox(height: 2),
                  Text(
                    isAr
                        ? 'نموذج مستمر بدون بطاقات متداخلة متوافق مع شاشات الجوال'
                        : 'Calm continuous mobile form layout without nested cards',
                    style: theme.typography.small.copyWith(
                      color: colorScheme.mutedForeground,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // 2. Section 1: Header Details
                  AppFormSection(
                    title: isAr ? 'معلومات السند' : 'Voucher Details',
                    description: isAr ? 'البيانات الأساسية ورقم القيد' : 'Voucher metadata & code',
                    icon: shadcn.LucideIcons.fileText,
                    children: [
                      AppTextField(
                        label: isAr ? 'رقم السند' : 'Voucher Number',
                        controller: _codeController,
                        readOnly: true,
                        prefixIcon: Icon(
                          shadcn.LucideIcons.hash,
                          size: 16,
                          color: colorScheme.mutedForeground,
                        ),
                      ),
                      AppDateField(
                        label: isAr ? 'تاريخ القيد' : 'Voucher Date',
                        value: _selectedDate,
                        onChanged: (d) => setState(() => _selectedDate = d),
                      ),
                      AppDropdown<String>(
                        label: isAr ? 'العملة' : 'Currency',
                        value: _selectedCurrency,
                        items: const [
                          AppDropdownItem(
                            value: 'SAR',
                            label: 'SAR - Saudi Riyal (ر.س)',
                          ),
                          AppDropdownItem(
                            value: 'USD',
                            label: 'USD - US Dollar (\$)',
                          ),
                          AppDropdownItem(
                            value: 'AED',
                            label: 'AED - UAE Dirham (د.إ)',
                          ),
                        ],
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedCurrency = val);
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.md),

                  // 3. Section 2: Financial Values
                  AppFormSection(
                    title: isAr ? 'بيانات الحساب والمبلغ' : 'Account & Amount',
                    description: isAr ? 'حساب الأستاذ والمبلغ المالي' : 'Ledger account & financial entry',
                    icon: shadcn.LucideIcons.wallet,
                    children: [
                      AppDropdown<String>(
                        label: isAr ? 'الحساب المالي' : 'Ledger Account',
                        value: _selectedAccountCode,
                        errorText: _accountError,
                        items: accounts.map((acc) {
                          return AppDropdownItem(
                            value: acc.code,
                            label: '${acc.code} - ${acc.name(isAr)}',
                          );
                        }).toList(),
                        onChanged: (val) => setState(() {
                          _selectedAccountCode = val;
                          _accountError = null;
                        }),
                      ),
                      AppAmountField(
                        label: isAr ? 'المبلغ المالي' : 'Transaction Amount',
                        controller: _amountController,
                        currencySymbol: _selectedCurrency,
                        isDebit: _isDebit,
                        errorText: _amountError,
                        required: true,
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.md),

                  // 4. Section 3: Memo & Narration
                  AppFormSection(
                    title: isAr ? 'البيان والملاحظات' : 'Narration & Memo',
                    icon: shadcn.LucideIcons.messageSquare,
                    children: [
                      AppTextField(
                        label: isAr ? 'شرح القيد' : 'Narration',
                        controller: _memoController,
                        maxLines: 3,
                        hint: isAr
                            ? 'أدخل بياناً توضيحياً لحركة القيد المحاسبي...'
                            : 'Enter narration description for audit ledger...',
                      ),
                    ],
                  ),
                ],
              ),
          ),

        // Sticky Bottom Actions Integration
        AppFormActions(
          submitLabel: isAr ? 'حفظ القيد' : 'Save Voucher',
          cancelLabel: isAr ? 'إلغاء' : 'Cancel',
          onSubmit: _validateAndSubmit,
          onCancel: () {
            setState(() {
              _memoController.clear();
              _amountController.text = '0.00';
            });
          },
        ),
      ],
    );
  }
}
