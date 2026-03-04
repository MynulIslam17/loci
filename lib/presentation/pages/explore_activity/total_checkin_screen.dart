import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/presentation/widgets/custom_appbar.dart';
import 'package:loci/presentation/widgets/custom_image_container.dart';
import 'package:loci/presentation/widgets/custom_text_field.dart';

class TotalCheckInScreen extends StatefulWidget {
  const TotalCheckInScreen({super.key});

  @override
  State<TotalCheckInScreen> createState() => _TotalCheckInScreenState();
}

class _TotalCheckInScreenState extends State<TotalCheckInScreen> {
  late String title;

  @override
  void initState() {
    super.initState();
    // Handling arguments with fallback
    var args = Get.arguments;
    if (args != null && args is Map && args["title"] != null) {
      title = args["title"];
    } else {
      title = "Check-Ins";
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return Scaffold(
      appBar: CustomAppbar(title: title),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),

                  // --- Search Bar ---
                  CustomTextField(
                    borderColor: colorScheme.outline,
                    hintText: "Search check-ins contacts ...",
                    hintTextColor: colorScheme.onSurfaceVariant,
                    textColor: colorScheme.onSurface,
                    suffixIcon: Icon(
                      Icons.search,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // --- Header Row ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Total Check-Ins",
                        style: AppTextStyle.textLg(weight: FontWeight.w700),
                      ),
                      OutlinedButton.icon(
                        onPressed: () {},
                        icon: Icon(Icons.save_alt, size: 18, color: colorScheme.onSurface),
                        label: Text(
                          "Save",
                          style: AppTextStyle.textSm(
                            color: colorScheme.onSurface,
                            weight: FontWeight.w500,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),

                        ),
                      ),
                    ],
                  ),

                  Text(
                    "8 Leads",
                    style: AppTextStyle.textXs(color: colorScheme.onSurfaceVariant),
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),

            // --- The Attendee List ---
            SliverList(
              delegate: SliverChildBuilderDelegate(
                    (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 7),
                    child: _buildAttendeeCard(context),
                  );
                },
                childCount: 8,
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildAttendeeCard(BuildContext context) {
    final colorScheme = context.colorScheme;

    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      color: colorScheme.surfaceContainerHigh,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // User Avatar
            const CustomCachedImage(
              width: 50,
              height: 50,
              imageUrl: "assets/images/user2.png",
              isCircle: true,
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Alexandra Broke",
                    style: AppTextStyle.textSm(weight: FontWeight.w700),
                  ),
                  const SizedBox(height: 6),
                  _buildDetailRow(Icons.business_outlined, "VP of Sales at TechCorp"),
                  const SizedBox(height: 4),
                  _buildDetailRow(Icons.email_outlined, "sarah.j@techcorp.com"),
                  const SizedBox(height: 4),
                  _buildDetailRow(Icons.phone_outlined, "555-0101"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: context.colorScheme.onSurfaceVariant),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: AppTextStyle.textXs(color: context.colorScheme.onSurfaceVariant),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}