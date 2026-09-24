import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;
import '../../nexabiz_ui.dart';
import 'gallery_state_controller.dart';
import 'sections/gallery_actions_playground.dart';
import 'sections/gallery_data_playground.dart';
import 'sections/gallery_datetime_playground.dart';
import 'sections/gallery_feedback_playground.dart';
import 'sections/gallery_forms_playground.dart';
import 'sections/gallery_layout_playground.dart';
import 'sections/gallery_navigation_playground.dart';
import 'sections/gallery_overlays_playground.dart';

/// Top-level interactive Component Gallery & Playground page for NexaBiz UI.
class ComponentGalleryPage extends StatefulWidget {
  const ComponentGalleryPage({super.key});

  @override
  State<ComponentGalleryPage> createState() => _ComponentGalleryPageState();
}

class _ComponentGalleryPageState extends State<ComponentGalleryPage> {
  late final GalleryStateController _controller;

  @override
  void initState() {
    super.initState();
    _controller = GalleryStateController();
    _controller.addListener(_onStateChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onStateChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onStateChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: _controller.directionality,
      child: AppResponsiveScaffold(
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: AppContainer.page(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Page Header
                AppPageHeader(
                  title: 'Shadcn Flutter Component Gallery & Playground',
                  subtitle:
                      'Interactive design-system reference, live property tuning, RTL/LTR & responsive testing environment',
                  breadcrumbs: const [
                    'Developer Tools',
                    'Design System',
                    'Gallery',
                  ],
                  actions: [
                    shadcn.OutlineButton(
                      onPressed: () => _controller.toggleDirectionality(),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(AppIcons.globe, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            _controller.directionality == TextDirection.rtl
                                ? 'LTR Mode'
                                : 'RTL Mode',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),

                // Control Toolbar (Search, Viewport, Category Filter)
                AppCard(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: AppTextField(
                              hint: 'Search components by name or keyword...',
                              prefixIcon: const Icon(AppIcons.search, size: 16),
                              onChanged: (query) =>
                                  _controller.setSearchQuery(query),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          SizedBox(
                            width: 180,
                            child: AppSelectField<GalleryViewportSize>(
                              value: _controller.viewportSize,
                              onChanged: (val) {
                                if (val != null) {
                                  _controller.setViewportSize(val);
                                }
                              },
                              items: GalleryViewportSize.values
                                  .map(
                                    (sz) => AppSelectOption(
                                      value: sz,
                                      label: sz.label,
                                    ),
                                  )
                                  .toList(),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),

                      // Category Filter Chips
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: GalleryCategory.values.map((cat) {
                            final isSelected =
                                _controller.selectedCategory == cat;
                            return Padding(
                              padding: const EdgeInsets.only(
                                right: AppSpacing.xs,
                              ),
                              child: shadcn.GhostButton(
                                onPressed: () => _controller.setCategory(cat),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.sm,
                                    vertical: AppSpacing.xxs,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? AppColors.primaryBlue.withValues(
                                            alpha: 0.15,
                                          )
                                        : null,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        cat.icon,
                                        size: 14,
                                        color: isSelected
                                            ? AppColors.primaryBlue
                                            : null,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        cat.label,
                                        style: isSelected
                                            ? AppTypography.bodyBold(
                                                context,
                                              ).copyWith(
                                                color: AppColors.primaryBlue,
                                              )
                                            : AppTypography.body(context),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                // Simulated Viewport Container
                _buildViewportWrapper(
                  context,
                  child: Column(
                    children: [
                      GalleryFormsPlayground(controller: _controller),
                      GalleryActionsPlayground(controller: _controller),
                      GalleryFeedbackPlayground(controller: _controller),
                      GalleryOverlaysPlayground(controller: _controller),
                      GalleryLayoutPlayground(controller: _controller),
                      GalleryDataPlayground(controller: _controller),
                      GalleryNavigationPlayground(controller: _controller),
                      GalleryDateTimePlayground(controller: _controller),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildViewportWrapper(BuildContext context, {required Widget child}) {
    if (_controller.viewportSize == GalleryViewportSize.auto) {
      return child;
    }
    return Center(
      child: Container(
        width: _controller.viewportSize.width,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.primaryBlue, width: 2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Container(
              color: AppColors.primaryBlue,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: 4,
              ),
              child: Row(
                children: [
                  const Icon(
                    AppIcons.box,
                    size: 14,
                    color: AppColors.lightSurface,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Simulated Viewport: ${_controller.viewportSize.label}',
                    style: AppTypography.caption(
                      context,
                    ).copyWith(color: AppColors.lightSurface),
                  ),
                ],
              ),
            ),
            child,
          ],
        ),
      ),
    );
  }
}
