import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/presentation/widgets/custom_text_field.dart';
import 'package:loci/routes/app_routes.dart';

import 'widgets/event_card.dart';

class EventScreen extends StatefulWidget {
  const EventScreen({super.key});

  @override
  State<EventScreen> createState() => _EventScreenState();
}

class _EventScreenState extends State<EventScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomTextField(
                  borderColor: context.colorScheme.outline,
                  hintText: "Search Event",
                  hintTextColor: context.colorScheme.onSurfaceVariant,
                  textColor: context.colorScheme.onSurface,
                  suffixIcon: Icon(
                    Icons.search,
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                ),

                const SizedBox(height: 16),

                Text(
                  "Upcoming Events",
                  style: AppTextStyle.textXl(
                    color: context.colorScheme.onSurface,
                    weight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "RSVP to the events which you interested",
                  style: AppTextStyle.textSm(
                    color: context.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 16),

                //-- Event card ---
                ListView.separated(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: 3,
                  itemBuilder: (context, index) {
                    return EventCard(
                      imageUrl: "assets/images/finedine.png",
                      title: "Spring Pub Crawl Festival",
                      description:
                          "Join us for the biggest pub crawl of the season! Visit 8 amazing bars...",
                      date: "Mon, Jan 19 at 2:50 PM",
                      location: "Downtown District",
                      attendance: "0 going / 200 max",
                      organizer: "Crawl Events Co.",
                      onRSVP: () {
                        Get.toNamed(AppRoutes.eventDetails);
                      },
                    );
                  },
                  separatorBuilder: (BuildContext context, int index) {
                    return const SizedBox(height: 6);
                  },




                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
