import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:loci/core/theme/theme_extention.dart';

/// Material date picker on Android; Cupertino wheel on iOS.
Future<DateTime?> showAdaptiveDatePicker({
  required BuildContext context,
  required DateTime firstDate,
  required DateTime lastDate,
  DateTime? initialDate,
}) {
  final initial = _clampDate(initialDate ?? DateTime.now(), firstDate, lastDate);
  if (!context.isCupertino) {
    return showDatePicker(
      context: context,
      firstDate: firstDate,
      lastDate: lastDate,
      initialDate: initial,
    );
  }
  return _showCupertinoDateTime(
    context: context,
    mode: CupertinoDatePickerMode.date,
    initialDateTime: initial,
    minimumDate: firstDate,
    maximumDate: lastDate,
  );
}

/// Material time picker on Android; Cupertino wheel on iOS.
Future<TimeOfDay?> showAdaptiveTimePicker({
  required BuildContext context,
  TimeOfDay? initialTime,
  bool use24hFormat = false,
}) async {
  final initial = initialTime ?? TimeOfDay.now();
  if (!context.isCupertino) {
    return showTimePicker(
      context: context,
      initialTime: initial,
      builder: use24hFormat
          ? null
          : (context, child) => MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(alwaysUse24HourFormat: false),
              child: child!,
            ),
    );
  }

  final now = DateTime.now();
  final picked = await _showCupertinoDateTime(
    context: context,
    mode: CupertinoDatePickerMode.time,
    initialDateTime: DateTime(
      now.year,
      now.month,
      now.day,
      initial.hour,
      initial.minute,
    ),
    use24hFormat: use24hFormat,
  );
  if (picked == null) return null;
  return TimeOfDay(hour: picked.hour, minute: picked.minute);
}

/// Material range calendar on Android; two Cupertino date wheels on iOS.
Future<DateTimeRange?> showAdaptiveDateRangePicker({
  required BuildContext context,
  required DateTime firstDate,
  required DateTime lastDate,
  DateTimeRange? initialDateRange,
}) async {
  if (!context.isCupertino) {
    return showDateRangePicker(
      context: context,
      firstDate: firstDate,
      lastDate: lastDate,
      initialDateRange: initialDateRange,
    );
  }

  final start = await _showCupertinoDateTime(
    context: context,
    mode: CupertinoDatePickerMode.date,
    initialDateTime: _clampDate(
      initialDateRange?.start ?? DateTime.now(),
      firstDate,
      lastDate,
    ),
    minimumDate: firstDate,
    maximumDate: lastDate,
  );
  if (start == null || !context.mounted) return null;

  final end = await _showCupertinoDateTime(
    context: context,
    mode: CupertinoDatePickerMode.date,
    initialDateTime: _clampDate(
      initialDateRange?.end ?? start,
      start,
      lastDate,
    ),
    minimumDate: start,
    maximumDate: lastDate,
  );
  if (end == null) return null;
  return DateTimeRange(start: start, end: end);
}

DateTime _clampDate(DateTime value, DateTime min, DateTime max) {
  if (value.isBefore(min)) return min;
  if (value.isAfter(max)) return max;
  return value;
}

Future<DateTime?> _showCupertinoDateTime({
  required BuildContext context,
  required CupertinoDatePickerMode mode,
  required DateTime initialDateTime,
  DateTime? minimumDate,
  DateTime? maximumDate,
  bool use24hFormat = false,
}) {
  var selected = initialDateTime;
  final scheme = Theme.of(context).colorScheme;

  return showCupertinoModalPopup<DateTime>(
    context: context,
    builder: (ctx) {
      return Material(
        color: scheme.surface,
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 280,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CupertinoButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: const Text('Cancel'),
                      ),
                      CupertinoButton(
                        onPressed: () => Navigator.of(ctx).pop(selected),
                        child: const Text('Done'),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: CupertinoDatePicker(
                    mode: mode,
                    initialDateTime: initialDateTime,
                    minimumDate: minimumDate,
                    maximumDate: maximumDate,
                    use24hFormat: use24hFormat,
                    onDateTimeChanged: (value) => selected = value,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
