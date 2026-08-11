import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/features/browse_business/presentation/controllers/save_business_controller.dart';
import 'package:loci/shared/widgets/confirm_dialog.dart';

class BusinessSaveListButton extends StatelessWidget {
  const BusinessSaveListButton({
    super.key,
    required this.businessId,
    this.initiallySaved = false,
  });

  final String businessId;
  final bool initiallySaved;

  @override
  Widget build(BuildContext context) {
    final saveController = Get.find<SaveBusinessController>();

    return Obx(() {
      final loading = saveController.isLoading(businessId);
      final saved = saveController.isSaved(businessId, initiallySaved);

      if (loading) {
        return SizedBox(
          width: 180,
          height: 45,
          child: ElevatedButton.icon(
            onPressed: null,
            icon: const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            label: const Text('Please wait...'),
          ),
        );
      }

      if (saved) {
        return SizedBox(
          width: 180,
          height: 45,
          child: ElevatedButton.icon(
            onPressed: () => _confirmUnsave(context, saveController),
            icon: const Icon(Icons.check, size: 20),
            label: const Text('Saved'),
          ),
        );
      }

      return SizedBox(
        width: 180,
        height: 45,
        child: ElevatedButton.icon(
          onPressed: () => saveController.saveBusiness(businessId),
          icon: const Icon(Icons.add, size: 20),
          label: const Text('Add to List'),
        ),
      );
    });
  }

  Future<void> _confirmUnsave(
    BuildContext context,
    SaveBusinessController saveController,
  ) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Remove from list?',
      message: 'Do you want to remove this business from your saved list?',
      confirmText: 'Remove',
      icon: Icons.bookmark_remove_outlined,
      isDestructive: true,
    );
    if (confirmed) {
      await saveController.unsaveBusiness(businessId);
    }
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
