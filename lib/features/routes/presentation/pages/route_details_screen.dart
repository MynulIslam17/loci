import 'package:flutter/material.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:get/get.dart';
import 'package:loci/features/routes/domain/services/routes_service.dart';
import 'package:loci/shared/widgets/error_state.dart';
import 'package:loci/routes/app_routes.dart';
import 'package:loci/core/enums/checkin_status.dart';
import 'package:loci/features/routes/presentation/controllers/route_details_controller.dart';
import 'package:loci/features/routes/presentation/widgets/route_details_skeleton.dart';
import 'package:loci/shared/widgets/company_info_card.dart';
import 'package:loci/shared/widgets/authenticated_map_image.dart';
import 'package:loci/shared/widgets/custom_image_container.dart';

class RouteDetailsScreen extends StatefulWidget {
  const RouteDetailsScreen({
    super.key,
    this.showAppbar = true,
    this.routeId,
    this.routeName,
  });
  final bool showAppbar; // to hide or show appbar
  final String? routeName;
  final String? routeId;

  @override
  State<RouteDetailsScreen> createState() => _RouteDetailsScreenState();
}

class _RouteDetailsScreenState extends State<RouteDetailsScreen> {
  late String routeName;
  late String routeId;
  late bool showAppbar;

  ///get x controller
  late final RouteDetailsController controller;
  bool _checkedInThisVisit = false;

  @override
  void initState() {
    super.initState();

    final args = Get.arguments as Map<String, dynamic>?;

    routeId = widget.routeId ?? args?['routeId']?.toString() ?? '';
    routeName = widget.routeName ?? args?['routeName']?.toString() ?? '';
    showAppbar = args?['showAppBar'] as bool? ?? widget.showAppbar;

    // Initialize controller if it exists, else put it
    if (Get.isRegistered<RouteDetailsController>()) {
      controller = Get.find<RouteDetailsController>();
    } else {
      controller = Get.put(RouteDetailsController(Get.find<RoutesService>()));
    }

    if (routeId.isNotEmpty) {
      controller.fetchRouteDetails(routeId);
    }
  }

  void _popWithResult() {
    Get.back(
      result: _checkedInThisVisit
          ? <String, dynamic>{
              'checkedIn': true,
              'entityId':
                  controller.routeDetails?.routeModel.routeId ?? routeId,
              'activityType': 'route',
            }
          : null,
    );
  }

  Future<void> _openCheckIn() async {
    final openRouteId =
        controller.routeDetails?.routeModel.routeId ?? routeId;

    final result = await Get.toNamed(
      AppRoutes.checkIn,
      arguments: {
        'type': 'route',
        'entityId': openRouteId,
      },
    );

    if (result is Map && result['checkedIn'] == true) {
      final checkedInId = result['entityId']?.toString();
      if (checkedInId == openRouteId) {
        controller.updateCheckInStatus(
          CheckInStatus.checkedIn,
          onlyIfId: openRouteId,
        );
        _checkedInThisVisit = true;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _popWithResult();
      },
      child: Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: showAppbar
          ? AppBar(
              title: Text(
                routeName,
                style: AppTextStyle.textMd(weight: FontWeight.w600),
              ),
              leading: IconButton(
                icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
                onPressed: () => Get.back(),
              ),
            )
          : null,
      body: Obx(() {
        if (controller.isLoading) {
          return const RouteDetailsSkeleton();
        }

        // --- Error state
        if (controller.errorMessage != null) {
          return ErrorStateWidget(
            message: controller.errorMessage!,
            onRetry: () => controller.fetchRouteDetails(routeId),
          );
        }

        // --- Normal state

        final business = controller.routeDetails?.organizerBusiness;
        final route = controller.routeDetails?.routeModel;

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Header Image Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: CustomCachedImage(
                  imageUrl: route?.banner,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  customBorderRadius: BorderRadius.circular(16),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      route?.title ?? "",
                      style: AppTextStyle.textLg(weight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      route?.details ?? "",
                      style: AppTextStyle.textXs(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 2. Info Section with Side Button
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _buildInfoRow(
                            colorScheme,
                            route?.location ?? "",
                            route?.openingTime ?? "",
                            route?.availabilityType ?? "",
                          ),
                        ),
                        const SizedBox(width: 8),
                        Obx(() {
                          final checkInStatus =
                              controller.routeDetails?.myCheckInStatus;
                          final isCheckedIn =
                              checkInStatus == CheckInStatus.checkedIn;

                          return ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 140),
                            child: ElevatedButton.icon(
                              icon: Icon(
                                isCheckedIn
                                    ? Icons.check_circle
                                    : Icons.qr_code,
                                size: 18,
                                color: context.colorScheme.onSurface,
                              ),
                              onPressed: isCheckedIn ? null : _openCheckIn,
                              style: ElevatedButton.styleFrom(
                                foregroundColor:
                                    context.colorScheme.onSurface,
                                backgroundColor: isCheckedIn
                                    ? context
                                        .colorScheme.surfaceContainerHigh
                                    : context.colorScheme.primary,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 10,
                                ),
                                visualDensity: VisualDensity.compact,
                                tapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                              label: Text(
                                checkInStatus?.label ?? 'Check In',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // 3. Interactive Map Section
                    Card(
                      color: colorScheme.surfaceContainerHigh,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: AuthenticatedMapImage(
                          imageUrl: controller.routeDetails?.mapImage,
                          height: 180,
                          latitude: controller.routeDetails?.coordinates.lat,
                          longitude: controller.routeDetails?.coordinates.lng,
                          locationLabel: route?.title,
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // 4. Owner Section
                    Text(
                      "Owner",
                      style: AppTextStyle.textMd(
                        weight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 12),
                    CompanyInfoCard(
                      title: business?.name ?? "",
                      description: business?.description ?? "",
                      imagePath: business?.logo ?? "",
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
      ),
    );
  }

  Widget _buildInfoRow(
    ColorScheme colorScheme,
    String location,
    String openingTime,
    String availabilityType,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoItem(Icons.location_on_outlined, location, colorScheme),
        const SizedBox(height: 8),
        _buildInfoItem(Icons.access_time, openingTime, colorScheme),
        const SizedBox(height: 8),
        _buildInfoItem(Icons.explore_outlined, availabilityType, colorScheme),
      ],
    );
  }

  Widget _buildInfoItem(IconData icon, String label, ColorScheme colorScheme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 18,
          color: const Color(0xFF66B9AD),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label.isEmpty ? '—' : label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyle.textXs(
              color: colorScheme.onSurfaceVariant,
              weight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
