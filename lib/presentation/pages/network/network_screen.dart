import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:loci/core/constants/app_text_style.dart';

import '../../../routes/app_routes.dart';

class NetworkScreen extends StatefulWidget {
  const NetworkScreen({super.key});

  @override
  State<NetworkScreen> createState() => _NetworkScreenState();
}

class _NetworkScreenState extends State<NetworkScreen> {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,

      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
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

            // --- Stats Grid Section ---
            GridView.count(
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
                  "0",
                  Icons.people_outline,
                ),
                _buildStatCard(context, "Check-Ins", "0", Icons.person_outline),
                _buildStatCard(
                  context,
                  "Referrals Sent",
                  "0",
                  Icons.send_outlined,
                ),
                _buildStatCard(
                  context,
                  "Upcoming Meeting",
                  "0",
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
              onPressed: () {},
              icon: Icon(Icons.grid_view_rounded, color: colorScheme.onPrimary),
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
            _buildRecentList(context),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Individual Stat Cards
  Widget _buildStatCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
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
              color: colorScheme.onSurface,
              weight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // Small Action Buttons (Referral, Network, etc.)
  Widget _buildActionButton(BuildContext context, String label) {
    final colorScheme = Theme.of(context).colorScheme;
    return Expanded(
      child: OutlinedButton(
        onPressed: () {
          _actionButtonHandler(label);
        },
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

  // Recent Check-In List Item
  Widget _buildRecentList(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 2,
      separatorBuilder: (context, index) =>
          Divider(height: 1, color: colorScheme.outline.withOpacity(0.2)),
      itemBuilder: (context, index) {
        return Card(
          color: colorScheme.surfaceContainerHigh,
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 4,
            ),
            leading: const CircleAvatar(
              radius: 17,
              backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=12'),
            ),
            title: Text(
              "Alexandra Broke",
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: AppTextStyle.textXs(
                color: colorScheme.onSurface,
                weight: FontWeight.w700,
              ),
            ),
            subtitle: Text(
              "43 min ago",
              style: AppTextStyle.textXs(
                color: colorScheme.onSurfaceVariant,
                weight: FontWeight.w500,
              ).copyWith(fontSize: 10),
            ),
            trailing: Card(
              color: colorScheme.surfaceContainerHigh,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                child: Text(
                  "Atlanta Tech Meetup",
                  style: AppTextStyle.textXs(
                    color: colorScheme.onSurface,
                    weight: FontWeight.w500,
                  ).copyWith(fontSize: 10),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  //--action handler for go to next route
  void _actionButtonHandler(String label) async {
    switch (label) {
      case "Referral":
        Get.toNamed(AppRoutes.referral);
        break;

      case "Connection":
        Get.toNamed(AppRoutes.connection);
        break;

      case "Meeting":
        Get.toNamed(AppRoutes.meeting);
        break;
    }
  }




}
