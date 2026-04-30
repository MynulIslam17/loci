import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:loci/core/enums/category_enum.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/presentation/pages/browse/widgets/business_category_card.dart';
import '../../../core/constants/app_text_style.dart';
import '../../../routes/app_routes.dart';

class BrowseScreen extends StatefulWidget {
  const BrowseScreen({super.key});

  @override
  State<BrowseScreen> createState() => _BrowseScreenState();
}

class _BrowseScreenState extends State<BrowseScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colorScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Discover your place",
                  style: AppTextStyle.textXl(
                    weight: FontWeight.w700,
                    color: context.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "What are you in the mood for today?",
                  style: AppTextStyle.textSm(
                    color: context.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 16),

                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 1.1,
                  ),
                  itemCount: BusinessCategory.values.length,
                  itemBuilder: (context, index) {
                    final category = BusinessCategory.values[index];

                    return BusinessCategoryCard(
                      category: category,
                      onTap: () => _placeHandler(category),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _placeHandler(BusinessCategory category) {
    Get.toNamed(
      AppRoutes.browseBusiness,
      arguments: category,
    );
  }

}