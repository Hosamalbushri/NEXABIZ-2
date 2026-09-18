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
  final List<AppNavItem> items;

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

  List<AppNavItem> _getNavItems(BuildContext context) {
    if (widget.items.isNotEmpty) return widget.items;
    final l10n = AppLocalizations.of(context);
    return [
      AppNavItem(
        label: l10n.navDashboard,
        icon: AppIcons.dashboard,
        routePath: '/dashboard',
      ),
      AppNavItem(
        label: l10n.navServices,
        icon: AppIcons.grid,
        routePath: '/services',
      ),
      AppNavItem(
        label: l10n.navReports,
        icon: AppIcons.chart,
        routePath: '/reports',
      ),
      AppNavItem(
        label: l10n.navSettings,
        icon: AppIcons.settings,
        routePath: '/settings',
      ),
    ];
  }

  int _getSelectedIndex(List<AppNavItem> navItems) {
    if (widget.navigationShell != null) {
      return widget.navigationShell!.currentIndex;
    }
    final cleanPath = widget.currentPath.split('?').first;
    for (var i = 0; i < navItems.length; i++) {
      final p = navItems[i].routePath;
      if (cleanPath == p || cleanPath.startsWith('$p/')) {
        return i;
      }
    }
    return 0;
  }

  void _onSelect(BuildContext context, int index, List<AppNavItem> navItems) {
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
      final targetPath = navItems[index].routePath;
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

    return AppResponsiveScaffold(
      currentIndex: selectedIndex,
      onNavigationIndexChanged: (index) => _onSelect(context, index, navItems),
      extendBody: true,
      mobileBottomBar: AppCustomBottomNav(
        currentIndex: selectedIndex,
        items: navItems,
        onTap: (index) => _onSelect(context, index, navItems),
        onFabTap: () => _toggleQuickActions(context),
        isFabOpen: _quickActionsOpen,
        fabIcon: AppIcons.plus,
      ),
      body: widget.child,
    );
  }
}
