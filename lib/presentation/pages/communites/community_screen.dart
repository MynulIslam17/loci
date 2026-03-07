import 'package:flutter/material.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/presentation/widgets/custom_image_container.dart';

import '../../../core/theme/theme_extention.dart';
import '../home/home_screen.dart';

/// The first page of the Community tab
class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,

      body: Padding(
        padding: const EdgeInsets.all(12),
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Marland Clutch’s Community",
                    style: AppTextStyle.textMd(weight: FontWeight.w600),
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "23601 Hoover Rd, Warren, MI 48089",
                        style: AppTextStyle.textXs(),
                      ),
                      const SizedBox(width: 4),
                    ],
                  ),

                  const SizedBox(height: 16),



                  Container(
                    width: double.infinity,
                    height: 100,
                    child: Stack(children: [


                      CustomCachedImage(
                        width: double.infinity,
                          imageUrl: "assets/images/location.png"
                      ),

                       Positioned(
                           top: 10,
                           child: Text("Marland Clutch Centre")),





                    ],)
                  )

                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
