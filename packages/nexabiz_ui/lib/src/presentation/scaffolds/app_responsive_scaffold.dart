import 'package:flutter/material.dart';
export 'package:flutter/material.dart' show FloatingActionButtonLocation;
import '../../layout/layout.dart';

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
    this.maxContentWidth = AppLayoutTokens.maxPageWidth,
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
  final double maxContentWidth;
  final bool resizeToAvoidBottomInset;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return AppResponsive.builder(
      builder: (context, tier, constraints) {
        final desktop =
            tier == AppBreakpointTier.expanded ||
            tier == AppBreakpointTier.wide;
        final displaySidebar = showSidebar ?? desktop;
        final content = Column(
          children: [
            if (desktop) ?topHeader,
            Expanded(
              child: AppContentConstraint(
                maxWidth: maxContentWidth,
                child: body,
              ),
            ),
            ?bottomActions,
          ],
        );

        return Scaffold(
          backgroundColor: backgroundColor,
          resizeToAvoidBottomInset: resizeToAvoidBottomInset,
          extendBody: extendBody,
          appBar: appBar,
          body: SafeArea(
            top: false,
            bottom:
                bottomActions == null && (!desktop && mobileBottomBar == null),
            child: Row(
              children: [
                if (displaySidebar) ?sidebar,
                Expanded(child: content),
              ],
            ),
          ),
          bottomNavigationBar: desktop ? null : mobileBottomBar,
          floatingActionButton: floatingActionButton,
          floatingActionButtonLocation: floatingActionButtonLocation,
        );
      },
    );
  }
}
