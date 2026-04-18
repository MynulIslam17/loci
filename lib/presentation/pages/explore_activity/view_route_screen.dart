import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/presentation/controllers/explore_acitivity/business_route_details_controller.dart';
import 'package:loci/presentation/widgets/custom_appbar.dart';
import 'package:loci/presentation/widgets/custom_image_container.dart';
import '../../../gen/assets.gen.dart';
import '../../widgets/common/company_info_card.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/qrcode_maker.dart';

class ViewRouteScreen extends StatefulWidget {
  const ViewRouteScreen({super.key});

  @override
  State<ViewRouteScreen> createState() => _ViewRouteScreenState();
}

class _ViewRouteScreenState extends State<ViewRouteScreen> {
  late final String routeName;
  late final String routeId;

  final routeDetailsController =
  Get.find<BusinessRouteDetailsController>();

  @override
  void initState() {
    super.initState();

    var args = Get.arguments as Map<String, dynamic>?;

    routeName = args?["routeName"] ?? "";
    routeId = args?["routeId"] ?? "";

    routeDetailsController.fetchRouteDetails(routeId);
  }

  void _qrCodeDownloadHandler(BuildContext context, String qrCode) {
    CustomQrCode.show(
      context,
      data: qrCode,
      title: routeName,
      subtitle: "Scan this QR to check-in to this route",
      appName: "Loci",
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: CustomAppbar(title: routeName),

      body: GetBuilder<BusinessRouteDetailsController>(
        builder: (controller) {
          /// ===== LOADING =====
          if (controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          /// ===== ERROR =====
          if (controller.errorMessage != null) {
            return Center(child: Text(controller.errorMessage!));
          }

          /// ===== EMPTY =====
          if (controller.routeDetails == null) {
            return const Center(child: Text("No route found"));
          }

          final routeDetails = controller.routeDetails!;
          final route = routeDetails.routeModel;
          final organizer = routeDetails.organizerBusiness;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// 1. Banner Image
                _buildBanner(colorScheme, route.banner),

                const SizedBox(height: 18),

                /// 2. Title & Description
                Text(
                  route.title,
                  style: AppTextStyle.textMd(
                    weight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  route.details,
                  style: AppTextStyle.textXs(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),

                const SizedBox(height: 20),

                /// 3. Route Info
                _buildInfoRow(
                  Icons.location_on_outlined,
                  route.location,
                  colorScheme,
                ),
                const SizedBox(height: 8),

                _buildInfoRow(
                  Icons.access_time,
                  route.openingTime ?? "N/A",
                  colorScheme,
                ),
                const SizedBox(height: 8),

                _buildInfoRow(
                  Icons.speed,
                  route.activityType ?? "N/A",
                  colorScheme,
                ),

                const SizedBox(height: 24),

                /// 4. Check-in Counter
                _buildCheckInCounter(
                  colorScheme,
                  routeDetails.checkInCount,
                ),

                const SizedBox(height: 16),

                /// 5. QR Button
                CustomButton(
                  backgroundColor: colorScheme.primary,
                  textColor: colorScheme.onPrimary,
                  onPressed: () => _qrCodeDownloadHandler(
                    context,
                    routeDetails.qrCode,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.qr_code_scanner, size: 20),
                      const SizedBox(width: 10),
                      Text(
                        "Download QR code",
                        style: AppTextStyle.textSm(
                          weight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                /// 6. Map
                _buildMapPreview(colorScheme),

                const SizedBox(height: 24),

                /// 7. Organizer
                Text(
                  "Organizer",
                  style: AppTextStyle.textMd(
                    weight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 12),

                CompanyInfoCard(
                  title: organizer.name,
                  description: organizer.description ?? "__",
                  imagePath: organizer.logo ?? "",
                ),

                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  /// ===== BANNER =====
  Widget _buildBanner(ColorScheme colorScheme, String image) {
    return CustomCachedImage(
      height: 200,
      width: double.infinity,
      imageUrl: image,
    );
  }

  /// ===== INFO ROW =====
  Widget _buildInfoRow(
      IconData icon,
      String text,
      ColorScheme colorScheme,
      ) {
    return Row(
      children: [
        Icon(icon, size: 18, color: colorScheme.primary),
        const SizedBox(width: 10),
        Text(
          text,
          style: AppTextStyle.textSm(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  /// ===== CHECKIN COUNTER =====
  Widget _buildCheckInCounter(
      ColorScheme colorScheme,
      int count,
      ) {
    return Center(
      child: Card(
        elevation: 2,
        color: colorScheme.surfaceContainerHigh,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.person_outline,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "$count",
                    style: AppTextStyle.textLg(
                      weight: FontWeight.w700,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                "Check-ins",
                style: AppTextStyle.textXs(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// ===== MAP =====
  Widget _buildMapPreview(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.asset(
          Assets.images.location.path,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}