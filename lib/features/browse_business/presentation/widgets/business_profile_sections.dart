import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/features/browse_business/presentation/controllers/save_business_controller.dart';

class BusinessSaveListButton extends StatelessWidget {
  const BusinessSaveListButton({super.key, required this.businessId});

  final String businessId;

  @override
  Widget build(BuildContext context) {
    final saveController = Get.find<SaveBusinessController>();

    return Obx(() {
      final loading = saveController.isLoading(businessId);

      return SizedBox(
        width: 180,
        height: 45,
        child: ElevatedButton.icon(
          onPressed: loading ? null : () => saveController.saveBusiness(businessId),
          icon: loading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.add, size: 20),
          label: Text(loading ? 'Saving...' : 'Add to List'),
        ),
      );
    });
  }
}

class BusinessDescriptionCard extends StatelessWidget {
  const BusinessDescriptionCard({super.key, required this.description});

  final String description;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: context.colorScheme.surfaceContainerHigh,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Text(
          description,
          style: AppTextStyle.textXs(
            color: context.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

class BusinessSectionTitle extends StatelessWidget {
  const BusinessSectionTitle({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: Text(
        title,
        style: AppTextStyle.textXl(
          weight: FontWeight.w700,
          color: context.colorScheme.primary,
        ),
      ),
    );
  }
}
