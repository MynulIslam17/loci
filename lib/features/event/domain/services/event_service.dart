import 'package:loci/features/event/data/models/event_detail_model.dart';
import 'package:loci/features/event/data/models/event_list_model.dart';
import 'package:loci/features/event/data/repositories/event_repository.dart';

/// Domain orchestration for events. Controllers call this — never NetworkCaller.
class EventService {
  final EventRepository _repository;

  EventService(this._repository);

  Future<EventListResponseModel> getEvents({
    required int page,
    required int limit,
    String? businessId,
    String? search,
  }) async {
    final body = await _repository.getEvents(
      page: page,
      limit: limit,
      businessId: businessId,
      search: search,
    );
    return EventListResponseModel.fromJson(body);
  }

  Future<EventDetailsModel> getEventDetails(String eventId) async {
    final body = await _repository.getEventDetails(eventId);
    final data = body['data'];
    if (data is! Map<String, dynamic>) {
      throw Exception('Failed to load event details');
    }
    return EventDetailsModel.fromJson(data);
  }

  Future<String> sendRsvp({
    required String eventId,
    required String status,
  }) async {
    final body = await _repository.sendRsvp(eventId: eventId, status: status);
    return body['message']?.toString() ?? 'RSVP sent successfully';
  }
}
