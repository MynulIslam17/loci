import 'dart:io';

import 'package:loci/features/event/data/models/event_details_model.dart';
import 'package:loci/features/event/data/models/event_model.dart';
import 'package:loci/features/raffles/data/models/raffles_details_model.dart';
import 'package:loci/features/raffles/data/models/raffles_model.dart';
import 'package:loci/features/routes/data/models/route_details_model.dart';
import 'package:loci/features/routes/data/models/routes_model.dart';
import 'package:loci/features/explore_activity/data/models/event_update_request_model.dart';
import 'package:loci/features/explore_activity/data/models/raffle_update_request_model.dart';
import 'package:loci/features/explore_activity/data/models/route_update_request_model.dart';
import 'package:loci/features/explore_activity/data/models/task_model.dart';
import 'package:loci/features/explore_activity/data/repositories/explore_activity_repository.dart';

/// Domain orchestration for explore activity. Controllers call this — never NetworkCaller.
class ExploreActivityService {
  final ExploreActivityRepository _repository;

  ExploreActivityService(this._repository);

  Future<EventListResponseModel> getEvents({
    required int page,
    required int limit,
    required String businessId,
  }) async {
    final body = await _repository.getEvents(
      page: page,
      limit: limit,
      businessId: businessId,
    );
    return EventListResponseModel.fromJson(body);
  }

  Future<RouteResponseModel> getRoutes({
    required int page,
    required int limit,
    required String businessId,
  }) async {
    final body = await _repository.getRoutes(
      page: page,
      limit: limit,
      businessId: businessId,
    );
    return RouteResponseModel.fromJson(body);
  }

  Future<RaffleListResponseModel> getRaffles({
    required int page,
    required int limit,
    required String businessId,
  }) async {
    final body = await _repository.getRaffles(
      page: page,
      limit: limit,
      businessId: businessId,
    );
    return RaffleListResponseModel.fromJson(body);
  }

  Future<EventDetailsModel> getEventDetails(String eventId) async {
    final body = await _repository.getEventDetails(eventId);
    final data = body['data'];
    if (data is! Map<String, dynamic>) {
      throw Exception('Failed to load event details');
    }
    return EventDetailsModel.fromJson(data);
  }

  Future<RouteDetails> getRouteDetails(String routeId) async {
    final body = await _repository.getRouteDetails(routeId);
    final data = body['data'];
    if (data == null) {
      throw Exception('No route data found');
    }
    return RouteDetails.fromJson(data as Map<String, dynamic>);
  }

  Future<RaffleDetailsModel> getRaffleDetails(String raffleId) async {
    final body = await _repository.getRaffleDetails(raffleId);
    return RaffleDetailsModel.fromJson(body);
  }

  Future<ActivityListResponseModel> searchTasks({
    required String query,
    required int page,
    required int limit,
    String? businessId,
  }) async {
    final body = await _repository.searchTasks(
      query: query,
      page: page,
      limit: limit,
      businessId: businessId,
    );
    return ActivityListResponseModel.fromJson(body);
  }

  Future<void> updateEvent(EventUpdateRequest request) {
    final fields = request.toFields();
    return _repository.updateEvent(
      eventId: request.eventId,
      fields: fields.isNotEmpty ? fields : null,
      files: request.toFiles(),
    );
  }

  Future<void> updateRoute(RouteUpdateRequest request) {
    final fields = request.toFields();
    return _repository.updateRoute(
      routeId: request.routeId,
      fields: fields.isNotEmpty ? fields : null,
      files: request.toFiles(),
    );
  }

  Future<void> updateRaffle(RaffleUpdateRequest request) {
    final fields = request.toFields();
    final files = request.toFiles();
    return _repository.updateRaffle(
      raffleId: request.raffleId,
      fields: fields.isNotEmpty ? fields : null,
      files: files.isNotEmpty ? files : null,
    );
  }

  Future<String> createActivity({
    required String url,
    required Map<String, String> body,
    Map<String, File>? files,
  }) async {
    final res = await _repository.createActivity(
      url: url,
      body: body,
      files: files,
    );
    return res['message']?.toString() ?? 'Created successfully';
  }
}
