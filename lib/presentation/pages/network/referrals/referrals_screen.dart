import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/presentation/controllers/network_dash/received_referrals_controller.dart';
import 'package:loci/presentation/controllers/network_dash/sent_referrals_controller.dart';
import 'package:loci/presentation/pages/network/referrals/tabs/received_referrals_tab.dart';
import 'package:loci/presentation/pages/network/referrals/tabs/sent_referrals_tab.dart';
import 'package:loci/presentation/widgets/custom_button.dart';
import 'package:loci/presentation/widgets/custom_text_field.dart';
import 'package:loci/routes/app_routes.dart';


class ReferralsScreen extends StatefulWidget {
  const ReferralsScreen({super.key});

  @override
  State<ReferralsScreen> createState() => _ReferralsScreenState();
}

class _ReferralsScreenState extends State<ReferralsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  SentReferralsController get _sentController =>
      Get.find<SentReferralsController>();
  ReceivedReferralsController get _receivedController =>
      Get.find<ReceivedReferralsController>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _sentController.onSearchChanged(query);
    _receivedController.onSearchChanged(query);
  }

  void _clearSearch() {
    _searchController.clear();
    _sentController.clearSearch();
    _receivedController.clearSearch();
  }

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;

    return Scaffold(
      backgroundColor: color.surface,
      appBar: AppBar(
        title: Text(
          'Referrals',
          style: AppTextStyle.textLg(weight: FontWeight.w700),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          /// STATIC HEADER
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                /// SEARCH
                ValueListenableBuilder<TextEditingValue>(
                  valueListenable: _searchController,
                  builder: (_, value, __) => CustomTextField(
                    controller: _searchController,
                    hintText: "Search Referral ..",
                    textColor: color.onSurface,
                    borderColor: color.outline,
                    onChanged: _onSearchChanged,
                    suffixIcon: value.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.close,
                                color: color.onSurfaceVariant),
                            onPressed: _clearSearch,
                          )
                        : Icon(Icons.search, color: color.onSurfaceVariant),
                  ),
                ),

                const SizedBox(height: 20),

                Text(
                  "Referrals",
                  style: AppTextStyle.textXl(weight: FontWeight.w600),
                ),

                const SizedBox(height: 5),

                Text(
                  "Manage your business referrals",
                  style: AppTextStyle.textSm(color: color.onSurfaceVariant),
                ),

                const SizedBox(height: 16),

                /// SEND REFERRAL BUTTON
                CustomButton(
                  backgroundColor: color.primary,
                  onPressed: () => Get.toNamed(AppRoutes.sendReferral),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.send_outlined, color: color.onPrimary),
                      const SizedBox(width: 8),
                      Text(
                        "Send New Referral",
                        style: AppTextStyle.textMd(
                          weight: FontWeight.w600,
                          color: color.onPrimary,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

              ],
            ),
          ),

          /// TAB BAR
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 5),
            child: TabBar(
              controller: _tabController,
              labelStyle: AppTextStyle.textSm(weight: FontWeight.w600),
              unselectedLabelStyle: AppTextStyle.textSm(),
              labelColor: color.primary,
              unselectedLabelColor: color.onSurfaceVariant,
              indicatorColor: color.primary,
              indicatorWeight: 4,
              indicatorSize: TabBarIndicatorSize.label,
              dividerColor: Colors.transparent,
              splashFactory: NoSplash.splashFactory,
              overlayColor: WidgetStateProperty.all(Colors.transparent),
              tabs: const [
                Tab(text: "Sent"),
                Tab(text: "Received"),
              ],
            ),
          ),
          const SizedBox(height: 4),

          /// TAB CONTENT
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [

                /// SENT TAB
                const SentReferralsTab(),

                /// RECEIVED TAB
                const ReceivedReferralsTab(),

              ],
            ),
          ),

        ],
      ),
    );
  }
}
