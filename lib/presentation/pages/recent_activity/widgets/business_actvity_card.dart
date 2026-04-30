import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/theme_extention.dart';

import '../../../widgets/custom_image_container.dart';

Widget buildBusinessActivityCard({
  required BuildContext context,
  required String id,
  required String businessName,
  required String category,
  required String lastVisited,
  required VoidCallback onDelete,
  required bool isDeleting, // 👈 ADD THIS
  String? imageUrl,
}) {
  final colorScheme = context.colorScheme;

  return Card(
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          CustomCachedImage(
            width: 52,
            height: 52,
            imageUrl: imageUrl ?? "",
            isCircle: true,
          ),
          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(businessName),
                Text(category),
                Text("Visited $lastVisited"),
              ],
            ),
          ),

          ///  USE PASSED STATE
          isDeleting
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'delete') {
                      onDelete();
                    }
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: 'delete', child: Text("Delete")),
                  ],
                  icon: Icon(
                    Icons.more_vert,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
        ],
      ),
    ),
  );
}
