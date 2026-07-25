import 'package:loci/core/constants/app_url.dart';
import 'package:loci/core/network/network_caller.dart';

/// Event data layer: remote HTTP via [NetworkCaller].
class EventRepository {
  final NetworkCaller _network;

  EventRepository(this._network);

  Future<Map<String, dynamic>> getEvents({
    required int page,
    required int limit,
    String? businessId,
    String? search,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'limit': limit,
      if (businessId != null) 'businessId': businessId,
      if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
    };

    final res = await _network.getRequest(
      url: AppUrl.eventList,
      queryParams: queryParams,
    );
    if (!res.isSuccess || res.body == null) {
      throw Exception(res.errorMessage ?? 'Failed to load events');
    }
    return res.body!;
  }

  Future<Map<String, dynamic>> getEventDetails(String eventId) async {
    final res = await _network.getRequest(url: AppUrl.eventDetails(eventId));
    if (!res.isSuccess || res.body == null) {
      throw Exception(res.errorMessage ?? 'Failed to load event details');
    }
    return res.body!;
  }

  Future<Map<String, dynamic>> sendRsvp({
    required String eventId,
    required String status,
  }) async {
    final res = await _network.postRequest(
      url: AppUrl.rsvpEvent(eventId),
      body: {'status': status},
    );
    if (!res.isSuccess || res.body == null) {
      throw Exception(
        res.body?['message'] ?? res.errorMessage ?? 'Something went wrong',
      );
    }
    return res.body!;
  }
}
