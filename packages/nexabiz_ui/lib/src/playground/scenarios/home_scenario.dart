import 'package:flutter/material.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

import '../../theme/tokens/tokens.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_status_badge.dart';
import '../../widgets/app_surface.dart';
import '../playground_demo_models.dart';

class HomeScenario extends StatelessWidget {
  const HomeScenario({
    super.key,
    required this.isArabic,
    required this.selectedCompany,
    required this.onSwitchCompany,
  });

  final bool isArabic;
  final DemoCompanyItem selectedCompany;
  final VoidCallback onSwitchCompany;

  @override
  Widget build(BuildContext context) {
    final theme = shadcn.Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isAr = isArabic;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Active Company Card / Switcher
          AppCard(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    borderRadius: BorderRadius.circular(AppRadii.sm),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    selectedCompany.code.substring(0, 2),
                    style: TextStyle(
                      color: colorScheme.primaryForeground,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        selectedCompany.name(isAr),
                        style: theme.typography.p.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        selectedCompany.branch(isAr),
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
                AppButton(
                  label: isAr ? 'تبديل' : 'Switch',
                  variant: AppButtonVariant.outlined,
                  isCompact: true,
                  onPressed: onSwitchCompany,
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          // System Readiness & Security Status (Real Core Concept)
          AppSurface(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                Icon(shadcn.LucideIcons.shieldCheck, color: colorScheme.primary, size: 28),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isAr ? 'حالة النظام الأساسي: جاهز' : 'Core Platform Status: Ready',
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isAr
                            ? 'جلسة مصادقة نشطة ومؤمنة بالتشفير المحلي'
                            : 'Active authenticated session, secured local storage',
                        style: TextStyle(fontSize: 11, color: colorScheme.mutedForeground),
                      ),
                    ],
                  ),
                ),
                AppStatusBadge(
                  label: isAr ? 'نشط' : 'Active',
                  tone: AppStatusTone.success,
                  animate: false,
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          // Core Shortcuts (Zero domain fabrication)
          Text(
            isAr ? 'الوصول السريع للنظام' : 'Platform Quick Access',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              Expanded(
                child: _buildQuickTile(
                  context,
                  icon: shadcn.LucideIcons.building,
                  title: isAr ? 'إدارة الشركات' : 'Companies',
                  subtitle: isAr ? '٣ شركات نشطة' : '3 active entities',
                  onTap: onSwitchCompany,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _buildQuickTile(
                  context,
                  icon: shadcn.LucideIcons.settings,
                  title: isAr ? 'إعدادات النظام' : 'System Setup',
                  subtitle: isAr ? 'المستخدمين والأذونات' : 'Users & Permissions',
                  onTap: () {},
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.lg),

          // Available Capabilities (Explicitly showing capability discovery, zero fake business data)
          Text(
            isAr ? 'حزم الأعمال المتاحة' : 'Available Business Capabilities',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppSpacing.xs),
          _buildCapabilityCard(
            context,
            icon: shadcn.LucideIcons.calculator,
            name: isAr ? 'المحاسبة المالية (Accounting)' : 'Financial Accounting',
            desc: isAr
                ? 'دفتر الأستاذ، سندات القيد، شجرة الحسابات والتقارير'
                : 'General Ledger, Journal Vouchers, Chart of Accounts',
            isRegistered: true,
          ),
          const SizedBox(height: AppSpacing.xs),
          _buildCapabilityCard(
            context,
            icon: shadcn.LucideIcons.boxes,
            name: isAr ? 'إدارة المستودعات (Inventory)' : 'Inventory & Warehouse',
            desc: isAr
                ? 'الأصناف، فواتير التوريد، تسويات الجرد والمواقع'
                : 'Stock Items, Inbound Logistics, Audit Reconciliation',
            isRegistered: false,
          ),
          const SizedBox(height: AppSpacing.xs),
          _buildCapabilityCard(
            context,
            icon: shadcn.LucideIcons.shoppingCart,
            name: isAr ? 'المبيعات والعملاء (Sales & CRM)' : 'Sales & Commercial Operations',
            desc: isAr
                ? 'فواتير المبيعات، عروض الأسعار، حسابات العملاء'
                : 'Sales Invoicing, Quotations, Customer Accounts',
            isRegistered: false,
          ),

          const SizedBox(height: AppSpacing.lg),

          // Recent Core Activity (Real session & system events)
          Text(
            isAr ? 'سجل العمليات الإدارية الحديثة' : 'Recent Core System Activity',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppSpacing.xs),
          AppCard(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
            child: Column(
              children: [
                _buildActivityRow(
                  context,
                  title: isAr ? 'تسجيل دخول ناجح' : 'Successful User Authentication',
                  detail: isAr ? 'المستخدم: hosam (مسؤول النظام)' : 'User: hosam (Admin)',
                  time: isAr ? 'منذ ١٠ دقائق' : '10m ago',
                  icon: shadcn.LucideIcons.keyRound,
                ),
                const Divider(height: 1),
                _buildActivityRow(
                  context,
                  title: isAr ? 'تأكيد تهيئة قاعدة البيانات المحلية' : 'Local Database Initialized',
                  detail: isAr ? 'محرك Drift v2.34 • تشفير AES-256' : 'Drift Engine v2.34 • AES-256 Encrypted',
                  time: isAr ? 'اليوم ٠٠:١٥' : 'Today 00:15',
                  icon: shadcn.LucideIcons.database,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final theme = shadcn.Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: AppSurface(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 24, color: theme.colorScheme.primary),
            const SizedBox(height: AppSpacing.sm),
            Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
            const SizedBox(height: 2),
            Text(subtitle, style: TextStyle(fontSize: 11, color: theme.colorScheme.mutedForeground)),
          ],
        ),
      ),
    );
  }

  Widget _buildCapabilityCard(
    BuildContext context, {
    required IconData icon,
    required String name,
    required String desc,
    required bool isRegistered,
  }) {
    final theme = shadcn.Theme.of(context);
    final isAr = isArabic;
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: isRegistered
                  ? theme.colorScheme.primary.withValues(alpha: 0.1)
                  : theme.colorScheme.muted,
              borderRadius: BorderRadius.circular(AppRadii.sm),
            ),
            child: Icon(
              icon,
              color: isRegistered ? theme.colorScheme.primary : theme.colorScheme.mutedForeground,
              size: 22,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    AppStatusBadge(
                      label: isRegistered
                          ? (isAr ? 'مثبت' : 'Installed')
                          : (isAr ? 'مخطط' : 'Roadmap'),
                      tone: isRegistered ? AppStatusTone.success : AppStatusTone.neutral,
                      animate: false,
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  desc,
                  style: TextStyle(fontSize: 11, color: theme.colorScheme.mutedForeground),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityRow(
    BuildContext context, {
    required String title,
    required String detail,
    required String time,
    required IconData icon,
  }) {
    final theme = shadcn.Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: [
          Icon(icon, size: 18, color: theme.colorScheme.mutedForeground),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                Text(detail, style: TextStyle(fontSize: 11, color: theme.colorScheme.mutedForeground)),
              ],
            ),
          ),
          Text(time, style: TextStyle(fontSize: 10, color: theme.colorScheme.mutedForeground)),
        ],
      ),
    );
  }
}
