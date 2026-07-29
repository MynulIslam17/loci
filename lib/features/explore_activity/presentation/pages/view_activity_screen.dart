import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/features/explore_activity/presentation/controllers/view_activity_controller.dart';
import 'package:loci/features/explore_activity/presentation/widgets/explore_activity_async_body.dart';
import 'package:loci/features/explore_activity/presentation/widgets/view_activity_detail_content.dart';
import 'package:loci/shared/widgets/custom_appbar.dart';

/// Single view screen for event, route, and raffle details.
class ViewActivityScreen extends GetView<ViewActivityController> {
  const ViewActivityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colorScheme.surface,
      appBar: CustomAppbar(title: controller.screenTitle),
      body: Obx(() {
        controller.activityType;
        return ExploreActivityAsyncBody(
          isLoading: controller.isLoading,
          errorMessage: controller.errorMessage,
          onRetry: controller.retryLoad,
          isEmpty: controller.isEmpty,
          emptyMessage: controller.emptyMessage,
          builder: (context) => ViewActivityDetailContent(
            activityType: controller.activityType,
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
