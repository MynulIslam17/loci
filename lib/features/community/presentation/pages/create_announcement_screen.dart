import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/enums/announcement_type.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/core/utils/show_snackbar.dart';
import 'package:loci/features/community/data/models/activity_model.dart';
import 'package:loci/features/community/presentation/controllers/create_announcement_controller.dart';
import 'package:loci/features/community/presentation/widgets/create_announcement_activity_section.dart';
import 'package:loci/shared/widgets/attachment_picker_field.dart';
import 'package:loci/shared/widgets/custom_appbar.dart';
import 'package:loci/shared/widgets/custom_button.dart';
import 'package:loci/shared/widgets/custom_dropdown.dart';
import 'package:loci/shared/widgets/custom_text_field.dart';
import 'package:loci/shared/widgets/file_picker.dart';

/// Screen for creating a community announcement (notice, offer, or activity).
///
/// Layering — the UI only talks to the controller; it never reaches into the
/// service, repository, or network directly:
///
///   UI (this screen)
///     → CreateAnnouncementController  (form state + validation)
///       → CommunityService           (use-case orchestration)
///         → CommunityRepository      (request building)
///           → NetworkCaller          (HTTP)
class CreateAnnouncementScreen extends StatefulWidget {
  const CreateAnnouncementScreen({super.key});

  @override
  State<CreateAnnouncementScreen> createState() =>
      _CreateAnnouncementScreenState();
}

class _CreateAnnouncementScreenState extends State<CreateAnnouncementScreen> {
  final _controller = Get.find<CreateAnnouncementController>();

  // Form state owned by the screen.
  final _formKey = GlobalKey<FormState>();
  final _detailsController = TextEditingController();
  final _activitySearchController = TextEditingController();

  // Scrolls the activity search field above the keyboard when the results
  // dropdown (rendered below the field) opens.
  final _activityFieldKey = GlobalKey();
  final _scrollController = ScrollController();
  Worker? _suggestionsWorker;

  @override
  void initState() {
    super.initState();
    _initControllerFromArguments();
    _watchActivitySuggestions();
  }

  @override
  void dispose() {
    _suggestionsWorker?.dispose();
    _scrollController.dispose();
    _detailsController.dispose();
    _activitySearchController.dispose();
    super.dispose();
  }

  /// Binds the controller to the community passed in via route arguments.
  void _initControllerFromArguments() {
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    _controller.bind(
      communityId: args['communityId']?.toString() ?? '',
      postAsBusiness: args['postAsBusiness'] == true,
    );
    _detailsController.clear();
    _activitySearchController.clear();
  }

  /// Lifts the search field into view when suggestions open so the results are
  /// not hidden behind the keyboard.
  void _watchActivitySuggestions() {
    _suggestionsWorker = ever<bool>(_controller.showActivitySuggestions, (
      isOpen,
    ) {
      if (isOpen) _scrollActivityFieldIntoView();
    });
  }

  void _scrollActivityFieldIntoView() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final fieldContext = _activityFieldKey.currentContext;
      if (fieldContext == null) return;
      Scrollable.ensureVisible(
        fieldContext,
        alignment: 0.05,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  // Offers accept images only — the backend rejects other file types.
  static const _offerImageExtensions = ['jpg', 'jpeg', 'png', 'webp'];

  Future<void> _pickOfferAttachment() async {
    // 1. Restrict the picker to image types.
    final file = await AppFilePicker.pickSingle(
      allowedExtensions: _offerImageExtensions,
    );
    if (file == null) return;

    // 2. Validate the selection (some pickers still allow browsing to a PDF).
    final extension = file.path.split('.').last.toLowerCase();
    if (!_offerImageExtensions.contains(extension)) {
      SnackbarService.error('Please choose an image (JPG, PNG or WEBP)');
      return;
    }

    _controller.setAttachment(file);
  }

  void _onActivitySelected(ActivityModel activity) {
    _controller.selectActivity(activity);
  }

  Future<void> _publishAnnouncement() async {
    if (!_formKey.currentState!.validate()) return;

    final published = await _controller.publishAnnouncement(
      _detailsController.text,
    );
    if (!mounted) return;

    if (published) {
      _closeAfterPublish();
      SnackbarService.success('Announcement published');
    } else {
      SnackbarService.error(
        _controller.errorMessage.value ?? 'Could not publish announcement',
      );
    }
  }

  void _closeAfterPublish() {
    if (Get.key.currentState?.canPop() ?? false) {
      Get.back(result: true);
    } else if (mounted) {
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colorScheme.surface,
      appBar: const CustomAppbar(title: 'Create announcement'),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _FormHeader(),
                    const SizedBox(height: 20),
                    _AnnouncementTypeSelector(
                      controller: _controller,
                      onLeaveActivityType: _activitySearchController.clear,
                    ),
                    const SizedBox(height: 20),
                    _AnnouncementFields(
                      controller: _controller,
                      detailsController: _detailsController,
                      activitySearchController: _activitySearchController,
                      activityFieldKey: _activityFieldKey,
                      onPickAttachment: _pickOfferAttachment,
                      onActivitySelected: _onActivitySelected,
                    ),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
              child: Obx(
                () => CustomButton(
                  height: 52,
                  text: 'Publish',
                  isLoading: _controller.isLoading.value,
                  onPressed: _publishAnnouncement,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Title + helper line at the top of the form.
class _FormHeader extends StatelessWidget {
  const _FormHeader();

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;
    return Column(
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
      ],
    );
  }
}

/// Dropdown that picks the announcement type (notice / offer / activity).
class _AnnouncementTypeSelector extends StatelessWidget {
  const _AnnouncementTypeSelector({
    required this.controller,
    required this.onLeaveActivityType,
  });

  final CreateAnnouncementController controller;

  /// Called when switching away from the activity type, so the screen can clear
  /// the activity search field.
  final VoidCallback onLeaveActivityType;

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
            .map((t) => DropdownMenuItem(value: t.label, child: Text(t.label)))
            .toList(),
        onChanged: (label) => _onTypeChanged(label),
      ),
    );
  }

  void _onTypeChanged(String? label) {
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
      onLeaveActivityType();
    }
  }
}

/// The type-specific fields: activity picker, details, and offer attachment.
class _AnnouncementFields extends StatelessWidget {
  const _AnnouncementFields({
    required this.controller,
    required this.detailsController,
    required this.activitySearchController,
    required this.activityFieldKey,
    required this.onPickAttachment,
    required this.onActivitySelected,
  });

  final CreateAnnouncementController controller;
  final TextEditingController detailsController;
  final TextEditingController activitySearchController;
  final GlobalKey activityFieldKey;
  final VoidCallback onPickAttachment;
  final void Function(ActivityModel activity) onActivitySelected;

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;

    return Obx(() {
      final type = controller.announcementType.value;
      final isActivity = type == AnnouncementType.activity;
      final isOffer = type == AnnouncementType.offer;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isActivity) ...[
            CreateAnnouncementActivitySection(
              controller: controller,
              searchController: activitySearchController,
              searchFieldKey: activityFieldKey,
              onActivitySelected: onActivitySelected,
            ),
            const SizedBox(height: 20),
          ],
          CustomTextField(
            controller: detailsController,
            title: isActivity ? 'Description' : 'Details',
            hintText: 'Enter details...',
            maxLine: 4,
            maxLength: 2000,
            borderColor: colors.outline,
            textColor: colors.onSurface,
            validator: (v) => (v != null && v.trim().isNotEmpty)
                ? null
                : 'Please enter details',
          ),
          if (isOffer) ...[
            const SizedBox(height: 20),
            AttachmentPickerField(
              selectedFile: controller.attachment.value,
              onPickFile: onPickAttachment,
              onRemoveFile: controller.clearAttachment,
              title: 'Image',
              emptyLabel: 'Add image (JPG or PNG)',
            ),
          ],
        ],
      );
    });
  }
}
