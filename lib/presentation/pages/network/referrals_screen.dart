import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/presentation/widgets/custom_button.dart';
import 'package:loci/presentation/widgets/custom_text_field.dart';
import 'package:loci/routes/app_routes.dart';

import '../../../core/enums/network_type.dart';
import '../../../core/enums/referral_enum.dart';
import '../../../core/utils/date_parser.dart';
import '../../controllers/network_dash/connection_controller.dart';
import 'widget/referral_card.dart';

class ReferralsScreen extends StatefulWidget {
  const ReferralsScreen({super.key});

  @override
  State<ReferralsScreen> createState() => _ReferralsScreenState();
}

class _ReferralsScreenState extends State<ReferralsScreen> {
  final controller = Get.find<ConnectionController>();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchDashboard(NetworkType.referrals);
    });
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
      body: GetBuilder<ConnectionController>(
        builder: (_) {
          final referrals = controller.referrals;

          if (controller.isLoading && referrals.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return RefreshIndicator(
            onRefresh: () async {
              await controller.refreshDashboard(NetworkType.referrals);
            },
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                const SizedBox(height: 10),

                /// SEARCH
                CustomTextField(
                  hintText: "Search Referral ..",
                  suffixIcon: Icon(
                    Icons.search,
                    color: color.onSurfaceVariant,
                  ),
                  textColor: color.onSurface,
                  borderColor: color.outline,
                ),

                const SizedBox(height: 20),

                Text(
                  "Referrals",
                  style: AppTextStyle.textXl(weight: FontWeight.w600),
                ),

                const SizedBox(height: 5),

                Text(
                  "Manage your business referrals",
                  style: AppTextStyle.textSm(
                    color: color.onSurfaceVariant,
                  ),
                ),

                const SizedBox(height: 16),

                /// BUTTON
                CustomButton(
                  backgroundColor: color.primary,
                  onPressed: () {
                    Get.toNamed(AppRoutes.sendReferral);
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.send_outlined,
                          color: color.onPrimary),
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

                const SizedBox(height: 20),

                /// LIST
                if (referrals.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 50),
                    child: Center(
                      child: Text(
                        "No referrals found",
                        style: AppTextStyle.textSm(
                          color: color.onSurfaceVariant,
                        ),
                      ),
                    ),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: referrals.length,
                    itemBuilder: (context, index) {
                      final r = referrals[index];

                      return ReferralCard(
                        status: r.status,
                        fromName: r.fromName,
                        fromCompany: r.fromCompany,
                        toName: r.toName,
                        toCompany: r.toCompany,
                        message: r.message,
                        date: DateParserHelper.eventDateTime(r.dateTime)
                      );
                    },
                    separatorBuilder: (_, __) =>
                    const SizedBox(height: 15),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}