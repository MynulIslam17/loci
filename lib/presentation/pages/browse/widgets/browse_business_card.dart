import 'package:flutter/material.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/data/models/busniess/browse_business_model.dart';

import '../../../../core/theme/theme_extention.dart';
import '../../../widgets/custom_image_container.dart';


class BrowseBusinessCard extends StatelessWidget {
  final BrowseBusinessModel item;
  final bool isExpanded;
  final VoidCallback onTap;
  final VoidCallback onAdd;
  final VoidCallback onView;

  const BrowseBusinessCard({
    super.key,
    required this.item,
    required this.isExpanded,
    required this.onTap,
    required this.onAdd,
    required this.onView,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: context.colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isExpanded
                ? context.colorScheme.primary.withOpacity(0.5)
                : context.colorScheme.outline,
            width: isExpanded ? 1.5 : 0.8,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ================= HEADER =================
              Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: CustomCachedImage(
                        width: 52,
                        height: 52,
                        imageUrl: item.logo,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 12),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.name,
                            style: AppTextStyle.textSm(
                              weight: FontWeight.w600,
                              color: context.colorScheme.onSurface,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            item.category,
                            style: AppTextStyle.textXs(
                              color: context.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),

                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: context.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.star_rounded,
                            size: 13,
                            color: context.colorScheme.primary,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            item.rating.toStringAsFixed(1),
                            style: AppTextStyle.textXs(
                              color: context.colorScheme.primary,
                              weight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 8),

                    AnimatedRotation(
                      turns: isExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 300),
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 20,
                        color: context.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),

              // ================= EXPANDED =================
              AnimatedCrossFade(
                duration: const Duration(milliseconds: 300),
                crossFadeState: isExpanded
                    ? CrossFadeState.showFirst
                    : CrossFadeState.showSecond,
                firstChild: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Divider(
                      height: 1,
                      thickness: 0.6,
                      color: context.colorScheme.outline.withOpacity(0.2),
                    ),


                      CustomCachedImage(
                        width: double.infinity,
                        height: 160,
                        imageUrl: item.logo,
                        fit: BoxFit.cover,
                      ),

                    Padding(
                      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.description,
                            style: AppTextStyle.textXs(
                              color: context.colorScheme.onSurfaceVariant,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),

                          Row(
                            children: [
                              Icon(
                                Icons.location_on_outlined,
                                size: 13,
                                color:
                                context.colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  item.location,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyle.textXs(
                                    color:
                                    context.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),

                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: onAdd,
                                  icon: const Icon(Icons.add_circle_outline,
                                      size: 16),
                                  label: const Text("Add to list"),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: FilledButton.icon(
                                  onPressed: onView,
                                  icon: const Icon(
                                      Icons.remove_red_eye_outlined,
                                      size: 16),
                                  label: const Text("View page"),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                secondChild: const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}