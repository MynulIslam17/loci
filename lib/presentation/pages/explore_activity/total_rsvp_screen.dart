import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/presentation/widgets/custom_appbar.dart';

import '../../widgets/custom_image_container.dart';
import '../../widgets/custom_text_field.dart';

class TotalRsvpScreen extends StatefulWidget {
  const TotalRsvpScreen({super.key});

  @override
  State<TotalRsvpScreen> createState() => _TotalRsvpScreenState();
}

class _TotalRsvpScreenState extends State<TotalRsvpScreen> {
  late String title;

  @override
  void initState() {
    super.initState();

    var args = Get.arguments;
    if (args != null && args is Map && args["title"] != null) {
      title = args["title"];
    } else {
      title = "Event Details";
    }
  }
  @override
  Widget build(BuildContext context) {

    final colorScheme=context.colorScheme;
    return Scaffold(
      appBar:CustomAppbar(title: title),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: CustomScrollView(
          slivers: [


            SliverToBoxAdapter(
              child:Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  // --- Search Bar ---

                  CustomTextField(
                    borderColor: context.colorScheme.outline,
                    hintText: "Explore Activities",
                    hintTextColor: context.colorScheme.onSurfaceVariant,
                    textColor: context.colorScheme.onSurface,
                    suffixIcon: Icon(
                      Icons.search,
                      color: context.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // --- Header Row ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Total RSVP list",
                        style: AppTextStyle.textLg(weight: FontWeight.w700),
                      ),
                      OutlinedButton.icon(
                        onPressed: () {},
                        icon:  Icon(Icons.save_alt, size: 18,color: colorScheme.onSurface),
                        label:  Text("Save",style: AppTextStyle.textSm(color: colorScheme.onSurface,weight: FontWeight.w500),),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ],
                  ),
                  Text("8 Leads", style: AppTextStyle.textXs(color: colorScheme.onSurfaceVariant)),
                  const SizedBox(height: 16),

                ],
              ),
            ),


            SliverList(

              delegate: SliverChildBuilderDelegate((context,index){

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 7),
                  child: _buildAttendeeCard(context),
                );
              },childCount: 5

              ),


            )



          ],
        ),
      ),
    );
  }

  Widget _buildAttendeeCard(BuildContext context) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      color: context.colorScheme.surfaceContainerHigh,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [

             CustomCachedImage(
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
                  Text("Alexandra Broke", style: AppTextStyle.textSm(weight: FontWeight.w700)),
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
        Text(text, style: AppTextStyle.textXs(color: context.colorScheme.onSurfaceVariant)),
      ],
    );
  }
}