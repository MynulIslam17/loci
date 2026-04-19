import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/app_colors.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/presentation/widgets/custom_appbar.dart';
import 'package:loci/presentation/widgets/custom_image_container.dart';

import '../../../routes/app_routes.dart';
import '../network/widget/referral_card.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  // --- Data Structure with specific Types ---
  final List<Map<String, dynamic>> notificationData = [
    {
      "type": "referral",
      "name": "Alex send Referral!",
      "desc": "Alex send Referral! Michael would be raffles grea..."*4,
      "time": "5:35 pm",
      "image": "assets/images/user1.jpg",
    },
    {
      "type": "meeting",
      "name": "Sarah request raffles meeting!",
      "desc": "Let's do meeting about our future plan for t...",
      "time": "5:35 pm",
      "image": "assets/images/user2.jpg",
    },
    {
      "type": "normal",
      "name": "Alex answer your Question!",
      "desc": "Any food that your liked recently? Barclay...",
      "time": "5:35 pm",
      "image": "assets/images/user1.jpg",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppbar(title: "Notifications"),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: notificationData.length,
        itemBuilder: (context, index) {
          final item = notificationData[index];

          // Logic to return specific card based on type
          switch (item["type"]) {
            case "referral":
              return CustomNotificationCard(data: item, onConfirm: () {  }, onReject: () {  }, onTapBody: () {

                Get.toNamed(AppRoutes.referralsInvitation,);
              },);
            case "meeting":
              return CustomNotificationCard(data: item, onConfirm: () {  }, onReject: () {  }, onTapBody: () {
                Get.toNamed(AppRoutes.meetingInvitation,);
              },);
            default:
              return NormalNotificationCard(data: item, onTapBody: () {  },);
          }
        },
      ),
    );
  }
}

// --- 1. Normal Message Card ---
class NormalNotificationCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final VoidCallback onTapBody;

  const NormalNotificationCard({super.key, required this.data, required this.onTapBody});

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Material(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTapBody,
          splashColor: colorScheme.primary.withOpacity(0.3),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomCachedImage(
                    width: 50, height: 50, imageUrl: data["image"], isCircle: true),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data["name"],
                        style: AppTextStyle.textSm(
                            color: colorScheme.onSurface, weight: FontWeight.w600),
                      ),
                      Text(
                        data["desc"],
                        style: AppTextStyle.textXs(
                            color: colorScheme.onSurfaceVariant, weight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
                Text(
                  data["time"],
                  style: AppTextStyle.textXs(color: colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// --- 2. Meeting Request Card ---
class CustomNotificationCard extends StatelessWidget {

  final VoidCallback onConfirm;
  final VoidCallback onReject;
  final VoidCallback onTapBody;
  final Map<String, dynamic> data;

  const CustomNotificationCard({
    super.key,
    required this.data,
    required this.onConfirm,
    required this.onReject,
    required this.onTapBody});

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
     return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Material(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTapBody,
          splashColor: colorScheme.primary.withOpacity(0.3),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Row(
                  children: [
                    CustomCachedImage(
                        width: 45, height: 45, imageUrl: data["image"], isCircle: true),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(data["name"],
                              style: AppTextStyle.textSm(weight: FontWeight.w600)),
                          Text(
                            data["desc"],
                            style: AppTextStyle.textXs(
                                color: colorScheme.onSurfaceVariant, weight: FontWeight.w500),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 4,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 7),
                    Text(data["time"],
                        style: AppTextStyle.textXs(color: colorScheme.onSurfaceVariant)),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: onConfirm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF62B4AC),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text("Confirm"),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: onReject,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.redAccent,
                          side: const BorderSide(color: Colors.redAccent),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text("Reject"),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

