import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;
import '../../nexabiz_ui.dart';
import 'gallery_state_controller.dart';

/// Reusable card component for displaying an interactive preview,
/// live controls, description, and verified Dart code snippet for a component.
class GalleryPreviewCard extends StatefulWidget {
  final String name;
  final GalleryCategory category;
  final String description;
  final String usageNotes;
  final String dartCode;
  final Widget preview;
  final Widget? controls;

  const GalleryPreviewCard({
    super.key,
    required this.name,
    required this.category,
    required this.description,
    required this.usageNotes,
    required this.dartCode,
    required this.preview,
    this.controls,
  });

  @override
  State<GalleryPreviewCard> createState() => _GalleryPreviewCardState();
}

class _GalleryPreviewCardState extends State<GalleryPreviewCard> {
  bool _showCode = false;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row wrapped in responsive Wrap
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.xxs,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          widget.name,
                          style: AppTypography.sectionTitle(context),
                        ),
                        AppStatusBadge(
                          label: widget.category.label,
                          tone: AppStatusTone.info,
                          animate: false,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      widget.description,
                      style: AppTypography.caption(context),
                    ),
                  ],
                ),
              ),
              shadcn.OutlineButton(
                density: shadcn.ButtonDensity.compact,
                onPressed: () {
                  setState(() {
                    _showCode = !_showCode;
                  });
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(AppIcons.command, size: 14),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(_showCode ? 'Hide Code' : 'View Code'),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          const AppDivider(),
          const SizedBox(height: AppSpacing.md),
          // Preview Surface with fluid small-screen adaptation
          AppSurface(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Center(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minWidth: constraints.maxWidth > 0
                            ? constraints.maxWidth
                            : 0,
                      ),
                      child: Center(child: widget.preview),
                    ),
                  ),
                );
              },
            ),
          ),
          if (widget.controls != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppThemeController.isDark(context)
                    ? const Color(0xFF1E293B)
                    : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Interactive Controls',
                    style: AppTypography.label(context),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  widget.controls!,
                ],
              ),
            ),
          ],
          if (_showCode) ...[
            const SizedBox(height: AppSpacing.sm),
            AppCard(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Text(
                  widget.dartCode,
                  style: AppTypography.caption(context),
                ),
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.xs),
          Text(
            'NexaBiz Note: ${widget.usageNotes}',
            style: AppTypography.caption(context),
          ),
        ],
      ),
    );
  }
}
