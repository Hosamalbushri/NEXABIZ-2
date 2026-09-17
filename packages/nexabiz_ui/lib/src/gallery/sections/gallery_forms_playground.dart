import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;
import '../../../nexabiz_ui.dart';
import '../gallery_preview_card.dart';

class GalleryFormsPlayground extends StatefulWidget {
  final GalleryStateController controller;

  const GalleryFormsPlayground({super.key, required this.controller});

  @override
  State<GalleryFormsPlayground> createState() => _GalleryFormsPlaygroundState();
}

class _GalleryFormsPlaygroundState extends State<GalleryFormsPlayground> {
  // Input state
  bool _inputDisabled = false;

  // Checkbox & Switch state
  bool _checkboxValue = true;
  bool _switchValue = true;

  // Slider state
  double _sliderValue = 45.0;

  // Select state
  String _selectedCurrency = 'USD';

  // Star Rating state
  double _starRating = 4.0;

  @override
  Widget build(BuildContext context) {
    final cat = GalleryCategory.forms;
    final ctrl = widget.controller;

    final cards = <Widget>[];

    // 1. TextField / Input
    if (ctrl.isComponentMatching('Input / TextField', 'Text input primitive for single line text entries', cat)) {
      cards.add(
        GalleryPreviewCard(
          name: 'Input / TextField',
          category: cat,
          description: 'Canonical text input box derived from shadcn_flutter.',
          usageNotes: 'Use AppTextField for standardized ERP form field inputs.',
          dartCode: '''
AppTextField(
  label: 'Company Name',
  hint: 'Enter company name...',
  enabled: !_inputDisabled,
  onChanged: (val) {},
)''',
          preview: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 320),
            child: AppTextField(
              label: 'Company Name',
              hint: 'Enter company name...',
              enabled: !_inputDisabled,
              onChanged: (val) {},
            ),
          ),
          controls: Row(
            children: [
              AppSwitch(
                value: _inputDisabled,
                onChanged: (val) => setState(() => _inputDisabled = val),
              ),
              const SizedBox(width: AppSpacing.xs),
              const Text('Disabled'),
            ],
          ),
        ),
      );
    }

    // 2. TextArea
    if (ctrl.isComponentMatching('TextArea', 'Multi-line text input field', cat)) {
      cards.add(
        GalleryPreviewCard(
          name: 'TextArea',
          category: cat,
          description: 'Multi-line input field for notes, descriptions, and comments.',
          usageNotes: 'Use for journal entry descriptions or customer address fields.',
          dartCode: '''
shadcn.TextArea(
  placeholder: const Text('Enter ledger notes or transaction comments...'),
  maxLines: 3,
)''',
          preview: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 340),
            child: shadcn.TextArea(
              placeholder: Text('Enter ledger notes or transaction comments...'),
              maxLines: 3,
            ),
          ),
        ),
      );
    }

    // 3. Checkbox
    if (ctrl.isComponentMatching('Checkbox', 'Selectable check box state control', cat)) {
      cards.add(
        GalleryPreviewCard(
          name: 'Checkbox',
          category: cat,
          description: 'Toggleable checkbox control supporting checked and unchecked states.',
          usageNotes: 'Use for line item inclusion or batch approval toggles.',
          dartCode: '''
shadcn.Checkbox(
  state: _checkboxValue ? shadcn.CheckboxState.checked : shadcn.CheckboxState.unchecked,
  onChanged: (state) {},
)''',
          preview: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: AppSpacing.xs,
            children: [
              shadcn.Checkbox(
                state: _checkboxValue
                    ? shadcn.CheckboxState.checked
                    : shadcn.CheckboxState.unchecked,
                onChanged: (st) => setState(() {
                  _checkboxValue = st == shadcn.CheckboxState.checked;
                }),
              ),
              Text('Include tax calculation in ledger totals', style: AppTypography.body(context)),
            ],
          ),
          controls: Row(
            children: [
              AppSwitch(
                value: _checkboxValue,
                onChanged: (val) => setState(() => _checkboxValue = val),
              ),
              const SizedBox(width: AppSpacing.xs),
              const Text('Checked'),
            ],
          ),
        ),
      );
    }

    // 4. Switch
    if (ctrl.isComponentMatching('Switch', 'Toggle switch component', cat)) {
      cards.add(
        GalleryPreviewCard(
          name: 'Switch',
          category: cat,
          description: 'On/Off toggle switch primitive.',
          usageNotes: 'Use for binary configuration options like Dark Mode or Auto-sync.',
          dartCode: '''
AppSwitch(
  value: _switchValue,
  onChanged: (val) {},
)''',
          preview: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: AppSpacing.xs,
            children: [
              AppSwitch(
                value: _switchValue,
                onChanged: (val) => setState(() => _switchValue = val),
              ),
              Text(_switchValue ? 'Real-time Sync Active' : 'Real-time Sync Paused', style: AppTypography.body(context)),
            ],
          ),
        ),
      );
    }

    // 5. Slider
    if (ctrl.isComponentMatching('Slider', 'Continuous or discrete range slider', cat)) {
      cards.add(
        GalleryPreviewCard(
          name: 'Slider',
          category: cat,
          description: 'Interactive range slider widget for selecting numeric values.',
          usageNotes: 'Use for discount percentages, threshold values, or opacity controls.',
          dartCode: '''
shadcn.Slider(
  value: shadcn.SliderValue.single(_sliderValue),
  min: 0,
  max: 100,
  onChanged: (val) {},
)''',
          preview: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 320),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Discount Rate:', style: AppTypography.label(context)),
                    Text('${_sliderValue.round()}%', style: AppTypography.numericValue(context)),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                shadcn.Slider(
                  value: shadcn.SliderValue.single(_sliderValue),
                  min: 0,
                  max: 100,
                  onChanged: (val) {
                    setState(() {
                      _sliderValue = val.value;
                    });
                  },
                ),
              ],
            ),
          ),
        ),
      );
    }

    // 6. Select / Dropdown
    if (ctrl.isComponentMatching('Select', 'Dropdown select menu component', cat)) {
      cards.add(
        GalleryPreviewCard(
          name: 'Select / Dropdown',
          category: cat,
          description: 'Single choice select dropdown primitive.',
          usageNotes: 'Use for currency selection, warehouse location, or document type.',
          dartCode: '''
AppSelectField<String>(
  label: 'Functional Currency',
  value: _selectedCurrency,
  items: [
    AppSelectItem(value: 'USD', label: 'USD - US Dollar'),
    AppSelectItem(value: 'EUR', label: 'EUR - Euro'),
    AppSelectItem(value: 'SAR', label: 'SAR - Saudi Riyal'),
  ],
  onChanged: (val) {},
)''',
          preview: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 300),
            child: AppSelectField<String>(
              label: 'Functional Currency',
              value: _selectedCurrency,
              items: const [
                AppSelectItem(value: 'USD', label: 'USD - US Dollar'),
                AppSelectItem(value: 'EUR', label: 'EUR - Euro'),
                AppSelectItem(value: 'SAR', label: 'SAR - Saudi Riyal'),
                AppSelectItem(value: 'AED', label: 'AED - UAE Dirham'),
              ],
              onChanged: (val) {
                if (val != null) setState(() => _selectedCurrency = val);
              },
            ),
          ),
        ),
      );
    }

    // 7. StarRating
    if (ctrl.isComponentMatching('StarRating', 'Interactive star rating input widget', cat)) {
      cards.add(
        GalleryPreviewCard(
          name: 'StarRating',
          category: cat,
          description: 'Star rating indicator and input control.',
          usageNotes: 'Use for vendor evaluation scores or customer feedback ratings.',
          dartCode: '''
shadcn.StarRating(
  value: _starRating,
  onChanged: (val) {},
)''',
          preview: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: AppSpacing.sm,
            children: [
              shadcn.StarRating(
                value: _starRating,
                onChanged: (val) => setState(() => _starRating = val),
              ),
              Text('Rating: ${_starRating.toStringAsFixed(1)} / 5.0', style: AppTypography.body(context)),
            ],
          ),
        ),
      );
    }

    return Column(
      children: cards
          .map((card) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: card,
              ))
          .toList(),
    );
  }
}
