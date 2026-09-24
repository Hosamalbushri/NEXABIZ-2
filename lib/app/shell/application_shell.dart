import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:nexabiz_ui/nexabiz_ui.dart';

import '../../l10n/app_localizations.dart';

/// Canonical application shell providing responsive layout adaptation across Mobile,
/// Tablet, and Desktop platforms using canonical `nexabiz_ui` primitives.
class ApplicationShell extends StatefulWidget {
  final Widget child;
  final String currentPath;
  final StatefulNavigationShell? navigationShell;
  final List<AppNavigationItem> items;

  const ApplicationShell({
    super.key,
    required this.child,
    required this.currentPath,
    this.navigationShell,
    this.items = const [],
  });

  @override
  State<ApplicationShell> createState() => _ApplicationShellState();
}

class _ApplicationShellState extends State<ApplicationShell> {
  bool _quickActionsOpen = false;

  List<AppNavigationItem> _getNavItems(BuildContext context) {
    if (widget.items.isNotEmpty) return widget.items;
    final l10n = AppLocalizations.of(context);
    return [
      AppNavigationItem(
        id: '/dashboard',
        label: l10n.navDashboard,
        icon: AppIcons.dashboard,
      ),
      AppNavigationItem(
        id: '/services',
        label: l10n.navServices,
        icon: AppIcons.grid,
      ),
      AppNavigationItem(
        id: '/reports',
        label: l10n.navReports,
        icon: AppIcons.chart,
      ),
      AppNavigationItem(
        id: '/settings',
        label: l10n.navSettings,
        icon: AppIcons.settings,
      ),
    ];
  }

  int _getSelectedIndex(List<AppNavigationItem> navItems) {
    if (widget.navigationShell != null) {
      return widget.navigationShell!.currentIndex;
    }
    final cleanPath = widget.currentPath.split('?').first;
    for (var i = 0; i < navItems.length; i++) {
      final p = navItems[i].id;
      if (cleanPath == p || cleanPath.startsWith('$p/')) {
        return i;
      }
    }
    return 0;
  }

  void _onSelect(
    BuildContext context,
    String id,
    List<AppNavigationItem> navItems,
  ) {
    final index = navItems.indexWhere((item) => item.id == id);
    if (index < 0 || index >= navItems.length) return;
    if (_quickActionsOpen) {
      setState(() => _quickActionsOpen = false);
    }
    if (widget.navigationShell != null) {
      widget.navigationShell!.goBranch(
        index,
        initialLocation: index == widget.navigationShell!.currentIndex,
      );
    } else {
      final targetPath = navItems[index].id;
      if (widget.currentPath != targetPath) {
        context.go(targetPath);
      }
    }
  }

  void _toggleQuickActions(BuildContext context) {
    if (_quickActionsOpen) {
      AppQuickActionsPanel.close(context);
      setState(() => _quickActionsOpen = false);
      return;
    }

    final l10n = AppLocalizations.of(context);

    setState(() => _quickActionsOpen = true);
    AppQuickActionsPanel.show<void>(
      context,
      title: l10n.quickActionsTitle,
      subtitle: l10n.quickActionsSubtitle,
      items: [
        AppQuickActionItem(
          label: l10n.quickActionMobilePlayground,
          description: l10n.quickActionMobilePlaygroundDesc,
          icon: AppIcons.layers,
          color: AppColors.primaryBlue,
          onTap: () {
            setState(() => _quickActionsOpen = false);
            context.push('/playground');
          },
        ),
        AppQuickActionItem(
          label: l10n.quickActionComponentGallery,
          description: l10n.quickActionComponentGalleryDesc,
          icon: AppIcons.grid,
          color: AppColors.accentPurple,
          onTap: () {
            setState(() => _quickActionsOpen = false);
            context.push('/gallery');
          },
        ),
        AppQuickActionItem(
          label: l10n.quickActionNewInvoice,
          description: l10n.quickActionNewInvoiceDesc,
          icon: AppIcons.receipt,
          color: AppColors.primaryBlue,
          onTap: () {
            setState(() => _quickActionsOpen = false);
            context.go('/services');
          },
        ),
        AppQuickActionItem(
          label: l10n.quickActionNewCustomer,
          description: l10n.quickActionNewCustomerDesc,
          icon: AppIcons.userAdd,
          color: AppColors.secondaryTeal,
          onTap: () {
            setState(() => _quickActionsOpen = false);
            context.go('/services');
          },
        ),
        AppQuickActionItem(
          label: l10n.quickActionAddProduct,
          description: l10n.quickActionAddProductDesc,
          icon: AppIcons.box,
          color: AppColors.accentPurple,
          onTap: () {
            setState(() => _quickActionsOpen = false);
            context.go('/services');
          },
        ),
      ],
    ).whenComplete(() {
      if (mounted) {
        setState(() => _quickActionsOpen = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final navItems = _getNavItems(context);
    final selectedIndex = _getSelectedIndex(navItems);
    final l10n = AppLocalizations.of(context);

    final sidebar = AppSidebar(
      header: AppCompanySwitcher(
        companyName: l10n.appName,
        branchName: l10n.mainBranch,
        onTap: () => context.push('/company-selection'),
      ),
      groups: [
        AppSidebarGroup(
          title: l10n.appName,
          items: [for (var i = 0; i < navItems.length; i++) navItems[i]],
        ),
      ],
      selectedId: navItems[selectedIndex].id,
      onSelected: (id) => _onSelect(context, id, navItems),
    );

    final topHeader = AppTopHeader(
      actions: [
        AppIconButton(
          variant: AppIconButtonVariant.ghost,
          icon: AppIcons.layers,
          tooltip: l10n.quickActionMobilePlayground,
          onPressed: () => context.push('/playground'),
        ),
        AppIconButton(
          variant: AppIconButtonVariant.ghost,
          icon: AppIcons.sparkles,
          tooltip: l10n.quickActionComponentGallery,
          onPressed: () => context.push('/gallery'),
        ),
        AppIconButton(
          variant: AppIconButtonVariant.ghost,
          icon: AppIcons.grid,
          tooltip: l10n.quickActionsTitle,
          onPressed: () => _toggleQuickActions(context),
        ),
      ],
    );

    return AppResponsiveScaffold(
      extendBody: true,
      sidebar: sidebar,
      topHeader: topHeader,
      mobileBottomBar: AppCustomBottomNav(
        selectedId: navItems[selectedIndex].id,
        items: navItems,
        onSelected: (id) => _onSelect(context, id, navItems),
        onFabTap: () => _toggleQuickActions(context),
        isFabOpen: _quickActionsOpen,
        fabIcon: AppIcons.plus,
        fabTooltip: l10n.quickActionsTitle,
      ),
      body: widget.child,
    );
  }
}
