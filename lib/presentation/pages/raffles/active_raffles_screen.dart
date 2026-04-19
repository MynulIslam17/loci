import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/presentation/pages/raffles/raffles_details_screen.dart';
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
      onGenerateRoute: (_) => MaterialPageRoute(
        builder: (_) => const ActiveRafflesPage(),
      ),
    );
  }
}


class ActiveRafflesPage extends StatefulWidget {
  const ActiveRafflesPage({super.key});

  @override
  State<ActiveRafflesPage> createState() => _ActiveRafflesPageState();
}

class _ActiveRafflesPageState extends State<ActiveRafflesPage> {
  final List<Map<String, dynamic>> raffleData = [
    {
      "title": "Coffee Lovers Bundle",
      "description":
      "Check in to 3 or more local cafes to enter. Win raffles premium selection of artisanal coffee beans and raffles high-end French press.",
      "prize": "Premium Coffee Kit (\$200 value)",
      "endDate": "Mar 15, 2026",
      "requiredCheckIns": 3,
      "imageUrl": "https://images.unsplash.com/photo-1509042239860-f550ce710b93?q=80&w=1000&auto=format",
      "organizer": "Crawl Events Co.",
    },
    {
      "title": "Ultimate Pizza Night",
      "description":
      "Visit 5 participating pizzerias this month. Win raffles voucher for raffles full family feast plus raffles custom-made pizza stone.",
      "prize": "Gourmet Pizza Feast (\$120 value)",
      "endDate": "Mar 20, 2026",
      "requiredCheckIns": 5,
      "imageUrl": "https://images.unsplash.com/photo-1513104890138-7c749659a591?q=80&w=1000&auto=format",
      "organizer": "Loci Foodie Network",
    },
    {
      "title": "Tech Explorer Giveaway",
      "description":
      "Check in at any 2 technology hubs or co-working spaces. Win raffles pair of the latest noise-canceling wireless earbuds.",
      "prize": "Wireless Earbuds (\$250 value)",
      "endDate": "Apr 05, 2026",
      "requiredCheckIns": 2,
      "imageUrl": "https://images.unsplash.com/photo-1505740420928-5e560c06d30e?q=80&w=1000&auto=format",
      "organizer": "Innovation District",
    },
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: CustomScrollView(
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
          SliverList(
            delegate: SliverChildBuilderDelegate(
                  (context, index) => _buildRaffleCard(raffleData[index]),
              childCount: raffleData.length,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRaffleCard(Map<String, dynamic> data) {
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
            imageUrl: data['imageUrl'],
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
                  data['title'],
                  style: AppTextStyle.textMd(weight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Text(
                  data['description'],
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyle.textXs(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 16),

                // Prize Badge
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
                    data['prize'],
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
                      "Ends ${data['endDate']}",
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
                    text: "Enter Raffle (${data['requiredCheckIns']} check-ins required)",
                    textStyle: AppTextStyle.textSm(weight: FontWeight.w600),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => RafflesDetailsScreen(),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: Text(
                    "by ${data['organizer']}",
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

