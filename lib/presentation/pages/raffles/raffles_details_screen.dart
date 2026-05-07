import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/presentation/controllers/raffles/raffle_details_controller.dart';
import 'package:loci/presentation/pages/raffles/widgets/date_range_helper.dart';
import 'package:loci/presentation/widgets/custom_appbar.dart';
import 'package:loci/routes/app_routes.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/models/raffles/raffles_details_model.dart';
import '../../widgets/custom_image_container.dart';

class RafflesDetailsScreen extends StatefulWidget {
  final String ? raffleId;
  final bool showAppBar;

  const RafflesDetailsScreen({super.key,  this.raffleId,  this.showAppBar=false});

  @override
  State<RafflesDetailsScreen> createState() => _RafflesDetailsScreenState();
}

class _RafflesDetailsScreenState extends State<RafflesDetailsScreen> {
  final rafflesDetailsController = Get.put(RaffleDetailsController());

  late final String activeRaffleId;
  late final bool showAppBar;

  @override
  void initState() {
    super.initState();

    final args = Get.arguments;

    if (args is Map<String, dynamic>) {
      activeRaffleId = args["raffleId"];
      showAppBar = args["showAppBar"] ?? true;
    } else {
      activeRaffleId = widget.raffleId!;
      showAppBar = widget.showAppBar;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      rafflesDetailsController.fetchRaffleDetails(activeRaffleId);
    });
  }


  void _taskHandler(RaffleTaskModel task) async {
    if (task.isCompleted) return;

    final activity = task.activity;

    await Get.toNamed(
      task.isRouteTask
          ? AppRoutes.routeDetails
          : AppRoutes.eventDetails,
      arguments: task.isRouteTask
          ? {
        "routeName": activity?.title,
        "routeId": activity?.id,
      }
          : {
        "eventTitle": activity?.title,
        "eventId": activity?.id,
      },
    );

    // AFTER COMING BACK → refresh raffle
    rafflesDetailsController.fetchRaffleDetails(activeRaffleId);
  }








  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar:showAppBar ? CustomAppbar(title: "Raffles Details")
      : null,
      body: GetBuilder<RaffleDetailsController>(
        builder: (controller) {
          if (controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.errorMessage != null) {
            return Center(child: Text(controller.errorMessage!));
          }

          if (controller.raffleDetails == null) {
            return const Center(child: Text("No data"));
          }

          final raffleDetails = controller.raffleDetails!;
          final raffle = raffleDetails.raffleModel;

          final tasks = raffleDetails.tasks;
          final total = tasks.length;
          final completed = tasks.where((e) => e.isCompleted).length;
          final percent = total == 0 ? 0.0 : completed / total;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 15),

                /// ─── Banner ─────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: CustomCachedImage(
                    imageUrl: raffle.banner,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    customBorderRadius: BorderRadius.circular(16),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// ─── Title ─────────────────────────────
                      Text(
                        raffle.title,
                        style: AppTextStyle.textLg(weight: FontWeight.w600),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        raffle.description,
                        style: AppTextStyle.textXs(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),

                      const SizedBox(height: 16),

                      /// ─── Bundle ─────────────────────────────
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          raffle.bundleName,
                          style: AppTextStyle.textSm(
                            color: colorScheme.primary,
                            weight: FontWeight.w600,
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      Text(
                        dateRangeHelper(
                          raffle.startDate,
                          raffle.endDate,
                        ),
                        style: AppTextStyle.textXs(color: AppColors.danger),
                      ),

                      const SizedBox(height: 24),

                      /// ─── Progress Section ─────────────────────────────
                      _buildProgressSection(
                        colorScheme,
                        percent,
                        total,
                        completed,
                      ),

                      const SizedBox(height: 24),

                      /// ─── Task List ─────────────────────────────
                      Card(
                        color: colorScheme.surfaceContainerHigh,
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: tasks.map((task) {
                              final activity = task.activity;

                              return _buildTaskItem(
                                name: activity?.title ?? "Unknown",
                                image: activity?.banner ?? "",
                                isCompleted: task.isCompleted,
                                colorScheme: colorScheme,
                                task: task,
                              );
                            }).toList(),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      /// ─── Sponsor ─────────────────────────────
                      Text(
                        "Sponsor",
                        style: AppTextStyle.textMd(weight: FontWeight.bold),
                      ),

                      const SizedBox(height: 12),

                      _buildSponsorCard(colorScheme, raffleDetails.sponsor),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ─────────────────────────────────────────
  // Progress Section
  // ─────────────────────────────────────────
  Widget _buildProgressSection(
      ColorScheme colorScheme,
      double percent,
      int total,
      int completed,
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Checked-in status:",
          style: AppTextStyle.textMd(
            weight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "You're doing great! Keep it up.",
              style: AppTextStyle.textXs(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            Text(
              "${(percent * 100).toInt()}%",
              style: AppTextStyle.textSm(
                weight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        LinearPercentIndicator(
          lineHeight: 8.0,
          percent: percent,
          padding: EdgeInsets.zero,
          backgroundColor: colorScheme.surfaceContainerHigh,
          progressColor: colorScheme.primary,
          barRadius: const Radius.circular(10),
          animation: true,
        ),

        const SizedBox(height: 8),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "$completed of $total tasks completed",
              style: AppTextStyle.textXs(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            Text(
              "${total - completed} remaining",
              style: AppTextStyle.textXs(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ─────────────────────────────────────────
  // Task Item
  // ─────────────────────────────────────────
  Widget _buildTaskItem({
    required String name,
    required String image,
    required bool isCompleted,
    required ColorScheme colorScheme,
    required RaffleTaskModel task,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(40),
        ),
        child: InkWell(
          onTap:()=>_taskHandler(task),

          child: Row(
            children: [
              Icon(
                isCompleted ? Icons.check_circle : Icons.add_circle,
                color: isCompleted ? Colors.green : colorScheme.primary,
                size: 32,
              ),

              const SizedBox(width: 12),

              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isCompleted ? Colors.green : colorScheme.primary,
                  ),
                  shape: BoxShape.circle,
                ),
                child: CustomCachedImage(
                  imageUrl: image,
                  isCircle: true,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: AppTextStyle.textSm(weight: FontWeight.bold),
                    ),
                    Text(
                      isCompleted ? "Completed" : "Tap to check-in",
                      style: AppTextStyle.textXs(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────
  // Sponsor Card
  // ─────────────────────────────────────────
  Widget _buildSponsorCard(
      ColorScheme colorScheme,
      SponsorModel sponsor,
      ) {
    return Card(
      margin: EdgeInsets.zero,
      color: colorScheme.surfaceContainerHigh,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              height: 60,
              width: 80,
              child: CustomCachedImage(
                imageUrl: sponsor.logo,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    sponsor.name,
                    style: AppTextStyle.textSm(
                      weight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                  Text(
                    sponsor.description,
                    maxLines: 2,
                    style: AppTextStyle.textXs(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}