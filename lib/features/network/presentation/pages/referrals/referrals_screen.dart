import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/features/network/presentation/controllers/received_referrals_controller.dart';
import 'package:loci/features/network/presentation/controllers/sent_referrals_controller.dart';
import 'package:loci/features/network/presentation/widgets/referrals/received_referrals_tab.dart';
import 'package:loci/features/network/presentation/widgets/referrals/sent_referrals_tab.dart';
import 'package:loci/shared/widgets/custom_button.dart';
import 'package:loci/shared/widgets/custom_text_field.dart';
import 'package:loci/shared/widgets/sticky_tab_bar.dart';
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
    final args = Get.arguments;
    final initialTab = (args is Map && args['initialTab'] == 'received') ? 1 : 0;
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: initialTab,
    );
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

  void _onClearSearch() {
    _searchController.clear();
    FocusScope.of(context).unfocus();
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
      body: NestedScrollView(
        headerSliverBuilder: (context, _) => [
          SliverToBoxAdapter(child: _buildHeader(color)),
          stickyTabBarSliver(
            backgroundColor: color.surface,
            tabBar: appStickyTabBar(
              controller: _tabController,
              colorScheme: color,
              labels: const ['Sent', 'Received'],
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: const [SentReferralsTab(), ReceivedReferralsTab()],
        ),
      ),
    );
  }

  Widget _buildHeader(ColorScheme color) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomTextField(
            controller: _searchController,
            hintText: 'Search Referral ..',
            textColor: color.onSurface,
            borderColor: color.outline,
            onChanged: _onSearchChanged,
            showClearButton: true,
            onClear: _onClearSearch,
            suffixIcon: Icon(Icons.search, color: color.onSurfaceVariant),
          ),
          const SizedBox(height: 20),
          Text(
            'Referrals',
            style: AppTextStyle.textXl(weight: FontWeight.w600),
          ),
          const SizedBox(height: 5),
          Text(
            'Manage your business referrals',
            style: AppTextStyle.textSm(color: color.onSurfaceVariant),
          ),
          const SizedBox(height: 16),
          CustomButton(
            backgroundColor: color.primary,
            onPressed: () => Get.toNamed(AppRoutes.sendReferral),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.send_outlined, color: color.onPrimary),
                const SizedBox(width: 8),
                Text(
                  'Send New Referral',
                  style: AppTextStyle.textMd(
                    weight: FontWeight.w600,
                    color: color.onPrimary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
