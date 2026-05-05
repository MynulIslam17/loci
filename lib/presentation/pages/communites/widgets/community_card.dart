import 'package:flutter/material.dart';
import 'package:loci/core/enums/community_role.dart';
import 'package:loci/presentation/widgets/custom_button.dart';
import 'package:loci/presentation/widgets/custom_image_container.dart';
import '../../../../core/constants/app_text_style.dart';
import '../../../../core/theme/theme_extention.dart';

class CommunityCard extends StatelessWidget {
  final String title;
  final String category;
  final String members;
  final String communityLogo;
  final String description;
  final VoidCallback ? communityOnTap;
  final VoidCallback? onJoinTap;
  final bool isJoining;
  final CommunityRole? role;

  const CommunityCard({
    super.key,
    required this.title,
    required this.category,
    required this.members,
    required this.description,
    required this.communityLogo,
     this.communityOnTap,
    this.isJoining = false,
    this.onJoinTap,
    this.role,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return Card(
      color: colorScheme.surfaceContainerHigh,
      elevation: 1,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: communityOnTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Community Avatar
                  CustomCachedImage(
                    width: 50,
                    height: 50,
                    isCircle: true,
                    imageUrl: communityLogo,
                  ),

                  const SizedBox(width: 12),

                  /// Title & Category
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: AppTextStyle.textMd(weight: FontWeight.bold),
                        ),
                        Text(
                          category,
                          style: AppTextStyle.textSm(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),

                  /// Members + Role Badge
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (role != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          margin: const EdgeInsets.only(bottom: 4),
                          decoration: BoxDecoration(
                            color: role == CommunityRole.owner
                                ? Colors.orange.withOpacity(0.1)
                                : colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            role!.label.toUpperCase(),
                            style: AppTextStyle.textXs(
                              color: role == CommunityRole.owner
                                  ? Colors.orange
                                  : colorScheme.primary,
                              weight: FontWeight.w600,
                            ),
                          ),
                        ),

                      /// Member Count
                      Row(
                        children: [
                          Icon(
                            Icons.people_outline,
                            size: 16,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            members,
                            style: AppTextStyle.textSm(
                              color: colorScheme.onSurfaceVariant,
                              weight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 12),

              /// Description
              Text(
                description,
                style: AppTextStyle.textSm(
                  color: colorScheme.onSurfaceVariant,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 12),

              /// Join Button
              if (onJoinTap != null)
                Align(
                  alignment: Alignment.topRight,
                  child: CustomButton(
                    text: "Join",
                    width: 100,
                    height: 40,
                    isLoading: isJoining,
                    onPressed: isJoining ? null : onJoinTap,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}