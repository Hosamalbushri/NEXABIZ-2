import 'package:flutter/material.dart';
export 'package:flutter/material.dart' show FloatingActionButtonLocation;
import '../../constants/app_constants.dart';
import 'app_responsive.dart';


/// Standardized responsive scaffold container with desktop content constraints,
/// mobile bottom bar, and keyboard-aware bottom action bar support.
class AppResponsiveScaffold extends StatelessWidget {
  const AppResponsiveScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.sidebar,
    this.topHeader,
    this.showSidebar,
    this.bottomActions,
    this.mobileBottomBar,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.extendBody = false,
    this.currentIndex,
    this.onNavigationIndexChanged,
    this.maxContentWidth = AppConstants.maxContentWidth,
    this.resizeToAvoidBottomInset = true,
    this.backgroundColor,
  });

  final PreferredSizeWidget? appBar;
  final Widget body;
  final Widget? sidebar;
  final Widget? topHeader;
  final bool? showSidebar;
  final Widget? bottomActions;
  final Widget? mobileBottomBar;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final bool extendBody;
  final int? currentIndex;
  final ValueChanged<int>? onNavigationIndexChanged;
  final double maxContentWidth;
  final bool resizeToAvoidBottomInset;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      extendBody: extendBody,
      appBar: appBar,
      body: SafeArea(
        top: false,
        bottom: bottomActions == null && mobileBottomBar == null,
        child: Column(
          children: [
            Expanded(
              child: AppContentConstraint(
                maxWidth: maxContentWidth,
                child: body,
              ),
            ),
            ?bottomActions,
          ],
        ),
      ),
      bottomNavigationBar: mobileBottomBar,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
    );
  }
}
