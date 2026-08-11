import 'dart:io';

import 'package:loci/core/constants/app_url.dart';
import 'package:loci/core/network/network_caller.dart';

/// Explore Activity data layer: remote HTTP via [NetworkCaller].
class ExploreActivityRepository {
  final NetworkCaller _network;

  ExploreActivityRepository(this._network);

  Future<Map<String, dynamic>> getEvents({
    required int page,
    required int limit,
    required String businessId,
    String? search,
  }) async {
    final res = await _network.getRequest(
      url: AppUrl.eventList,
      queryParams: {
        'page': page,
        'limit': limit,
        'businessId': businessId,
        if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
      },
    );
    if (!res.isSuccess || res.body == null) {
      throw Exception(res.errorMessage ?? 'Failed to load events');
    }
    return res.body!;
  }

  Future<Map<String, dynamic>> getRoutes({
    required int page,
    required int limit,
    required String businessId,
    String? search,
  }) async {
    final res = await _network.getRequest(
      url: AppUrl.routeList,
      queryParams: {
        'page': page,
        'limit': limit,
        'businessId': businessId,
        if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
      },
    );
    if (!res.isSuccess || res.body == null) {
      throw Exception(res.errorMessage ?? 'Failed to load routes');
    }
    return res.body!;
  }

  Future<Map<String, dynamic>> getRaffles({
    required int page,
    required int limit,
    required String businessId,
    String? search,
  }) async {
    final res = await _network.getRequest(
      url: AppUrl.raffles,
      queryParams: {
        'page': page,
        'limit': limit,
        'businessId': businessId,
        if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
      },
    );
    if (!res.isSuccess || res.body == null) {
      throw Exception(res.errorMessage ?? 'Failed to load raffles');
    }
    return res.body!;
  }

  Future<Map<String, dynamic>> getEventDetails(
    String eventId, {
    String? businessId,
  }) async {
    final res = await _network.getRequest(
      url: AppUrl.eventDetails(eventId),
      queryParams: {
        if (businessId != null && businessId.isNotEmpty)
          'businessId': businessId,
      },
    );
    if (!res.isSuccess || res.body == null) {
      throw Exception(res.errorMessage ?? 'Failed to load event details');
    }
    return res.body!;
  }

  Future<Map<String, dynamic>> getRouteDetails(
    String routeId, {
    String? businessId,
  }) async {
    final res = await _network.getRequest(
      url: AppUrl.routeDetails(routeId),
      queryParams: {
        if (businessId != null && businessId.isNotEmpty)
          'businessId': businessId,
      },
    );
    if (!res.isSuccess || res.body == null) {
      throw Exception(res.errorMessage ?? 'Failed to fetch route details');
    }
    return res.body!;
  }

  Future<Map<String, dynamic>> getRaffleDetails(String raffleId) async {
    final res = await _network.getRequest(url: AppUrl.rafflesDetails(raffleId));
    if (!res.isSuccess || res.body == null) {
      throw Exception(res.errorMessage ?? 'Failed to fetch raffle details');
    }
    return res.body!;
  }

  Future<Map<String, dynamic>> searchTasks({
    required String query,
    required int page,
    required int limit,
    String? businessId,
  }) async {
    final queryParams = <String, dynamic>{
      'q': query,
      'page': page,
      'limit': limit,
      if (businessId != null && businessId.isNotEmpty) 'businessId': businessId,
    };
    final res = await _network.getRequest(
      url: AppUrl.searchTask,
      queryParams: queryParams,
    );
    if (!res.isSuccess || res.body == null) {
      throw Exception(res.errorMessage ?? 'Failed to load tasks');
    }
    return res.body!;
  }

  Future<void> updateEvent({
    required String eventId,
    Map<String, String>? fields,
    Map<String, File>? files,
  }) async {
    final res = await _network.multipartRequest(
      url: AppUrl.eventDetails(eventId),
      method: 'PATCH',
      fields: fields,
      files: files,
    );
    if (!res.isSuccess) {
      throw Exception(res.errorMessage ?? 'Update failed');
    }
  }

  Future<void> updateRoute({
    required String routeId,
    Map<String, String>? fields,
    Map<String, File>? files,
  }) async {
    final res = await _network.multipartRequest(
      url: AppUrl.routeDetails(routeId),
      method: 'PATCH',
      fields: fields,
      files: files,
    );
    if (!res.isSuccess) {
      throw Exception(res.errorMessage ?? 'Update failed');
    }
  }

  Future<void> updateRaffle({
    required String raffleId,
    Map<String, String>? fields,
    Map<String, File>? files,
  }) async {
    final res = await _network.multipartRequest(
      url: AppUrl.rafflesDetails(raffleId),
      method: 'PATCH',
      fields: fields,
      files: files,
    );
    if (!res.isSuccess) {
      throw Exception(res.errorMessage ?? 'Update failed');
    }
  }

  Future<Map<String, dynamic>> createActivity({
    required String url,
    required Map<String, String> body,
    Map<String, File>? files,
  }) async {
    final res = await _network.multipartRequest(
      url: url,
      method: 'POST',
      fields: body,
      files: files,
    );
    if (!res.isSuccess) {
      final message =
          res.body?['errors']?['details']?[0] ??
          res.body?['message'] ??
          res.errorMessage ??
          'Failed to create activity';
      throw Exception(message.toString());
    }
    return res.body ?? const {};
  }
}
