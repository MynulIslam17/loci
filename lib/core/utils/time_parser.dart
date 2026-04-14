import 'package:flutter/material.dart';

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