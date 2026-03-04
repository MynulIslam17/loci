import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/app_colors.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/presentation/widgets/custom_button.dart';
import 'package:loci/presentation/widgets/custom_image_container.dart';

import '../../../gen/assets.gen.dart';
import '../../widgets/event_card.dart';

class EventDetails extends StatefulWidget {
  const EventDetails({super.key});

  @override
  State<EventDetails> createState() => _EventDetailsState();
}

class _EventDetailsState extends State<EventDetails> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Spring Pub Crawl Festival",
          style: AppTextStyle.textLg(weight: FontWeight.w600),
        ),
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [


              //--- top image--
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CustomCachedImage(
                  imageUrl: "assets/images/finedine.png",
                  height: 200,
                  width: double.infinity,
                  borderRadius: 10,
                )
              ),

              const SizedBox(height: 16),
              // ---- header section----
              _buildEventHeader(
                title: "Spring Pub Crawl Festival",
                description:
                    "Join us for the biggest pub crawl of the season! Visit 8 amazing bars in downtown and enjoy the night of your life, also there are special guest will participate too. Join us for the biggest pub crawl of the season! Visit 8 amazing bars in downtown and enjoy the night of your life, also there are special guest will participate too. ",
              ),
              const SizedBox(height: 16),

              //--- event Info Rows
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 3,
                    child: Column(
                      children: [
                        IconTextRow(
                          icon: Icons.calendar_today_outlined,
                          text: "Mon, Jan 19 at 2:50 PM",
                          iconColor: context.colorScheme.primary,
                        ),
                        const SizedBox(height: 8),
                        IconTextRow(
                          icon: Icons.location_on_outlined,
                          text: "Downtown District",
                          iconColor: context.colorScheme.primary,
                        ),
                        const SizedBox(height: 8),
                        IconTextRow(
                          icon: Icons.people_outline,
                          text: "0 going / 200 max",
                          iconColor: context.colorScheme.primary,
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),

                  ElevatedButton.icon(
                    icon: Icon(
                      Icons.qr_code,
                      color: context.colorScheme.onSurface,
                    ),
                    onPressed: () {},

                    style: ElevatedButton.styleFrom(
                      foregroundColor: context.colorScheme.onSurface,
                      backgroundColor: context.colorScheme.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    label: Text("Check In"),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              Card(
                color: context.colorScheme.surfaceContainerHigh,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: ClipRRect(
                    child: Image.asset(Assets.images.location.path),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              Text(
                "Owner",
                style: AppTextStyle.textMd(weight: FontWeight.w700),
              ),

              const SizedBox(height: 10,),

              SizedBox(
                width: double.infinity,

                child: Card(
                  color: context.colorScheme.surfaceContainerHigh,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.asset(Assets.images.companyLogo.path),
                        ),

                        const SizedBox(width: 20),

                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Marland Clutch",
                                style: AppTextStyle.textSm(
                                  weight: FontWeight.w700,
                                  color: context.colorScheme.primary,
                                ),
                              ),
                              Text(
                                "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text.",
                                style: AppTextStyle.textXs(
                                  color: context.colorScheme.onSurfaceVariant,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 4,
                              ),
                            ],
                          ),
                        ),

                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10,),

              CustomButton(
                text: "RSVP",
                onPressed: () {},

              )







            ],
          ),
        ),
      ),
    );
  }

  //--- helper widgets--------
  Widget _buildEventHeader({
    required String title,
    required String description,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyle.textMd(
            color: context.colorScheme.onSurface,
            weight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          description,
          style: AppTextStyle.textXs(
            color: context.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
