import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/presentation/widgets/custom_text_field.dart';
import 'package:loci/routes/app_routes.dart';
import '../../controllers/event/event_list_controller.dart';
import 'widgets/event_card.dart';

class EventScreen extends StatefulWidget {
  const EventScreen({super.key});

  @override
  State<EventScreen> createState() => _EventScreenState();
}

class _EventScreenState extends State<EventScreen> {
  final eventController = Get.find<EventListController>();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        eventController.loadMoreEvents();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _eventOnTapHandler(String eventId) {
    Get.toNamed(AppRoutes.eventDetails, arguments: {'id': eventId});
  }

  void _rsvpOnTapHandler(String eventId) {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
          child: GetBuilder<EventListController>(
            builder: (controller) {

              // Loading
              if (controller.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              // Error
              if (controller.errorMessage != null &&
                  controller.eventList.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline,
                          size: 48, color: context.colorScheme.error),
                      const SizedBox(height: 12),
                      Text(
                        controller.errorMessage!,
                        style: AppTextStyle.textSm(
                            color: context.colorScheme.error),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () => controller.fetchEvents(),
                        child: const Text("Try Again"),
                      ),
                    ],
                  ),
                );
              }

              // Empty
              if (controller.eventList.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.event_busy,
                          size: 48,
                          color: context.colorScheme.onSurfaceVariant),
                      const SizedBox(height: 12),
                      Text(
                        "No upcoming events",
                        style: AppTextStyle.textSm(
                            color: context.colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                );
              }

              // ✅ Search + Header + List সব একসাথে scroll করবে
              return RefreshIndicator(
                onRefresh: () => controller.fetchEvents(isRefresh: true),
                child: CustomScrollView(
                  controller: _scrollController,
                  slivers: [

                    // Search + Header
                    SliverToBoxAdapter(
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
                        ],
                      ),
                    ),

                    // Event List
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                            (context, index) {

                          // Pagination loader
                          if (index == controller.eventList.length) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child: Center(child: CircularProgressIndicator()),
                            );
                          }

                          final event = controller.eventList[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: EventCard(
                              onTapCard: () => _eventOnTapHandler(event.id),
                              imageUrl: event.coverImage,
                              title: event.title,
                              description: event.description,
                              date: event.date,
                              location: event.location,
                              attendance:
                              "${event.goingCount} going / ${event.maxAttendees} max",
                              organizer: event.organizerName,
                              onRSVP: () => _rsvpOnTapHandler(event.id),
                            ),
                          );
                        },
                        childCount: controller.eventList.length +
                            (controller.isPaginationLoading ? 1 : 0),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}