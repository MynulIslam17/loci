
import '../../../../core/utils/date_parser.dart';

String dateRangeHelper(String start, String end) {
  final DateTime startDateTime = DateTime.parse(start).toLocal();
  final DateTime endDateTime = DateTime.parse(end).toLocal();

  final dateRange="${DateParserHelper.shortDate(startDateTime)}-${DateParserHelper.shortDate(endDateTime)}";
  return dateRange;
}

