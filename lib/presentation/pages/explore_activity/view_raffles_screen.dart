import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/utils/date_parser.dart'; // lib/core/utils/date_parser_helper.dart
import 'package:loci/data/models/raffles/raffles_details_model.dart';
import 'package:loci/presentation/widgets/custom_image_container.dart';
import 'package:loci/presentation/widgets/task_card.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import '../../controllers/explore_acitivity/business_raffle_detils_controller.dart';
import '../../widgets/common/company_info_card.dart';
import '../../widgets/custom_appbar.dart';

class ViewRafflesScreen extends StatefulWidget {
  const ViewRafflesScreen({super.key});

  @override
  State<ViewRafflesScreen> createState() => _ViewRafflesScreenState();
}

class _ViewRafflesScreenState extends State<ViewRafflesScreen> {
  final detailsController = Get.find<BusinessRaffleDetailsController>();

  late final String rafflesId;
  late final String rafflesName;

  @override
  void initState() {
    super.initState();

    var arg = Get.arguments as Map<String, dynamic>?;
    rafflesId = arg?["rafflesId"] ?? "";
    rafflesName = arg?["rafflesName"] ?? "";

    // Trigger the API call
    detailsController.fetchRaffleDetails(rafflesId);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: CustomAppbar(title: rafflesName),
      body: GetBuilder<BusinessRaffleDetailsController>(builder: (controller) {
        /// ===== LOADING =====
        if (controller.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        /// ===== ERROR =====
        if (controller.errorMessage != null) {
          return Center(child: Text(controller.errorMessage!));
        }

        /// ===== EMPTY =====
        if (controller.raffleDetails == null) {
          return const Center(child: Text("No raffles found"));
        }

        /// ===== DATA =====
        final rafflesDetails = controller.raffleDetails!;
        final raffle = rafflesDetails.raffleModel;
        final tasks = rafflesDetails.tasks;
        final sponsor = rafflesDetails.sponsor;

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// 1. Banner Image
              CustomCachedImage(
                imageUrl: raffle.banner,
                height: 250,
                width: double.infinity,
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// 2. Title
                    Text(
                      raffle.title,
                      style: AppTextStyle.textLg(weight: FontWeight.w700),
                    ),
                    const SizedBox(height: 6),

                    /// NEW: Date Row
                    _buildDateRow(
                        colorScheme,
                        "${DateParserHelper.shortDate(DateTime.parse(raffle.startDate))} - ${DateParserHelper.shortDate(DateTime.parse(raffle.endDate))}"
                    ),

                    const SizedBox(height: 12),

                    /// Description
                    Text(
                      raffle.description,
                      style: AppTextStyle.textSm(color: colorScheme.onSurfaceVariant),
                    ),
                    const SizedBox(height: 20),

                    /// 3. Highlight Card
                    _buildHighlightCard(colorScheme, raffle.bundleName),
                    const SizedBox(height: 20),

                    /// 4. Raffle Status Section
                    _buildRaffleStatus(colorScheme, rafflesDetails.totalTasks),
                    const SizedBox(height: 24),

                    /// 5. Tasks List
                    Text(
                      "Tasks required (Check-in):",
                      style: AppTextStyle.textMd(weight: FontWeight.w700),
                    ),
                    const SizedBox(height: 12),
                    _buildTaskListView(colorScheme, tasks),
                    const SizedBox(height: 24),

                    /// 6. Sponsor Section
                    Text(
                      "Sponsor",
                      style: AppTextStyle.textMd(weight: FontWeight.w700),
                    ),
                    const SizedBox(height: 12),
                    _buildSponsorCard(colorScheme, sponsor),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  /// Helper for the Date Row
  Widget _buildDateRow(ColorScheme colorScheme, String dateRange) {
    return Row(
      children: [
        Icon(Icons.calendar_today_outlined,
            size: 14, color: colorScheme.primary),
        const SizedBox(width: 6),
        Text(
          dateRange,
          style: AppTextStyle.textXs(
            color: colorScheme.primary,
            weight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildHighlightCard(ColorScheme colorScheme, String bundleName) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.primary.withOpacity(0.1)),
      ),
      child: Text(
        bundleName,
        style: AppTextStyle.textMd(
          color: colorScheme.primary,
          weight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildTaskListView(ColorScheme colorScheme, List<RaffleTaskModel> tasks) {
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        padding: const EdgeInsets.all(8),
        physics: const NeverScrollableScrollPhysics(),
        itemCount: tasks.length,
        separatorBuilder: (context, index) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final task = tasks[index];
          return TaskCard(
            id: "id_$index",
            // Displaying task type based on what's available
            title: task.routeActivity != null ? "Route Activity" : "Event Activity",
            description: "Task order: ${task.order}. Complete this check-in to progress.",
          );
        },
      ),
    );
  }

  Widget _buildRaffleStatus(ColorScheme colorScheme, int totalTasks) {
    const double progressValue = 0.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Raffle status:", style: AppTextStyle.textSm(weight: FontWeight.w700)),
            Text("${(progressValue * 100).toInt()}%",
                style: AppTextStyle.textSm(
                    weight: FontWeight.w700, color: colorScheme.primary)),
          ],
        ),
        const SizedBox(height: 10),
        LinearPercentIndicator(
          lineHeight: 10.0,
          percent: progressValue,
          backgroundColor: colorScheme.surfaceContainerHigh,
          progressColor: colorScheme.primary,
          barRadius: const Radius.circular(10),
          animation: true,
          animationDuration: 1000,
          padding: EdgeInsets.zero,
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("0 of $totalTasks Tasks Completed",
                style: AppTextStyle.textXs(color: colorScheme.onSurfaceVariant)),
            Text("$totalTasks remaining",
                style: AppTextStyle.textXs(
                    weight: FontWeight.w600, color: colorScheme.onSurface)),
          ],
        ),
      ],
    );
  }

  Widget _buildSponsorCard(ColorScheme colorScheme, SponsorModel sponsor) {
    return CompanyInfoCard(
      title: sponsor.name,
      description: "Official partner and sponsor.",
      imagePath: sponsor.logo,
    );
  }
}