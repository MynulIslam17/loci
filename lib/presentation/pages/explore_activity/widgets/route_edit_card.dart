// import 'package:flutter/material.dart';
// import 'package:loci/core/theme/theme_extention.dart';
// import 'package:loci/presentation/widgets/custom_image_container.dart';
//
// import '../../../../core/constants/app_text_style.dart';
//
//
// class RouteEditCard extends StatelessWidget {
//   final String title;
//   final String description;
//   final String location;
//   final String duration;
//   final String difficulty;
//   final String imageUrl;
//   final VoidCallback onEdit;
//   final VoidCallback onView;
//
//   const RouteEditCard({
//     super.key,
//     required this.title,
//     required this.description,
//     required this.location,
//     required this.duration,
//     required this.difficulty,
//     required this.imageUrl,
//     required this.onEdit,
//     required this.onView,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final colorScheme = context.colorScheme;
//
//     return Card(
//       color: colorScheme.surfaceContainerHigh,
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // 1. Image Section with Rounded Tops
//           CustomCachedImage(
//             imageUrl: imageUrl,
//             height: 160,
//             width: double.infinity,
//             fit: BoxFit.cover,
//             customBorderRadius: BorderRadius.vertical(top: Radius.circular(16)),
//           ),
//
//           Padding(
//             padding: const EdgeInsets.all(12.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // 2. Route Title
//                 Text(
//                   title,
//                   style: AppTextStyle.textMd(
//                     weight: FontWeight.w700,
//                     color: colorScheme.onSurface,
//                   ),
//                 ),
//                 const SizedBox(height: 6),
//
//                 // 3. Shortened Description
//                 Text(
//                   description,
//                   maxLines: 2,
//                   overflow: TextOverflow.ellipsis,
//                   style: AppTextStyle.textXs(
//                     color: colorScheme.onSurfaceVariant,
//                   ),
//                 ),
//                 const SizedBox(height: 12),
//
//                 // 4. Horizontal Meta Info Row
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     _buildMetaItem(
//                       context,
//                       Icons.location_on_outlined,
//                       location,
//                     ),
//                     _buildMetaItem(context, Icons.access_time, duration),
//                     _buildMetaItem(context, Icons.explore_outlined, difficulty),
//                   ],
//                 ),
//                 const SizedBox(height: 16),
//
//                 // 5. Solid Management Buttons
//                 Row(
//                   children: [
//                     Expanded(
//                       child: OutlinedButton.icon(
//                         onPressed: onEdit,
//                         style: OutlinedButton.styleFrom(
//                           side: BorderSide(color: colorScheme.outlineVariant),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(10),
//                           ),
//                           padding: const EdgeInsets.symmetric(vertical: 12),
//                         ),
//                         icon: Icon(
//                           Icons.edit_outlined,
//                           size: 18,
//                           color: colorScheme.onSurface,
//                         ),
//                         label: Text(
//                           "Edit Info",
//                           style: AppTextStyle.textSm(
//                             weight: FontWeight.w600,
//                             color: colorScheme.onSurface,
//                           ),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(width: 12),
//                     Expanded(
//                       child: ElevatedButton(
//                         onPressed: onView,
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: colorScheme.primary,
//                           elevation: 0,
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(10),
//                           ),
//                           padding: const EdgeInsets.symmetric(vertical: 12),
//                         ),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Text(
//                               "View Details",
//                               style: AppTextStyle.textSm(
//                                 weight: FontWeight.w600,
//                                 color: Colors.white,
//                               ),
//                             ),
//                             const SizedBox(width: 4),
//                             const Icon(
//                               Icons.arrow_forward,
//                               size: 18,
//                               color: Colors.white,
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildMetaItem(BuildContext context, IconData icon, String text) {
//     final colorScheme = context.colorScheme;
//     return Row(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         Icon(icon, size: 14, color: colorScheme.primary),
//         const SizedBox(width: 4),
//         Text(
//           text,
//           style: AppTextStyle.textXs(
//             color: colorScheme.onSurfaceVariant,
//             weight: FontWeight.w500,
//           ),
//         ),
//       ],
//     );
//   }
// }

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/app_text_style.dart';
import '../../../../core/theme/theme_extention.dart';
import '../../../widgets/custom_image_container.dart';

class RouteEditCard extends StatelessWidget {
  final String title;
  final String description;
  final String location;
  final String openingTime;
  final String availabilityType;
  final bool isPublic;
  final String imageUrl;
  final VoidCallback onEdit;
  final VoidCallback onView;

  const RouteEditCard({
    super.key,
    required this.title,
    required this.description,
    required this.location,
    required this.openingTime,
    required this.availabilityType,
    required this.isPublic,
    required this.imageUrl,
    required this.onEdit,
    required this.onView,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return Card(
      color: colorScheme.surfaceContainerHigh,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomCachedImage(
            imageUrl: imageUrl,
            height: 160,
            width: double.infinity,
            fit: BoxFit.cover,
            customBorderRadius:
            const BorderRadius.vertical(top: Radius.circular(16)),
          ),

          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // title + public badge
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: AppTextStyle.textMd(
                          weight: FontWeight.w700,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: isPublic
                            ? colorScheme.primary.withOpacity(0.1)
                            : colorScheme.outline.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        isPublic ? "Public" : "Private",
                        style: AppTextStyle.textXs(
                          color: isPublic
                              ? colorScheme.primary
                              : colorScheme.onSurfaceVariant,
                          weight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 6),

                Text(
                  description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style:
                  AppTextStyle.textXs(color: colorScheme.onSurfaceVariant),
                ),

                const SizedBox(height: 12),

                // meta row
                Wrap(
                  spacing: 2,
                  runSpacing: 10,
                  children: [
                    _buildMetaItem(
                        context, Icons.location_on_outlined, location),
                    const SizedBox(width: 16),
                    _buildMetaItem(
                        context, Icons.access_time, openingTime),
                    const SizedBox(width: 16),
                    _buildMetaItem(
                        context, Icons.event_available_outlined, availabilityType),
                  ],
                ),

                const SizedBox(height: 16),

                // buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onEdit,
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: colorScheme.outlineVariant),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        icon: Icon(Icons.edit_outlined,
                            size: 18, color: colorScheme.onSurface),
                        label: Text(
                          "Edit Info",
                          style: AppTextStyle.textSm(
                              weight: FontWeight.w600,
                              color: colorScheme.onSurface),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: onView,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.primary,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "View Details",
                              style: AppTextStyle.textSm(
                                  weight: FontWeight.w600,
                                  color: Colors.white),
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.arrow_forward,
                                size: 18, color: Colors.white),
                          ],
                        ),
                      ),
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

  Widget _buildMetaItem(BuildContext context, IconData icon, String text) {
    final colorScheme = context.colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: colorScheme.primary),
        const SizedBox(width: 4),
        Text(
          text,
          style: AppTextStyle.textXs(
              color: colorScheme.onSurfaceVariant, weight: FontWeight.w500),
        ),
      ],
    );
  }
}