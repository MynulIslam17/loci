import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loci/presentation/pages/communites/widgets/community_card.dart';
import 'package:loci/presentation/pages/home/home%20navigator.dart';
import 'package:loci/presentation/widgets/custom_appbar.dart';
import '../../../core/theme/theme_extention.dart';
import '../../../core/constants/app_text_style.dart';
import '../../../routes/app_routes.dart';
import '../../controllers/community/all_community_controller.dart';
import '../../widgets/custom_text_field.dart';

class AllCommunityScreen extends StatelessWidget {
  const AllCommunityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: const CustomAppbar(title: "Communities"),
      body: GetBuilder<AllCommunityController>(
        initState: (_) {
          Get.find<AllCommunityController>().fetchCommunities();
        },

        builder: (controller) {
          return RefreshIndicator(
            onRefresh: controller.refreshCommunities,
            child: SingleChildScrollView(
              controller: controller.scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  CustomTextField(
                    hintText: "Search Community",
                    borderColor: colorScheme.outline,
                    fontSize: 14,
                    textColor: colorScheme.onSurface,
                    hintTextColor: colorScheme.onSurfaceVariant,
                    suffixIcon: Icon(
                      Icons.search,
                      size: 22,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    "My Community",
                    style: AppTextStyle.textLg(weight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  controller.isLoading && controller.joined.isEmpty
                      ? const Center(child: CircularProgressIndicator())
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: controller.joined.length,
                          itemBuilder: (context, index) {
                            final joinedCommunity = controller.joined[index];
                            return CommunityCard(
                              communityOnTap: () {},
                              title: joinedCommunity.name,
                              communityLogo: joinedCommunity.image,
                              category: joinedCommunity.category.label,
                              members: joinedCommunity.members,
                              description: joinedCommunity.description,
                            );
                          },
                        ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Business Communities",
                        style: AppTextStyle.textLg(weight: FontWeight.bold),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: Text(
                          "view all",
                          style: AppTextStyle.textSm(
                            color: colorScheme.primary,
                            weight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  controller.isLoading && controller.available.isEmpty
                      ? const Center(child: CircularProgressIndicator())
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: controller.available.length,
                          itemBuilder: (context, index) {
                            final community = controller.available[index];
                            return CommunityCard(
                              communityOnTap: () {
                                HomeNavigator.push(AppRoutes.communityScreen);
                              },
                              communityLogo: community.image,
                              title: community.name,
                              category: community.category.label,
                              members: community.members,
                              description: community.description,

                            );
                          },
                        ),
                  // Pagination loading indicator
                  if (controller.isPaginationLoading)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Center(child: CircularProgressIndicator()),
                    ),

                  // ... No more communities message ...
                  if (!controller.hasMore && controller.available.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Center(
                        child: Text(
                          "No more communities",
                          style: AppTextStyle.textSm(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
