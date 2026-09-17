import 'package:flutter/material.dart';
import '../theme/tokens/app_colors.dart';
import '../theme/tokens/app_spacing.dart';

/// Floating, draggable quick navigation overlay pill for sub-routes.
class AppDraggableQuickNav extends StatefulWidget {
  final VoidCallback onHomeTap;
  final VoidCallback onQuickActionsTap;
  final VoidCallback onBackTap;
  final Offset initialPosition;

  const AppDraggableQuickNav({
    super.key,
    required this.onHomeTap,
    required this.onQuickActionsTap,
    required this.onBackTap,
    this.initialPosition = const Offset(16, 120),
  });

  @override
  State<AppDraggableQuickNav> createState() => _AppDraggableQuickNavState();
}

class _AppDraggableQuickNavState extends State<AppDraggableQuickNav> {
  late Offset _offset;

  @override
  void initState() {
    super.initState();
    _offset = widget.initialPosition;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = (isDark ? AppColors.darkSurface : AppColors.lightSurface)
        .withValues(alpha: 0.92);

    return Positioned(
      left: _offset.dx,
      top: _offset.dy,
      child: GestureDetector(
        onPanUpdate: (details) {
          final size = MediaQuery.of(context).size;
          setState(() {
            _offset = Offset(
              (_offset.dx + details.delta.dx).clamp(8.0, size.width - 160.0),
              (_offset.dy + details.delta.dy).clamp(40.0, size.height - 100.0),
            );
          });
        },
        child: Material(
          elevation: 6,
          color: backgroundColor,
          borderRadius: BorderRadius.circular(24),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs, vertical: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_rounded, size: 18),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  onPressed: widget.onBackTap,
                  tooltip: 'Back',
                ),
                Container(
                  width: 1,
                  height: 16,
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                ),
                IconButton(
                  icon: const Icon(Icons.dashboard_rounded, size: 18),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  onPressed: widget.onHomeTap,
                  tooltip: 'Dashboard',
                ),
                Container(
                  width: 1,
                  height: 16,
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                ),
                IconButton(
                  icon: const Icon(Icons.flash_on_rounded, size: 18, color: AppColors.primaryBlue),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  onPressed: widget.onQuickActionsTap,
                  tooltip: 'Quick Actions',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
