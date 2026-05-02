/// Format member count → 480K / 1.2M
String formatMembers(dynamic count) {
  if (count == null) return "0";

  int value = count is int ? count : int.tryParse(count.toString()) ?? 0;

  if (value >= 1000000) {
    return "${(value / 1000000).toStringAsFixed(1)}M";
  } else if (value >= 1000) {
    return "${(value / 1000).toStringAsFixed(0)}K";
  } else {
    return value.toString();
  }
}
