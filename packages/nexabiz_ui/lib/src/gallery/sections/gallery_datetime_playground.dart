import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;
import '../../../nexabiz_ui.dart';
import '../gallery_state_controller.dart';
import '../gallery_preview_card.dart';

class GalleryDateTimePlayground extends StatefulWidget {
  final GalleryStateController controller;

  const GalleryDateTimePlayground({super.key, required this.controller});

  @override
  State<GalleryDateTimePlayground> createState() =>
      _GalleryDateTimePlaygroundState();
}

class _GalleryDateTimePlaygroundState extends State<GalleryDateTimePlayground> {
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final cat = GalleryCategory.dateTime;
    final ctrl = widget.controller;

    final cards = <Widget>[];

    // 1. Calendar
    if (ctrl.isComponentMatching(
      'Calendar',
      'Full month calendar selection grid',
      cat,
    )) {
      cards.add(
        GalleryPreviewCard(
          name: 'Calendar',
          category: cat,
          description: 'Calendar view primitive for date selection.',
          usageNotes:
              'Use for fiscal period range pickers and date selection dialogs.',
          dartCode: '''
shadcn.Calendar(
  selectionMode: shadcn.CalendarSelectionMode.single,
  view: _selectedDate.toCalendarView(),
  value: shadcn.CalendarValue.single(_selectedDate),
  onChanged: (val) {},
)''',
          preview: SizedBox(
            width: 300,
            child: AppCard(
              child: Column(
                children: [
                  Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: AppSpacing.xs,
                    runSpacing: AppSpacing.xs,
                    children: [
                      Text(
                        'Selected Fiscal Date:',
                        style: AppTypography.label(context),
                      ),
                      Text(
                        '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}',
                        style: AppTypography.numericValue(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  shadcn.Calendar(
                    selectionMode: shadcn.CalendarSelectionMode.single,
                    view: _selectedDate.toCalendarView(),
                    value: shadcn.CalendarValue.single(_selectedDate),
                    onChanged: (val) {
                      if (val is shadcn.SingleCalendarValue) {
                        setState(() => _selectedDate = val.date);
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    // 2. DatePicker / TimePicker
    if (ctrl.isComponentMatching(
      'DatePicker / TimePicker',
      'Input controls for date and time selection',
      cat,
    )) {
      cards.add(
        GalleryPreviewCard(
          name: 'DatePicker & TimePicker',
          category: cat,
          description:
              'Compact dropdown picker controls for dates and time values.',
          usageNotes: 'Use AppDateField across all transaction creation forms.',
          dartCode: '''
AppDateField(
  label: 'Voucher Date',
  value: _selectedDate,
  onChanged: (date) {},
)''',
          preview: SizedBox(
            width: 280,
            child: Column(
              children: [
                AppDateField(
                  label: 'Voucher Date',
                  value: _selectedDate,
                  onChanged: (date) {
                    if (date != null) setState(() => _selectedDate = date);
                  },
                ),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: AppSpacing.xs,
                  children: [
                    const Icon(AppIcons.calendar, size: 16),
                    Text(
                      'Posting Time: 09:30 AM (UTC+3)',
                      style: AppTypography.caption(context),
                    ),
                  ],
                ),
              ],
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
