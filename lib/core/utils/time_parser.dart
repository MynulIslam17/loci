import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

String formatTime(TimeOfDay time) {
  int hour = time.hour;
  int minute = time.minute;
  String period = "AM";

  if (hour >= 12) {
    period = "PM";
    if (hour > 12) hour -= 12;
  } else if (hour == 0) {
    hour = 12;
  }

  return "$hour:${minute.toString().padLeft(2, '0')} $period";
}


String combineToUtcIso(DateTime date, TimeOfDay time) {
  final combined = DateTime(
    date.year,
    date.month,
    date.day,
    time.hour,
    time.minute,
  );

  return combined.toUtc().toIso8601String();
}


TimeOfDay parseTime(String time) {
  try {
    time = time.trim().replaceAll(RegExp(r'\s+'), ' ');

    final parts = time.split(' ');
    final timePart = parts[0];
    final period = parts.length > 1 ? parts[1].toUpperCase() : "AM";

    final split = timePart.split(':');
    int hour = int.parse(split[0]);
    int minute = int.parse(split[1]);

    if (period == "PM" && hour != 12) hour += 12;
    if (period == "AM" && hour == 12) hour = 0;

    return TimeOfDay(hour: hour, minute: minute);
  } catch (e) {
    debugPrint("parseTime failed: $time → $e");
    return TimeOfDay.now(); // fallback (safe)
  }
}