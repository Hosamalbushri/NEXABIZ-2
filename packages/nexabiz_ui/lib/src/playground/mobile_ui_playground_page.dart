import 'package:flutter/material.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

import '../theme/app_theme.dart';
import '../theme/tokens/tokens.dart';
import 'playground_demo_models.dart';
import 'scenarios/bottom_actions_scenario.dart';
import 'scenarios/details_scenario.dart';
import 'scenarios/dialogs_scenario.dart';
import 'scenarios/filters_scenario.dart';
import 'scenarios/form_scenario.dart';
import 'scenarios/foundation_scenario.dart';
import 'scenarios/home_scenario.dart';
import 'scenarios/line_items_scenario.dart';
import 'scenarios/list_scenario.dart';
import 'scenarios/search_scenario.dart';
import 'scenarios/sheets_scenario.dart';
import 'scenarios/states_scenario.dart';
import 'scenarios/stepper_scenario.dart';
import 'scenarios/tree_scenario.dart';

enum PlaygroundScenario {
  foundation,
  home,
  list,
  details,
  form,
  lineItems,
  search,
  filters,
  sheets,
  dialogs,
  bottomActions,
  states,
  tree,
  stepper,
}

extension PlaygroundScenarioExtension on PlaygroundScenario {
  String label(bool isArabic) {
    switch (this) {
      case PlaygroundScenario.foundation:
        return isArabic ? '١. الأساس والطباعة' : '1. Foundation';
      case PlaygroundScenario.home:
        return isArabic ? '٢. واجهة النظام' : '2. Core Home';
      case PlaygroundScenario.list:
        return isArabic ? '٣. قائمة السندات' : '3. Voucher List';
      case PlaygroundScenario.details:
        return isArabic ? '٤. تفاصيل السند' : '4. Voucher Details';
      case PlaygroundScenario.form:
        return isArabic ? '٥. نموذج الإدخال' : '5. Voucher Form';
      case PlaygroundScenario.lineItems:
        return isArabic ? '٦. بنود القيد' : '6. Line Items';
      case PlaygroundScenario.search:
        return isArabic ? '٧. البحث الفوري' : '7. Search Flow';
      case PlaygroundScenario.filters:
        return isArabic ? '٨. المرشحات' : '8. Filters Sheet';
      case PlaygroundScenario.sheets:
        return isArabic ? '٩. الصفائح السفلية' : '9. Bottom Sheets';
      case PlaygroundScenario.dialogs:
        return isArabic ? '١٠. مربعات الحوار' : '10. Dialogs';
      case PlaygroundScenario.bottomActions:
        return isArabic ? '١١. الإجراءات السفلية' : '11. Bottom Actions';
      case PlaygroundScenario.states:
        return isArabic ? '١٢. حالات الشاشة' : '12. Screen States';
      case PlaygroundScenario.tree:
        return isArabic ? '١٣. إضافة شجرة' : '13. Tree Node Creation';
      case PlaygroundScenario.stepper:
        return isArabic ? '١٤. المعالج متعدد الخطوات' : '14. Multi-Step Stepper';
    }
  }

  IconData get icon {
    switch (this) {
      case PlaygroundScenario.foundation:
        return shadcn.LucideIcons.type;
      case PlaygroundScenario.home:
        return shadcn.LucideIcons.layoutGrid;
      case PlaygroundScenario.list:
        return shadcn.LucideIcons.list;
      case PlaygroundScenario.details:
        return shadcn.LucideIcons.fileText;
      case PlaygroundScenario.form:
        return shadcn.LucideIcons.pencil;
      case PlaygroundScenario.lineItems:
        return shadcn.LucideIcons.layers;
      case PlaygroundScenario.search:
        return shadcn.LucideIcons.search;
      case PlaygroundScenario.filters:
        return shadcn.LucideIcons.filter;
      case PlaygroundScenario.sheets:
        return shadcn.LucideIcons.panelBottom;
      case PlaygroundScenario.dialogs:
        return shadcn.LucideIcons.messageSquare;
      case PlaygroundScenario.bottomActions:
        return shadcn.LucideIcons.rectangleHorizontal;
      case PlaygroundScenario.states:
        return shadcn.LucideIcons.cpu;
      case PlaygroundScenario.tree:
        return shadcn.LucideIcons.gitFork;
      case PlaygroundScenario.stepper:
        return shadcn.LucideIcons.listOrdered;
    }
  }
}

/// Isolated Interactive Mobile UI Playground for NexaBiz ERP.
///
/// Provides live responsive testing across 320–430px mobile viewports,
/// Arabic (RTL) / English (LTR) toggling, light / dark themes, and
/// 11 dedicated business scenarios.
class MobileUiPlaygroundPage extends StatefulWidget {
  const MobileUiPlaygroundPage({
    super.key,
    this.initialScenario = PlaygroundScenario.foundation,
    this.initialArabic = true,
    this.initialDark = false,
    this.initialWidth = 375.0,
  });

  final PlaygroundScenario initialScenario;
  final bool initialArabic;
  final bool initialDark;
  final double? initialWidth;

  @override
  State<MobileUiPlaygroundPage> createState() => _MobileUiPlaygroundPageState();
}

class _MobileUiPlaygroundPageState extends State<MobileUiPlaygroundPage> {
  late PlaygroundScenario _currentScenario;
  late bool _isArabic;
  late bool _isDark;
  late double? _targetWidth;
  DemoCompanyItem _selectedCompany = PlaygroundFixtures.companies.first;
  DemoVoucherItem? _selectedVoucher;

  static const List<double?> _widthOptions = [
    320.0,
    360.0,
    375.0,
    390.0,
    412.0,
    430.0,
    600.0,
    null,
  ];

  @override
  void initState() {
    super.initState();
    _currentScenario = widget.initialScenario;
    _isArabic = widget.initialArabic;
    _isDark = widget.initialDark;
    _targetWidth = widget.initialWidth;
  }

  void _switchCompany() {
    final companies = PlaygroundFixtures.companies;
    final currentIndex = companies.indexOf(_selectedCompany);
    final nextIndex = (currentIndex + 1) % companies.length;
    setState(() {
      _selectedCompany = companies[nextIndex];
    });
  }

  @override
  Widget build(BuildContext context) {
    final activeTheme = _isDark ? AppTheme.dark() : AppTheme.light();

    return Scaffold(
      backgroundColor: _isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
      body: SafeArea(
        child: Column(
          children: [
            // Top Global Playground Navigation / Control Toolbar
            _buildPlaygroundToolbar(),

            // Viewport Simulation Area
            Expanded(
              child: Center(
                child: _buildDeviceViewport(activeTheme),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaygroundToolbar() {
    final isAr = _isArabic;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: _isDark ? const Color(0xFF1E293B) : Colors.white,
        border: Border(
          bottom: BorderSide(
            color: _isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
          ),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Row 1: Brand & Toggles
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                // Playground Identity
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue,
                        borderRadius: BorderRadius.circular(AppRadii.xs),
                      ),
                      child: const Icon(shadcn.LucideIcons.smartphone, size: 16, color: Colors.white),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          isAr ? 'بيئة المعاينة المحمولة' : 'Mobile UI Playground',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            fontFamily: 'Cairo',
                          ),
                        ),
                        Text(
                          'Cairo • shadcn_flutter • Phone-First',
                          style: TextStyle(
                            fontSize: 10,
                            color: _isDark ? Colors.white54 : Colors.black54,
                            fontFamily: 'Cairo',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(width: AppSpacing.md),

                // Locale Switcher (AR / EN)
                _buildControlChip(
                  label: _isArabic ? 'عربي (RTL)' : 'English (LTR)',
                  icon: shadcn.LucideIcons.globe,
                  isSelected: true,
                  onTap: () => setState(() => _isArabic = !_isArabic),
                ),

                const SizedBox(width: AppSpacing.xs),

                // Theme Switcher (Dark / Light)
                _buildControlChip(
                  label: _isDark ? 'Dark' : 'Light',
                  icon: _isDark ? shadcn.LucideIcons.moon : shadcn.LucideIcons.sun,
                  isSelected: _isDark,
                  onTap: () => setState(() => _isDark = !_isDark),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.xs),

          // Row 2: Scenario Horizontal Picker
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: PlaygroundScenario.values.map((sc) {
                final isSelected = _currentScenario == sc;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2.0),
                  child: GestureDetector(
                    onTap: () => setState(() => _currentScenario = sc),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primaryBlue
                            : (_isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9)),
                        borderRadius: BorderRadius.circular(AppRadii.xs),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            sc.icon,
                            size: 13,
                            color: isSelected ? Colors.white : (_isDark ? Colors.white70 : Colors.black87),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            sc.label(isAr),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              color: isSelected ? Colors.white : (_isDark ? Colors.white70 : Colors.black87),
                              fontFamily: 'Cairo',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: AppSpacing.xs),

          // Row 3: Responsive Width Matrix
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                Text(
                  isAr ? 'عرض الشاشة:' : 'Viewport Width:',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: _isDark ? Colors.white60 : Colors.black54,
                    fontFamily: 'Cairo',
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                ..._widthOptions.map((w) {
                  final isSelected = _targetWidth == w;
                  final label = w == null ? 'Full' : '${w.toInt()}px';
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2.0),
                    child: GestureDetector(
                      onTap: () => setState(() => _targetWidth = w),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primaryBlue
                              : (_isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          label,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected ? Colors.white : (_isDark ? Colors.white70 : Colors.black87),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlChip({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: _isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(AppRadii.xs),
          border: Border.all(
            color: _isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: _isDark ? Colors.white70 : Colors.black87),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: _isDark ? Colors.white70 : Colors.black87,
                fontFamily: 'Cairo',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeviceViewport(shadcn.ThemeData activeTheme) {
    final content = shadcn.Theme(
      data: activeTheme,
      child: Directionality(
        textDirection: _isArabic ? TextDirection.rtl : TextDirection.ltr,
        child: _buildScenarioContent(),
      ),
    );

    if (_targetWidth == null) {
      return Container(
        color: activeTheme.colorScheme.background,
        child: content,
      );
    }

    return Container(
      width: _targetWidth,
      margin: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: activeTheme.colorScheme.background,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(
          color: _isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
          width: 2.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Mobile Status Bar Mock
          Container(
            height: 24,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            color: activeTheme.colorScheme.card,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '09:41',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${_targetWidth!.toInt()}px',
                      style: TextStyle(
                        fontSize: 9,
                        color: activeTheme.colorScheme.mutedForeground,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(shadcn.LucideIcons.wifi, size: 10),
                    const SizedBox(width: 4),
                    const Icon(shadcn.LucideIcons.batteryMedium, size: 10),
                  ],
                ),
              ],
            ),
          ),
          // Content inside simulated screen
          Expanded(child: content),
        ],
      ),
    );
  }

  Widget _buildScenarioContent() {
    switch (_currentScenario) {
      case PlaygroundScenario.foundation:
        return FoundationScenario(isArabic: _isArabic);
      case PlaygroundScenario.home:
        return HomeScenario(
          isArabic: _isArabic,
          selectedCompany: _selectedCompany,
          onSwitchCompany: _switchCompany,
        );
      case PlaygroundScenario.list:
        return ListScenario(
          isArabic: _isArabic,
          onSelectVoucher: (v) {
            setState(() {
              _selectedVoucher = v;
              _currentScenario = PlaygroundScenario.details;
            });
          },
        );
      case PlaygroundScenario.details:
        return DetailsScenario(
          isArabic: _isArabic,
          voucher: _selectedVoucher,
        );
      case PlaygroundScenario.form:
        return FormScenario(isArabic: _isArabic);
      case PlaygroundScenario.lineItems:
        return LineItemsScenario(isArabic: _isArabic);
      case PlaygroundScenario.search:
        return SearchScenario(isArabic: _isArabic);
      case PlaygroundScenario.filters:
        return FiltersScenario(isArabic: _isArabic);
      case PlaygroundScenario.sheets:
        return SheetsScenario(isArabic: _isArabic);
      case PlaygroundScenario.dialogs:
        return DialogsScenario(isArabic: _isArabic);
      case PlaygroundScenario.bottomActions:
        return BottomActionsScenario(isArabic: _isArabic);
      case PlaygroundScenario.states:
        return StatesScenario(isArabic: _isArabic);
      case PlaygroundScenario.tree:
        return TreeScenario(isArabic: _isArabic);
      case PlaygroundScenario.stepper:
        return StepperScenario(isArabic: _isArabic);
    }
  }
}

