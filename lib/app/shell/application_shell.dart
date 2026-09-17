import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:nexabiz_ui/nexabiz_ui.dart';

/// Default shell navigation destinations matching NexaBiz ERP visual structure.
final List<AppNavItem> defaultShellNavItems = [
  const AppNavItem(
    label: 'Dashboard',
    icon: AppIcons.dashboard,
    routePath: '/dashboard',
  ),
  const AppNavItem(
    label: 'Services',
    icon: AppIcons.grid,
    routePath: '/services',
  ),
  const AppNavItem(
    label: 'Reports',
    icon: AppIcons.chart,
    routePath: '/reports',
  ),
  const AppNavItem(
    label: 'Settings',
    icon: AppIcons.settings,
    routePath: '/settings',
  ),
];

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

  List<AppNavItem> get _navItems =>
      widget.items.isNotEmpty ? widget.items : defaultShellNavItems;

  int get _selectedIndex {
    if (widget.navigationShell != null) {
      return widget.navigationShell!.currentIndex;
    }
    final cleanPath = widget.currentPath.split('?').first;
    for (var i = 0; i < _navItems.length; i++) {
      final p = _navItems[i].routePath;
      if (cleanPath == p || cleanPath.startsWith('$p/')) {
        return i;
      }
    }
    return 0;
  }

  void _onSelect(BuildContext context, int index) {
    if (index < 0 || index >= _navItems.length) return;
    if (_quickActionsOpen) {
      setState(() => _quickActionsOpen = false);
    }
    if (widget.navigationShell != null) {
      widget.navigationShell!.goBranch(
        index,
        initialLocation: index == widget.navigationShell!.currentIndex,
      );
    } else {
      final targetPath = _navItems[index].routePath;
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

    setState(() => _quickActionsOpen = true);
    AppQuickActionsPanel.show(
      context,
      title: 'Quick Actions',
      subtitle: 'Execute common business operations & developer tools',
      items: [
        AppQuickActionItem(
          label: 'Component Gallery',
          description: 'UI gallery & component playground',
          icon: AppIcons.grid,
          color: AppColors.accentPurple,
          onTap: () {
            setState(() => _quickActionsOpen = false);
            context.go('/gallery');
          },
        ),
        AppQuickActionItem(
          label: 'New Invoice',
          description: 'Create sales invoice',
          icon: AppIcons.receipt,
          color: AppColors.primaryBlue,
          onTap: () {
            setState(() => _quickActionsOpen = false);
            context.go('/services');
          },
        ),
        AppQuickActionItem(
          label: 'New Customer',
          description: 'Register customer account',
          icon: AppIcons.userAdd,
          color: AppColors.secondaryTeal,
          onTap: () {
            setState(() => _quickActionsOpen = false);
            context.go('/services');
          },
        ),
        AppQuickActionItem(
          label: 'Add Product',
          description: 'Inventory item entry',
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
    return AppResponsiveScaffold(
      currentIndex: _selectedIndex,
      onNavigationIndexChanged: (index) => _onSelect(context, index),
      extendBody: true,
      mobileBottomBar: AppCustomBottomNav(
        currentIndex: _selectedIndex,
        items: _navItems,
        onTap: (index) => _onSelect(context, index),
        onFabTap: () => _toggleQuickActions(context),
        isFabOpen: _quickActionsOpen,
        fabIcon: AppIcons.plus,
      ),
      body: widget.child,
    );
  }
}
