import 'package:get/get.dart';
import 'package:loci/core/enums/activity_type.dart';
import 'package:loci/features/explore_activity/presentation/controllers/business_event_details_controller.dart';
import 'package:loci/features/explore_activity/presentation/controllers/business_raffle_details_controller.dart';
import 'package:loci/features/explore_activity/presentation/controllers/business_route_details_controller.dart';

/// Coordinates view-details loading for event, route, and raffle.
class ViewActivityController extends GetxController {
  late ActivityType activityType;
  String screenTitle = '';

  BusinessEventDetailsController get _eventDetails =>
      Get.find<BusinessEventDetailsController>();
  BusinessRouteDetailsController get _routeDetails =>
      Get.find<BusinessRouteDetailsController>();
  BusinessRaffleDetailsController get _raffleDetails =>
      Get.find<BusinessRaffleDetailsController>();

  @override
  void onInit() {
    super.onInit();
    _parseArguments();
  }

  @override
  void onReady() {
    super.onReady();
    load();
  }

  void _parseArguments() {
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    screenTitle = args['title']?.toString() ??
        args['routeName']?.toString() ??
        args['rafflesName']?.toString() ??
        '';

    activityType = _activityTypeFromArgs(args);
  }

  ActivityType _activityTypeFromArgs(Map<String, dynamic> args) {
    final explicit = args['activityType']?.toString();
    if (explicit != null && explicit.isNotEmpty) {
      for (final type in ActivityType.values) {
        if (type.name == explicit) return type;
      }
      return ActivityType.fromString(explicit);
    }
    if (args['eventId'] != null && args['eventId'].toString().isNotEmpty) {
      return ActivityType.event;
    }
    if (args['routeId'] != null && args['routeId'].toString().isNotEmpty) {
      return ActivityType.routes;
    }
    return ActivityType.raffles;
  }

  Future<void> load() async {
    switch (activityType) {
      case ActivityType.event:
        await _eventDetails.loadFromRouteArguments();
        if (screenTitle.isEmpty) {
          screenTitle = _eventDetails.screenTitle;
        }
      case ActivityType.routes:
        await _routeDetails.loadFromRouteArguments();
        if (screenTitle.isEmpty) {
          screenTitle = _routeDetails.screenTitle;
        }
      case ActivityType.raffles:
        await _raffleDetails.loadFromRouteArguments();
        if (screenTitle.isEmpty) {
          screenTitle = _raffleDetails.screenTitle;
        }
    }
  }

  Future<void> retryLoad() async {
    switch (activityType) {
      case ActivityType.event:
        await _eventDetails.retryLoad();
      case ActivityType.routes:
        await _routeDetails.retryLoad();
      case ActivityType.raffles:
        await _raffleDetails.retryLoad();
    }
  }

  bool get isLoading {
    switch (activityType) {
      case ActivityType.event:
        return _eventDetails.isLoading.value;
      case ActivityType.routes:
        return _routeDetails.isLoading.value;
      case ActivityType.raffles:
        return _raffleDetails.isLoading.value;
    }
  }

  String? get errorMessage {
    switch (activityType) {
      case ActivityType.event:
        return _eventDetails.errorMessage.value;
      case ActivityType.routes:
        return _routeDetails.errorMessage.value;
      case ActivityType.raffles:
        return _raffleDetails.errorMessage.value;
    }
  }

  bool get isEmpty {
    switch (activityType) {
      case ActivityType.event:
        return _eventDetails.eventDetails.value == null;
      case ActivityType.routes:
        return _routeDetails.routeDetails.value == null;
      case ActivityType.raffles:
        return _raffleDetails.raffleDetails.value == null;
    }
  }

  String get emptyMessage {
    return switch (activityType) {
      ActivityType.event => 'No event details found',
      ActivityType.routes => 'No route found',
      ActivityType.raffles => 'No raffle found',
    };
  }
}
