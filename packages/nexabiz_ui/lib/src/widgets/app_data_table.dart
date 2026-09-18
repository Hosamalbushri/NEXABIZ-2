import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

import '../theme/app_breakpoints.dart';
import '../theme/app_spacing.dart';
import 'app_card.dart';
import 'app_empty_state.dart';
import 'app_loading.dart';

/// Column descriptor for [AppDataTable].
class AppTableColumn {
  const AppTableColumn({
    required this.label,
    this.tooltip,
    this.numeric = false,
  });

  final Widget label;
  final String? tooltip;
  final bool numeric;
}

/// Standardized responsive table widget supporting desktop `shadcn_flutter` Table
/// and mobile card list fallback with optional expandable row details.
class AppDataTable<T> extends StatefulWidget {
  const AppDataTable({
    super.key,
    required this.items,
    required this.columns,
    required this.rowBuilder,
    required this.cardBuilder,
    this.expandableCardBuilder,
    this.isLoading = false,
    this.emptyState,
    this.title,
    this.actions,
    this.onRowTap,
    this.minWidth = 700.0,
  });

  final List<T> items;
  final List<AppTableColumn> columns;
  final List<Widget> Function(T item) rowBuilder;
  final Widget Function(BuildContext context, T item) cardBuilder;
  final Widget Function(BuildContext context, T item)? expandableCardBuilder;
  final bool isLoading;
  final Widget? emptyState;
  final String? title;
  final List<Widget>? actions;
  final ValueChanged<T>? onRowTap;
  final double minWidth;

  @override
  State<AppDataTable<T>> createState() => _AppDataTableState<T>();
}

class _AppDataTableState<T> extends State<AppDataTable<T>> {
  final Set<int> _expandedIndices = {};

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading) {
      return const AppLoading();
    }

    if (widget.items.isEmpty) {
      return widget.emptyState ??
          const AppEmptyState(title: 'No records found');
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = AppBreakpoints.isMobile(constraints.maxWidth);

        if (isMobile) {
          return ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: widget.items.length,
            separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.xs),
            itemBuilder: (context, index) {
              final item = widget.items[index];
              final isExpanded = _expandedIndices.contains(index);

              if (widget.expandableCardBuilder == null) {
                return GestureDetector(
                  onTap: widget.onRowTap != null
                      ? () => widget.onRowTap!(item)
                      : null,
                  child: widget.cardBuilder(context, item),
                );
              }

              return AppCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          if (isExpanded) {
                            _expandedIndices.remove(index);
                          } else {
                            _expandedIndices.add(index);
                          }
                        });
                        if (widget.onRowTap != null) {
                          widget.onRowTap!(item);
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        child: Row(
                          children: [
                            Expanded(child: widget.cardBuilder(context, item)),
                            const SizedBox(width: AppSpacing.xs),
                            AnimatedRotation(
                              turns: isExpanded ? 0.5 : 0.0,
                              duration: const Duration(milliseconds: 200),
                              child: const Icon(
                                shadcn.LucideIcons.chevronDown,
                                size: 20,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (isExpanded && widget.expandableCardBuilder != null)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.sm,
                          0,
                          AppSpacing.sm,
                          AppSpacing.sm,
                        ),
                        child: Column(
                          children: [
                            const shadcn.Divider(),
                            const SizedBox(height: AppSpacing.xs),
                            widget.expandableCardBuilder!(context, item),
                          ],
                        ),
                      ),
                  ],
                ),
              );
            },
          );
        }

        return shadcn.SurfaceCard(
          padding: EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.title != null ||
                  (widget.actions != null && widget.actions!.isNotEmpty))
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Row(
                    children: [
                      if (widget.title != null)
                        Expanded(child: Text(widget.title!).h4()),
                      if (widget.actions != null) ...widget.actions!,
                    ],
                  ),
                ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minWidth: constraints.maxWidth > widget.minWidth
                        ? constraints.maxWidth
                        : widget.minWidth,
                  ),
                  child: shadcn.Table(
                    rows: [
                      shadcn.TableHeader(
                        cells: widget.columns
                            .map(
                              (col) => shadcn.TableCell(
                                child: Padding(
                                  padding: const EdgeInsets.all(AppSpacing.sm),
                                  child: col.label,
                                ),
                              ),
                            )
                            .toList(),
                      ),
                      ...widget.items.map((item) {
                        final cells = widget.rowBuilder(item);
                        return shadcn.TableRow(
                          cells: cells
                              .map(
                                (c) => shadcn.TableCell(
                                  child: GestureDetector(
                                    onTap: widget.onRowTap != null
                                        ? () => widget.onRowTap!(item)
                                        : null,
                                    child: Padding(
                                      padding: const EdgeInsets.all(
                                        AppSpacing.sm,
                                      ),
                                      child: c,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
