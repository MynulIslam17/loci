import 'package:flutter/material.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:get/get.dart';
import 'package:loci/presentation/widgets/custom_button.dart';
import 'package:loci/presentation/widgets/error_state.dart';
import 'package:loci/routes/app_routes.dart';
import '../../../core/enums/checkin_status.dart';
import '../../controllers/routes/route_details_controller.dart';
import '../../widgets/common/company_info_card.dart';
import '../../widgets/custom_image_container.dart';

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

  ///get x controller
  late final RouteDetailsController controller;

  @override
  void initState() {
    super.initState();

    // Get arguments from either Get.arguments or constructor
    final args = Get.arguments as Map<String, dynamic>?;

    routeId = widget.routeId ?? args?['routeId'] ?? '';
    routeName = widget.routeName ?? args?['routeName'] ?? '';

    // Initialize controller if it exists, else put it
    if (Get.isRegistered<RouteDetailsController>()) {
      controller = Get.find<RouteDetailsController>();
    } else {
      controller = Get.put(RouteDetailsController());
    }

    if (routeId.isNotEmpty) {
      controller.fetchRouteDetails(routeId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: widget.showAppbar
          ? AppBar(
              // Dynamic title from arguments
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
      body: GetBuilder<RouteDetailsController>(
        builder: (controller) {
          if (controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // --- Error state
          if (controller.errorMessage != null) {
            return ErrorStateWidget(
              errorMessage: controller.errorMessage,
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
                          // Left side: Info Items
                          Expanded(
                            child: _buildInfoRow(
                              colorScheme,
                              route?.location ?? "",
                              route?.openingTime ?? "",
                              route?.availabilityType ?? "",
                            ),
                          ),

                          // Right side: Check In Button
                          GetBuilder<RouteDetailsController>(
                            builder: (controller) {
                              final checkInStatus =
                                  controller.routeDetails?.myCheckInStatus;
                              final isCheckedIn =
                                  checkInStatus == CheckInStatus.checkedIn;

                              return ElevatedButton.icon(
                                icon: Icon(
                                  isCheckedIn
                                      ? Icons.check_circle
                                      : Icons.qr_code,
                                  color: context.colorScheme.onSurface,
                                ),
                                onPressed: isCheckedIn
                                    ? null
                                    : () => Get.toNamed(
                                        AppRoutes.checkIn,
                                        arguments: {'type': 'route'},
                                      ),
                                style: ElevatedButton.styleFrom(
                                  foregroundColor:
                                      context.colorScheme.onSurface,
                                  backgroundColor: isCheckedIn
                                      ? context.colorScheme.surfaceContainerHigh
                                      : context.colorScheme.primary,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                ),
                                label: Text(checkInStatus?.label ?? 'Check In'),
                              );
                            },
                          ),
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
                          child: CustomCachedImage(
                            imageUrl: "assets/images/location.png",
                            height: 180,
                            width: double.infinity,
                            fit: BoxFit.cover,
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
        },
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
      children: [
        Icon(
          icon,
          size: 18,
          color: const Color(0xFF66B9AD),
        ), // Using accent teal
        const SizedBox(width: 8),
        Text(
          label,
          style: AppTextStyle.textXs(
            color: colorScheme.onSurfaceVariant,
            weight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
