import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/core/utils/date_parser.dart';
import 'package:loci/data/models/raffles/raffles_model.dart';
import 'package:loci/presentation/controllers/raffles/raffle_list_controller.dart';
import 'package:loci/presentation/pages/raffles/raffles_details_screen.dart';
import 'package:loci/presentation/pages/raffles/widgets/date_range_helper.dart';
import 'package:loci/presentation/widgets/custom_button.dart';
import 'package:loci/presentation/widgets/custom_image_container.dart';
import 'package:loci/presentation/widgets/custom_text_field.dart';

class ActiveRafflesScreen extends StatelessWidget {
  const ActiveRafflesScreen({super.key});
  static final navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      onGenerateRoute: (_) =>
          MaterialPageRoute(builder: (_) => const ActiveRafflesPage()),
    );
  }
}

class ActiveRafflesPage extends StatefulWidget {
  const ActiveRafflesPage({super.key});

  @override
  State<ActiveRafflesPage> createState() => _ActiveRafflesPageState();
}

class _ActiveRafflesPageState extends State<ActiveRafflesPage> {
  final raffleListController = Get.find<RaffleListController>();



  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    raffleListController.fetchRaffles(isRefresh: true);
  }



  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: RefreshIndicator(
        onRefresh: () async {
          if (!raffleListController.isLoading) {
            await raffleListController.refreshRaffles();
          }
        },
        child: CustomScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  CustomTextField(
                    hintText: "Search Raffle",
                    borderColor: colorScheme.outline,
                    fontSize: 14,
                    textColor: colorScheme.onSurface,
                    hintTextColor: colorScheme.onSurfaceVariant,
                    suffixIcon: Icon(
                      Icons.search,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    "Active Raffles",
                    style: AppTextStyle.textXl(weight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Check in to locations to enter and win prizes",
                    style: AppTextStyle.textSm(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),

            GetBuilder<RaffleListController>(
              builder: (controller) {
                // loading state
                if (controller.isLoading) {
                  return SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                // Error state
                if (controller.errorMessage != null &&
                    controller.raffleList.isEmpty) {
                  return SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 48,
                            color: context.colorScheme.error,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            controller.errorMessage!,
                            style: AppTextStyle.textSm(
                              color: context.colorScheme.error,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          TextButton(
                            onPressed: () => controller.fetchRaffles(),
                            child: const Text("Try Again"),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                // Empty state
                if (controller.raffleList.isEmpty) {
                  return SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.event_busy,
                            size: 48,
                            color: context.colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            "No active raffles",
                            style: AppTextStyle.textSm(
                              color: context.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final raffleList=controller.raffleList;
                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _buildRaffleCard(raffleList[index]),
                    childCount: raffleList.length
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRaffleCard(RaffleModel raffle) {
    final colorScheme = context.colorScheme;
    const accentColor = Color(0xFF66B9AD);

    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      color: colorScheme.surfaceContainerHigh,
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomCachedImage(
            imageUrl: raffle.banner,
            height: 180,
            width: double.infinity,
            fit: BoxFit.cover,
            customBorderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  raffle.title,
                  style: AppTextStyle.textMd(weight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Text(
                  raffle.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyle.textXs(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 16),

                // bundle name
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 16,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withOpacity(0.2),
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
                const SizedBox(height: 16),

                // Date Row
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_outlined,
                      size: 14,
                      color: accentColor,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      dateRangeHelper(raffle.startDate, raffle.endDate),
                      style: AppTextStyle.textXs(weight: FontWeight.w500),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: CustomButton(
                    backgroundColor: colorScheme.primary,
                    textColor: colorScheme.onPrimary,
                    text:
                       // "Enter Raffle (${data['requiredCheckIns']} check-ins required)",
                    "Enter Raffle",
                    textStyle: AppTextStyle.textSm(weight: FontWeight.w600),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => RafflesDetailsScreen(
                            raffleId: raffle.id,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: Text(
                    "by ${raffle.organizerName}",
                    style: AppTextStyle.textXs(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }












}
