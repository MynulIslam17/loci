import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/enums/category_enum.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/features/browse_business/presentation/widgets/business_category_card.dart';
import 'package:loci/routes/app_routes.dart';

class BrowseScreen extends StatefulWidget {
  const BrowseScreen({super.key});

  @override
  State<BrowseScreen> createState() => _BrowseScreenState();
}

class _BrowseScreenState extends State<BrowseScreen> {
  void _placeHandler(BusinessCategory category) {
    HapticFeedback.lightImpact();
    Get.toNamed(AppRoutes.browseBusiness, arguments: category);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;

    return Scaffold(
      backgroundColor: colors.surface,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── 1. Clean & Modern Hero Welcome Banner (Gradient Tint) ────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      colors.primary.withValues(alpha: 0.12),
                      colors.surfaceContainerHigh,
                    ],
                  ),
                  border: Border.all(
                    color: colors.primary.withValues(alpha: 0.18),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: colors.primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: colors.primary.withValues(alpha: 0.25),
                              width: 0.8,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.explore_rounded,
                                size: 14,
                                color: colors.primary,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                'Explore Loci',
                                style: AppTextStyle.textXs(
                                  color: colors.primary,
                                  weight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Discover your place',
                      style: AppTextStyle.textXl(
                        weight: FontWeight.w800,
                        color: colors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'What are you in the mood for today?',
                      style: AppTextStyle.textSm(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ── 2. Section Header: All Categories ─────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Categories',
                    style: AppTextStyle.textLg(
                      weight: FontWeight.w700,
                      color: colors.onSurface,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: colors.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${BusinessCategory.values.length} Categories',
                      style: AppTextStyle.textXs(
                        color: colors.onSurfaceVariant,
                        weight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // ── 3. Centered Professional Category Grid ────────────────
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.05,
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
    );
  }
}
