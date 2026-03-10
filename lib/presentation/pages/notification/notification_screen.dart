import 'package:flutter/material.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/presentation/widgets/custom_appbar.dart';
import 'package:loci/presentation/widgets/custom_image_container.dart';

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
      "desc": "Alex send Referral! Michael would be a grea...",
      "time": "5:35 pm",
      "image": "assets/images/user1.jpg",
    },
    {
      "type": "meeting",
      "name": "Sarah request a meeting!",
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
              return ReferralCard(data: item);
            case "meeting":
              return MeetingCard(data: item);
            default:
              return NormalNotificationCard(data: item);
          }
        },
      ),
    );
  }
}

// --- 1. Normal Message Card ---
class NormalNotificationCard extends StatelessWidget {
  final Map<String, dynamic> data;
  const NormalNotificationCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomCachedImage(width: 50, height: 50, imageUrl: data["image"], isCircle: true),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(data["name"], style: AppTextStyle.textSm(color: colorScheme.onSurface, weight: FontWeight.w600)),
                  Text(data["desc"], style: AppTextStyle.textXs(color: colorScheme.onSurfaceVariant)),
                ],
              ),
            ),
            Text(data["time"], style: AppTextStyle.textXs(color: colorScheme.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}

// --- 2. Meeting Request Card ---
class MeetingCard extends StatelessWidget {
  final Map<String, dynamic> data;
  const MeetingCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Container(

        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Row(
              children: [
                CustomCachedImage(width: 45, height: 45, imageUrl: data["image"], isCircle: true),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(data["name"], style: AppTextStyle.textSm(weight: FontWeight.w600)),
                      Text("Meeting Request", style: AppTextStyle.textXs(color: const Color(0xFF62B4AC), weight: FontWeight.w600)),
                    ],
                  ),
                ),
                Text(data["time"], style: AppTextStyle.textXs(color: colorScheme.onSurfaceVariant)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF62B4AC),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text("Confirm"),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.redAccent,
                      side: const BorderSide(color: Colors.redAccent),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text("Reject"),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

// --- 3. Referral Card ---
class ReferralCard extends StatelessWidget {
  final Map<String, dynamic> data;
  const ReferralCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Container(

        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF62B4AC).withOpacity(0.1), // Distinct background for referrals
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF62B4AC).withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.stars, color: Color(0xFF62B4AC), size: 20),
                const SizedBox(width: 8),
                Text("New Referral", style: AppTextStyle.textXs(color: const Color(0xFF62B4AC), weight: FontWeight.w700)),
                const Spacer(),
                Text(data["time"], style: AppTextStyle.textXs(color: colorScheme.onSurfaceVariant)),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                CustomCachedImage(width: 40, height: 40, imageUrl: data["image"], isCircle: true),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(data["desc"], style: AppTextStyle.textSm(color: colorScheme.onSurface)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF62B4AC),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text("Accept Referral"),
              ),
            )
          ],
        ),
      ),
    );
  }
}