import 'dart:ui';
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
  final colors = Theme.of(context).colorScheme;
  final isDark = Theme.of(context).brightness == Brightness.dark;

  return showCupertinoModalPopup<DateTime>(
    context: context,
    builder: (ctx) {
      return ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: BoxDecoration(
              color: isDark
                  ? colors.surface.withValues(alpha: 0.85)
                  : colors.surface.withValues(alpha: 0.88),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(22)),
              border: Border(
                top: BorderSide(
                  color: colors.outlineVariant.withValues(
                    alpha: isDark ? 0.25 : 0.35,
                  ),
                  width: 0.5,
                ),
              ),
            ),
            child: SafeArea(
              top: false,
              child: SizedBox(
                height: 290,
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: colors.outlineVariant.withValues(
                              alpha: isDark ? 0.2 : 0.25,
                            ),
                            width: 0.5,
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CupertinoButton(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 10,
                            ),
                            onPressed: () => Navigator.of(ctx).pop(),
                            child: Text(
                              'Cancel',
                              style: TextStyle(
                                color: colors.onSurfaceVariant,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          CupertinoButton(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 10,
                            ),
                            onPressed: () => Navigator.of(ctx).pop(selected),
                            child: Text(
                              'Done',
                              style: TextStyle(
                                color: colors.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
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
          ),
        ),
      );
    },
  );
}
