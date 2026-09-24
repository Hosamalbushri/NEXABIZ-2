import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;
import '../../../nexabiz_ui.dart';
import '../gallery_state_controller.dart';
import '../gallery_preview_card.dart';

class GalleryActionsPlayground extends StatefulWidget {
  final GalleryStateController controller;

  const GalleryActionsPlayground({super.key, required this.controller});

  @override
  State<GalleryActionsPlayground> createState() =>
      _GalleryActionsPlaygroundState();
}

class _GalleryActionsPlaygroundState extends State<GalleryActionsPlayground> {
  bool _btnDisabled = false;
  bool _boldToggled = true;
  String _alignSelection = 'center';

  @override
  Widget build(BuildContext context) {
    final cat = GalleryCategory.actions;
    final ctrl = widget.controller;

    final cards = <Widget>[];

    // 1. Button Variants
    if (ctrl.isComponentMatching(
      'Button',
      'Interactive action button with multiple variants',
      cat,
    )) {
      cards.add(
        GalleryPreviewCard(
          name: 'Button',
          category: cat,
          description:
              'Primary action trigger with Primary, Secondary, Outline, Ghost, and Destructive variants.',
          usageNotes:
              'Use shadcn button primitives or AppButton across all forms, dialogs, and headers.',
          dartCode: '''
shadcn.PrimaryButton(
  onPressed: _btnDisabled ? null : () {},
  child: const Text('Post Journal Entry'),
)''',
          preview: Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              shadcn.PrimaryButton(
                onPressed: _btnDisabled ? null : () {},
                child: const Text('Primary Action'),
              ),
              shadcn.SecondaryButton(
                onPressed: _btnDisabled ? null : () {},
                child: const Text('Secondary'),
              ),
              shadcn.OutlineButton(
                onPressed: _btnDisabled ? null : () {},
                child: const Text('Outline'),
              ),
              shadcn.GhostButton(
                onPressed: _btnDisabled ? null : () {},
                child: const Text('Ghost'),
              ),
              shadcn.DestructiveButton(
                onPressed: _btnDisabled ? null : () {},
                child: const Text('Destructive'),
              ),
            ],
          ),
          controls: Row(
            children: [
              AppSwitch(
                value: _btnDisabled,
                onChanged: (val) => setState(() => _btnDisabled = val),
              ),
              const SizedBox(width: AppSpacing.xs),
              const Text('Disabled State'),
            ],
          ),
        ),
      );
    }

    // 2. Toggle & ToggleGroup
    if (ctrl.isComponentMatching(
      'Toggle / ToggleGroup',
      'Interactive selection toggles',
      cat,
    )) {
      cards.add(
        GalleryPreviewCard(
          name: 'Toggle / ToggleGroup',
          category: cat,
          description: 'Single or multi-select toggle controls.',
          usageNotes:
              'Use for view switching (Grid vs List) or text formatting controls.',
          dartCode: '''
shadcn.Toggle(
  value: _boldToggled,
  onChanged: (val) {},
  child: const Icon(AppIcons.settings),
)''',
          preview: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.xs,
            children: [
              shadcn.Toggle(
                value: _boldToggled,
                onChanged: (val) => setState(() => _boldToggled = val),
                child: const Text(
                  'B',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Wrap(
                spacing: 2,
                runSpacing: 2,
                children: [
                  shadcn.OutlineButton(
                    onPressed: () => setState(() => _alignSelection = 'left'),
                    child: Icon(
                      AppIcons.chevronLeft,
                      size: 16,
                      color: _alignSelection == 'left'
                          ? AppColors.primaryBlue
                          : null,
                    ),
                  ),
                  shadcn.OutlineButton(
                    onPressed: () => setState(() => _alignSelection = 'center'),
                    child: Icon(
                      AppIcons.grid,
                      size: 16,
                      color: _alignSelection == 'center'
                          ? AppColors.primaryBlue
                          : null,
                    ),
                  ),
                  shadcn.OutlineButton(
                    onPressed: () => setState(() => _alignSelection = 'right'),
                    child: Icon(
                      AppIcons.chevronRight,
                      size: 16,
                      color: _alignSelection == 'right'
                          ? AppColors.primaryBlue
                          : null,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    // 3. DropdownMenu & ContextMenu
    if (ctrl.isComponentMatching(
      'DropdownMenu',
      'Contextual dropdown menu overlay',
      cat,
    )) {
      cards.add(
        GalleryPreviewCard(
          name: 'DropdownMenu',
          category: cat,
          description: 'Contextual popover menu attached to a trigger widget.',
          usageNotes:
              'Use for table row actions (Edit, Print, Export, Delete).',
          dartCode: '''
shadcn.showDropdown<void>(
  context: context,
  builder: (context) => shadcn.DropdownMenu(
    children: [
      shadcn.MenuButton(child: Text('Edit Transaction')),
      shadcn.MenuButton(child: Text('Export PDF')),
      shadcn.MenuDivider(),
      shadcn.MenuButton(child: Text('Delete Voucher')),
    ],
  ),
);''',
          preview: shadcn.OutlineButton(
            onPressed: () {
              shadcn.showDropdown<void>(
                context: context,
                builder: (context) => const shadcn.DropdownMenu(
                  children: [
                    shadcn.MenuButton(child: Text('Edit Transaction')),
                    shadcn.MenuButton(child: Text('Export PDF Ledger')),
                    shadcn.MenuDivider(),
                    shadcn.MenuButton(child: Text('Void Voucher')),
                  ],
                ),
              );
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text('Action Options'),
                SizedBox(width: 4),
                Icon(AppIcons.chevronDown, size: 16),
              ],
            ),
          ),
        ),
      );
    }

    // 4. Command Palette
    if (ctrl.isComponentMatching(
      'Command',
      'Command palette search & action launcher',
      cat,
    )) {
      cards.add(
        GalleryPreviewCard(
          name: 'Command',
          category: cat,
          description:
              'Searchable command palette for quick navigation and actions.',
          usageNotes: 'Use for global quick command search (Ctrl+K).',
          dartCode: '''
AppTextField(
  hint: 'Type a command or search...',
  prefixIcon: Icon(AppIcons.command),
)''',
          preview: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 340),
            child: AppSurface(
              padding: const EdgeInsets.all(AppSpacing.xs),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  AppTextField(
                    hint: 'Type a command or search...',
                    prefixIcon: Icon(AppIcons.command, size: 16),
                  ),
                  SizedBox(height: AppSpacing.xs),
                  AppListTile(
                    leading: Icon(AppIcons.receipt, size: 16),
                    title: Text('Create Sales Invoice'),
                  ),
                  AppListTile(
                    leading: Icon(AppIcons.wallet, size: 16),
                    title: Text('View General Ledger'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Column(
      children: cards
          .map(
            (card) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: card,
            ),
          )
          .toList(),
    );
  }
}
