import 'package:flutter/material.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/presentation/widgets/custom_text_field.dart';

class ExploreRoutesScreen extends StatefulWidget {
  const ExploreRoutesScreen({super.key});

  @override
  State<ExploreRoutesScreen> createState() => _ExploreRoutesScreenState();
}

class _ExploreRoutesScreenState extends State<ExploreRoutesScreen> {
  final List<Map<String, dynamic>> routeData = [
    {
      "title": "Downtown Pub Crawl",
      "description":
          "Experience the best craft beer spots in downtown. Visit 8 amazing bars in downtown and enjoy the night of your life...",
      "location": "Downtown District",
      "duration": "3.0 h",
      "difficulty": "Easy",
      "imageUrl":
          "https://images.unsplash.com/photo-1514933651103-005eec06c04b?q=80&w=1000&auto=format&fit=crop",
    },
    {
      "title": "Historical Shop Hopping",
      "description":
          "Explore vintage boutiques and historical landmarks while discovering the city's hidden retail gems and local artisans...",
      "location": "Old Town District",
      "duration": "2.5 h",
      "difficulty": "Medium",
      "imageUrl":
          "https://images.unsplash.com/photo-1441986300917-64674bd600d8?q=80&w=1000&auto=format&fit=crop",
    },
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: CustomScrollView(
        slivers: [
          //-- 1. Static Header Section
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                //--- Search Bar
                CustomTextField(
                  hintText: "Search Routes",
                  hintTextColor: colorScheme.onSurfaceVariant,
                  fontSize: 14,
                  borderColor: colorScheme.outline,
                  textColor: colorScheme.onSurface,
                  suffixIcon: Icon(
                    Icons.search,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 24),
                //-- Title
                Text(
                  "Explore Routes",
                  style: AppTextStyle.textXl(
                    color: colorScheme.onSurface,
                    weight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                //--- Subtitle
                Text(
                  "Discover pub crawls, shop hopping, and scavenger hunts",
                  style: AppTextStyle.textSm(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),

          // 2. Dynamic List Section
          SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final route = routeData[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: _buildRouteCard(
                  context,
                  title: route["title"],
                  description: route["description"],
                  location: route["location"],
                  duration: route["duration"],
                  difficulty: route["difficulty"],
                  imageUrl: route["imageUrl"],
                ),
              );
            }, childCount: routeData.length),
          ),

          // Bottom Padding so the last card isn't cut off
          const SliverToBoxAdapter(child: SizedBox(height: 20)),
        ],
      ),
    );
  }

  Widget _buildRouteCard(
    BuildContext context, {
    required String title,
    required String description,
    required String location,
    required String duration,
    required String difficulty,
    required String imageUrl,
  }) {
    final colorScheme = context.colorScheme;

    return Card(
      color: colorScheme.surfaceContainerHigh,
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Section
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Image.network(
              imageUrl,
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),

          // Content Section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyle.textMd(
                    color: colorScheme.onSurface,
                    weight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyle.textXs(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 16),

                // Info Row (Location, Duration, Difficulty)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildInfoItem(
                      Icons.location_on_outlined,
                      location,
                      colorScheme,
                    ),
                    _buildInfoItem(Icons.access_time, duration, colorScheme),
                    _buildInfoItem(
                      Icons.explore_outlined,
                      difficulty,
                      colorScheme,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  //--helper widgets
  Widget _buildInfoItem(IconData icon, String label, ColorScheme colorScheme) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: const Color(0xFF66B9AD),
        ), // Teal accent from design
        const SizedBox(width: 4),
        Text(
          label,
          style: AppTextStyle.textXs(color: colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }
}
