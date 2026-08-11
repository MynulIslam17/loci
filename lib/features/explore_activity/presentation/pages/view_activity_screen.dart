import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loci/core/enums/activity_type.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/features/explore_activity/presentation/controllers/business_event_details_controller.dart';
import 'package:loci/features/explore_activity/presentation/controllers/business_raffle_details_controller.dart';
import 'package:loci/features/explore_activity/presentation/controllers/business_route_details_controller.dart';
import 'package:loci/features/explore_activity/presentation/controllers/view_activity_controller.dart';
import 'package:loci/features/explore_activity/presentation/widgets/explore_activity_async_body.dart';
import 'package:loci/features/explore_activity/presentation/widgets/view_activity_detail_content.dart';
import 'package:loci/shared/widgets/custom_appbar.dart';

/// Single view screen for event, route, and raffle details.
class ViewActivityScreen extends StatefulWidget {
  const ViewActivityScreen({super.key});

  @override
  State<ViewActivityScreen> createState() => _ViewActivityScreenState();
}

class _ViewActivityScreenState extends State<ViewActivityScreen> {
  late final ViewActivityController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<ViewActivityController>();
    _controller.parseRouteArguments();
    _controller.prepareForLoad();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _controller.loadCurrentActivity();
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colorScheme.surface,
      appBar: CustomAppbar(title: _controller.screenTitle),
      body: Obx(() {
        final type = _controller.activityType;
        final isLoading = switch (type) {
          ActivityType.event =>
            Get.find<BusinessEventDetailsController>().isLoading.value,
          ActivityType.routes =>
            Get.find<BusinessRouteDetailsController>().isLoading.value,
          ActivityType.raffles =>
            Get.find<BusinessRaffleDetailsController>().isLoading.value,
        };

        return ExploreActivityAsyncBody(
          isLoading: isLoading,
          errorMessage: _controller.errorMessage,
          onRetry: _controller.retryLoad,
          isEmpty: _controller.isEmpty,
          emptyMessage: _controller.emptyMessage,
          onRefresh: _controller.refreshCurrentActivity,
          builder: (context) => ViewActivityDetailContent(
            activityType: type,
          ),
        );
      }),
    );
  }
}

/// Backward-compatible names for routes and imports.
typedef ViewEventScreen = ViewActivityScreen;
typedef ViewRouteScreen = ViewActivityScreen;
typedef ViewRafflesScreen = ViewActivityScreen;
