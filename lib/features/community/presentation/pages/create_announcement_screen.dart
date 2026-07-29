import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/enums/announcement_type.dart';
import 'package:loci/core/theme/app_colors.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/core/utils/show_snackbar.dart';
import 'package:loci/features/community/presentation/controllers/create_announcement_controller.dart';
import 'package:loci/features/community/presentation/widgets/create_announcement_activity_section.dart';
import 'package:loci/shared/widgets/custom_appbar.dart';
import 'package:loci/shared/widgets/custom_button.dart';
import 'package:loci/shared/widgets/custom_dropdown.dart';
import 'package:loci/shared/widgets/custom_text_field.dart';
import 'package:loci/shared/widgets/file_picker.dart';

/// Create community announcement (notice, offer, or activity).
///
/// Flow: UI → [CreateAnnouncementController] → [CommunityService] → repository → API.
class CreateAnnouncementScreen extends StatefulWidget {
  const CreateAnnouncementScreen({super.key});

  @override
  State<CreateAnnouncementScreen> createState() =>
      _CreateAnnouncementScreenState();
}

class _CreateAnnouncementScreenState extends State<CreateAnnouncementScreen> {
  final _formKey = GlobalKey<FormState>();
  final _detailsController = TextEditingController();
  final _activitySearchController = TextEditingController();

  final _createCtrl = Get.find<CreateAnnouncementController>();

  @override
  void initState() {
    super.initState();
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    final communityId = args['communityId']?.toString() ?? '';
    _createCtrl.bind(
      communityId: communityId,
      postAsBusiness: args['postAsBusiness'] == true,
    );
    _detailsController.clear();
    _activitySearchController.clear();
  }

  @override
  void dispose() {
    _detailsController.dispose();
    _activitySearchController.dispose();
    super.dispose();
  }

  Future<void> _pickAttachment() async {
    final file = await AppFilePicker.pickSingle(
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
    );
    if (file != null) {
      _createCtrl.setAttachment(file);
    }
  }

  Future<void> _publish() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await _createCtrl.publish(_detailsController.text);
    if (!mounted) return;

    if (success) {
      _closeScreen();
      SnackbarService.success('Announcement published');
    } else {
      SnackbarService.error(
        _createCtrl.errorMessage.value ?? 'Could not publish announcement',
      );
    }
  }

  void _onActivitySelected(String id, String title) {
    _activitySearchController.text = title;
    _createCtrl.selectActivity(id: id);
  }

  void _closeScreen() {
    if (Get.key.currentState?.canPop() ?? false) {
      Get.back(result: true);
      return;
    }
    if (mounted) {
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: const CustomAppbar(title: 'Create announcement'),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Announcement details',
                      style: AppTextStyle.textLg(
                        color: colors.onSurface,
                        weight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Choose a type and fill in the fields below to post to your community.',
                      style: AppTextStyle.textSm(color: colors.onSurfaceVariant),
                    ),
                    const SizedBox(height: 20),
                    _TypeDropdown(
                      controller: _createCtrl,
                      onLeftActivityType: _activitySearchController.clear,
                    ),
                    const SizedBox(height: 20),
                    _FormBody(
                      controller: _createCtrl,
                      detailsController: _detailsController,
                      activitySearchController: _activitySearchController,
                      onPickAttachment: _pickAttachment,
                      onActivitySelected: _onActivitySelected,
                    ),
                  ],
                ),
              ),
            ),
          ),
          _PublishBar(onPublish: _publish, controller: _createCtrl),
        ],
      ),
    );
  }
}

class _TypeDropdown extends StatelessWidget {
  const _TypeDropdown({
    required this.controller,
    required this.onLeftActivityType,
  });

  final CreateAnnouncementController controller;
  final VoidCallback onLeftActivityType;

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;

    return Obx(
      () => CustomDropdown(
        title: 'Announcement type',
        dropdownColor: colors.surfaceContainerHigh,
        borderColor: colors.outline,
        hintText: 'Select type',
        textFontSize: 14,
        hintFontSize: 14,
        hintColor: colors.onSurfaceVariant,
        textColor: colors.onSurface,
        value: controller.announcementType.value.label,
        items: CreateAnnouncementController.creatableTypes
            .map(
              (t) => DropdownMenuItem(value: t.label, child: Text(t.label)),
            )
            .toList(),
        onChanged: (label) {
          if (label == null) return;
          final type = AnnouncementType.values.firstWhere(
            (t) => t.label == label,
            orElse: () => AnnouncementType.notice,
          );
          final wasActivity =
              controller.announcementType.value == AnnouncementType.activity;
          controller.setAnnouncementType(type);
          if (wasActivity && type != AnnouncementType.activity) {
            controller.clearActivitySelection();
            onLeftActivityType();
          }
        },
      ),
    );
  }
}

class _FormBody extends StatelessWidget {
  const _FormBody({
    required this.controller,
    required this.detailsController,
    required this.activitySearchController,
    required this.onPickAttachment,
    required this.onActivitySelected,
  });

  final CreateAnnouncementController controller;
  final TextEditingController detailsController;
  final TextEditingController activitySearchController;
  final VoidCallback onPickAttachment;
  final void Function(String id, String title) onActivitySelected;

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;

    return Obx(() {
      final type = controller.announcementType.value;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (type == AnnouncementType.activity) ...[
            CreateAnnouncementActivitySection(
              controller: controller,
              searchController: activitySearchController,
              onActivityTitleSelected: onActivitySelected,
            ),
            const SizedBox(height: 20),
          ],
          CustomTextField(
            controller: detailsController,
            title: 'Details',
            hintText: 'Enter details...',
            maxLine: 4,
            maxLength: 2000,
            borderColor: colors.outline,
            textColor: colors.onSurface,
            validator: (v) => v != null && v.trim().isNotEmpty
                ? null
                : 'Please enter details',
          ),
          if (type == AnnouncementType.offer) ...[
            const SizedBox(height: 20),
            _OfferAttachmentField(
              file: controller.attachment.value,
              onPick: onPickAttachment,
              onRemove: controller.clearAttachment,
            ),
          ],
          if (type == AnnouncementType.activity) ...[
            const SizedBox(height: 8),
            Text(
              'Add an optional description for this activity post.',
              style: AppTextStyle.textXs(color: colors.onSurfaceVariant),
            ),
          ],
        ],
      );
    });
  }
}

class _OfferAttachmentField extends StatelessWidget {
  const _OfferAttachmentField({
    required this.file,
    required this.onPick,
    required this.onRemove,
  });

  final File? file;
  final VoidCallback onPick;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Attachment',
          style: AppTextStyle.textMd(
            color: colors.onSurface,
            weight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        if (file != null)
          Card(
            color: colors.surfaceContainerHigh,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Icon(
                    file!.path.toLowerCase().endsWith('.pdf')
                        ? Icons.picture_as_pdf
                        : Icons.image_outlined,
                    color: file!.path.toLowerCase().endsWith('.pdf')
                        ? Colors.red
                        : colors.onSurfaceVariant,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      file!.path.split(Platform.pathSeparator).last,
                      style: AppTextStyle.textSm(weight: FontWeight.w500),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    onPressed: onRemove,
                    icon: const Icon(
                      Icons.delete_outline,
                      color: AppColors.danger,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          InkWell(
            onTap: onPick,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: colors.surfaceContainerHighest.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: colors.outline),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.attach_file, size: 20, color: colors.onSurface),
                  const SizedBox(width: 8),
                  Text(
                    'Add attachment (image or PDF)',
                    style: AppTextStyle.textSm(
                      weight: FontWeight.w600,
                      color: colors.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _PublishBar extends StatelessWidget {
  const _PublishBar({
    required this.onPublish,
    required this.controller,
  });

  final VoidCallback onPublish;
  final CreateAnnouncementController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: Obx(
        () => SizedBox(
          width: double.infinity,
          height: 50,
          child: CustomButton(
            onPressed: controller.isLoading.value ? null : onPublish,
            text: controller.isLoading.value ? 'Publishing...' : 'Publish',
          ),
        ),
      ),
    );
  }
}
