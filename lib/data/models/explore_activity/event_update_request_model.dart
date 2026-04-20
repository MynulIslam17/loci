import 'dart:io';

class EventUpdateRequest {
  final String eventId;
  final String? title;
  final String? details;
  final String? eventDate;
  final String? eventTime;
  final int? maxParticipants;
  final String? location;
  final String? url;
  final bool? isPublic;
  final String? status;
  final File? banner;

  EventUpdateRequest({
    required this.eventId,
    this.title,
    this.details,
    this.eventDate,
    this.eventTime,
    this.maxParticipants,
    this.location,
    this.url,
    this.isPublic,
    this.status,
    this.banner,
  });

  /// Converts the model to a Map for API calls.
  Map<String, String> toFields() {
    final Map<String, String> data = {};

    // add fields to the map if they are not null
    if (title != null) data['title'] = title!;
    if (details != null) data['details'] = details!;
    if (eventDate != null) data['eventDate'] = eventDate!;
    if (eventTime != null) data['eventTime'] = eventTime!;
    if (maxParticipants != null)
      data['maxParticipants'] = maxParticipants.toString();
    if (location != null) data['location'] = location!;
    if (url != null) data['url'] = url!;
    if (isPublic != null) data['isPublic'] = isPublic.toString();
    if (status != null) data['status'] = status!;

    return data;
  }

  /// Returns the file map if a new banner has been selected.
  Map<String, File>? toFiles() {
    if (banner == null) return null;
    return {'banner': banner!};
  }
}
