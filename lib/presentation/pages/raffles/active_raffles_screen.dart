import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/core/utils/date_parser.dart';
import 'package:loci/data/models/raffles/raffles_model.dart';
import 'package:loci/presentation/controllers/raffles/raffle_list_controller.dart';
import 'package:loci/presentation/pages/raffles/raffles_details_screen.dart';
import 'package:loci/presentation/pages/raffles/widgets/date_range_helper.dart';
import 'package:loci/presentation/pages/raffles/widgets/raffle_card.dart';
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

                final raffleList = controller.raffleList;
                return SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final raffle = raffleList[index];

                    return RaffleCard(
                      raffle: raffle,

                      onTap: () {
                        //TODO : navigate to raffle details screen
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                RafflesDetailsScreen(raffleId: raffle.id),
                          ),


                        );
                      },
                    );
                  }, childCount: raffleList.length),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
