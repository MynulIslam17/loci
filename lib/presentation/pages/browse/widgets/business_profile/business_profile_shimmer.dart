import 'package:flutter/material.dart';
import 'package:loci/presentation/widgets/app_skeleton.dart';

import '../../../../../core/theme/theme_extention.dart';

class BusinessProfileShimmer extends StatelessWidget {
  const BusinessProfileShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        children: [
          /// ================= PROFILE IMAGE =================
          Center(
            child: AppSkeleton.box(
              width: 120,
              height: 120,
              radius: 60,
            ),
          ),

          const SizedBox(height: 24),

          /// ================= INFO SECTION =================
          Card(
            color: colorScheme.surfaceContainerHigh,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  AppSkeleton.box(height: 14, width: 300),
                  const SizedBox(height: 10),
                  AppSkeleton.box(height: 12, width: 140),
                  const SizedBox(height: 10),
                  AppSkeleton.box(height: 12, width: 120),
                  const SizedBox(height: 10),
                  AppSkeleton.box(height: 12, width: 160),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          /// ================= DESCRIPTION BOX =================
          Card(
            color: colorScheme.surfaceContainerHigh,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppSkeleton.box(height: 12, width: double.infinity),
                  const SizedBox(height: 8),
                  AppSkeleton.box(height: 12, width: double.infinity),
                  const SizedBox(height: 8),
                  AppSkeleton.box(height: 12, width: 200),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          /// ================= SECTION TITLE =================
          Align(
            alignment: Alignment.centerLeft,
            child: AppSkeleton.box(height: 14, width: 100),
          ),

          const SizedBox(height: 12),

          /// ================= IMAGE GRID =================
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 4,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemBuilder: (_, __) {
              return AppSkeleton.box(
                height: 100,
                width: double.infinity,
                radius: 8,
              );
            },
          ),

          const SizedBox(height: 24),

          /// ================= REVIEW BOX =================
          Card(
            color: colorScheme.surfaceContainerHigh,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: AppSkeleton.box(height: 40, width: double.infinity),
            ),
          ),

          const SizedBox(height: 24),


        ],
      ),
    );
  }
}