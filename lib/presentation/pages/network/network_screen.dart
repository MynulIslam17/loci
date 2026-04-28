import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loci/core/enums/network_type.dart';
import 'package:loci/presentation/controllers/network_dash/connection_controller.dart';
import 'package:loci/presentation/widgets/app_skeleton.dart';
import 'package:loci/presentation/widgets/custom_image_container.dart';

import '../../../core/constants/app_text_style.dart';
import '../../../routes/app_routes.dart';

class NetworkScreen extends StatefulWidget {
  const NetworkScreen({super.key});

  @override
  State<NetworkScreen> createState() => _NetworkScreenState();
}

class _NetworkScreenState extends State<NetworkScreen> {
  final dashboardController = Get.find<ConnectionController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      dashboardController.fetchDashboard(NetworkType.checkins);
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: GetBuilder<ConnectionController>(
        builder: (controller) {
          if (controller.errorMessage != null) {
            return Center(child: Text(controller.errorMessage!));
          }

          final count = controller.counts;

          return RefreshIndicator(
            onRefresh: () async => controller.fetchDashboard(NetworkType.checkins),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  Text(
                    "Networking Dashboard",
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Overview of your network",
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // --- Stats Grid ---
                  controller.isLoading
                      ? AppSkeleton.list(context: context)
                      : GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.5,
                    children: [
                      _buildStatCard(
                        context,
                        "Total Contacts",
                        "${count?.connections ?? 0}",
                        Icons.people_outline,
                      ),
                      _buildStatCard(
                        context,
                        "Check-Ins",
                        "${count?.totalCheckIns ?? 0}",
                        Icons.person_outline,
                      ),
                      _buildStatCard(
                        context,
                        "Referrals Sent",
                        "${count?.referralsSent ?? 0}",
                        Icons.send_outlined,
                      ),
                      _buildStatCard(
                        context,
                        "Upcoming Meeting",
                        "${count?.upcomingMeetings ?? 0}",
                        Icons.handshake_outlined,
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),
                  Text(
                    "Quick Actions",
                    style: AppTextStyle.textMd(
                      color: colorScheme.onSurface,
                      weight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // --- Primary Quick Action Button ---
                  ElevatedButton.icon(
                    onPressed: controller.isLoading
                        ? null
                        : () => Get.toNamed(AppRoutes.checkIn),
                    icon: Icon(
                      Icons.grid_view_rounded,
                      color: colorScheme.onPrimary,
                    ),
                    label: Text(
                      "Check In",
                      style: AppTextStyle.textMd(weight: FontWeight.w600),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      minimumSize: const Size(double.infinity, 54),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                  ),

                  const SizedBox(height: 18),

                  // --- Secondary Action Buttons ---
                  Row(
                    children: [
                      _buildActionButton(context, "Referral"),
                      const SizedBox(width: 10),
                      _buildActionButton(context, "Connection"),
                      const SizedBox(width: 10),
                      _buildActionButton(context, "Meeting"),
                    ],
                  ),

                  const SizedBox(height: 24),
                  Text(
                    "Recent Check-Ins",
                    style: AppTextStyle.textMd(
                      color: colorScheme.onSurface,
                      weight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // --- Recent Check-In List ---
                  controller.isLoading
                      ? AppSkeleton.list(context: context)
                      : _buildRecentList(context),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ─── Stat Card ──────────────────────────────────────────────────────────────
  Widget _buildStatCard(BuildContext context, String label, String value, IconData icon) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      elevation: 2,
      color: colorScheme.surfaceContainerHigh,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: colorScheme.onSurface, size: 24),
              const SizedBox(width: 12),
              Text(
                value,
                style: AppTextStyle.textXl(
                  color: colorScheme.onSurface,
                  weight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: AppTextStyle.textXs(
              color: colorScheme.onSurfaceVariant,
              weight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Action Button ──────────────────────────────────────────────────────────
  Widget _buildActionButton(BuildContext context, String label) {
    final colorScheme = Theme.of(context).colorScheme;
    return Expanded(
      child: OutlinedButton(
        onPressed: () => _actionButtonHandler(label),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          side: BorderSide(color: colorScheme.outline),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          label,
          style: AppTextStyle.textSm(
            color: colorScheme.onSurface,
            weight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  // ─── Recent Check-In List ───────────────────────────────────────────────────
  Widget _buildRecentList(BuildContext context) {
    final checkInList = dashboardController.checkins;
    final colorScheme = Theme.of(context).colorScheme;

    if (checkInList.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Text("No recent check-ins", style: AppTextStyle.textSm(color: colorScheme.onSurfaceVariant)),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: checkInList.length,
      separatorBuilder: (_, __) => Divider(height: 1, color: colorScheme.outline.withOpacity(0.1)),
      itemBuilder: (context, index) {
        final checkIn = checkInList[index];
        return Card(
          elevation: 2,
          color: colorScheme.surfaceContainerHigh,
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            leading: CustomCachedImage(
              isCircle: true,
              width: 48,
              height: 48,
              imageUrl: checkIn.leadData.avatar,
            ),
            title: Text(
              checkIn.leadData.name,
              style: AppTextStyle.textSm(color: colorScheme.onSurface, weight: FontWeight.w700),
            ),
            subtitle: Text(
              checkIn.timeAgo,
              style: AppTextStyle.textXs(color: colorScheme.onSurfaceVariant).copyWith(fontSize: 10),
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainer, // Uses base500 (light) or dark800 (dark)
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                "Atlanta Tech Meetup",
                style: AppTextStyle.textXs(color: colorScheme.onSurface).copyWith(fontSize: 10),
              ),
            ),
          ),
        );
      },
    );
  }




  void _actionButtonHandler(String label) {
    switch (label) {
      case "Referral": Get.toNamed(AppRoutes.referral); break;
      case "Connection": Get.toNamed(AppRoutes.connection); break;
      case "Meeting": Get.toNamed(AppRoutes.meeting); break;
    }
  }
}


