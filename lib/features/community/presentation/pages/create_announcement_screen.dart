import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/enums/acitivty_ref_type.dart';
import 'package:loci/core/enums/announcement_type.dart';
import 'package:loci/core/theme/app_colors.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/features/community/domain/services/community_service.dart';
import 'package:loci/features/community/presentation/controllers/create_announcement_controller.dart';
import 'package:loci/features/community/presentation/controllers/my_community_controller.dart';
import 'package:loci/features/community/presentation/controllers/search_activity_controller.dart';
import 'package:loci/shared/widgets/custom_appbar.dart';
import 'package:loci/shared/widgets/custom_button.dart';
import 'package:loci/shared/widgets/custom_dropdown.dart';
import 'package:loci/shared/widgets/custom_text_field.dart';
import 'package:loci/shared/widgets/pagination_loading.dart';

class CreateAnnouncementScreen extends StatefulWidget {
  const CreateAnnouncementScreen({super.key});

  @override
  State<CreateAnnouncementScreen> createState() =>
      _CreateAnnouncementScreenState();
}

class _CreateAnnouncementScreenState extends State<CreateAnnouncementScreen> {
  // ── Form ──────────────────────────────────────────────────────────────────
  final _formKey = GlobalKey<FormState>();
  final _detailsController = TextEditingController();
  final _activitySearchController = TextEditingController();

  // ── Controllers ───────────────────────────────────────────────────────────

  final _createCtrl = Get.isRegistered<CreateAnnouncementController>()
      ? Get.find<CreateAnnouncementController>()
      : Get.put(CreateAnnouncementController(Get.find<CommunityService>()));
  late final SearchActivityController _searchCtrl;

  // ── State ─────────────────────────────────────────────────────────────────
  late final String _communityId;
  late final bool _postAsBusiness;
  final _announcementType = AnnouncementType.notice.obs;
  final _activityRefType = ActivityRefType.event.obs;
  final _selectedActivityId = RxnString();
  final _showSuggestions = false.obs;
  final _attachment = Rxn<File>();

  // ── Lifecycle ─────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    final args = Get.arguments as Map;
    _communityId = args['communityId'] as String;
    _postAsBusiness = args['postAsBusiness'] == true;

    // SearchActivityController needs communityId + activityRefType at setup,

    _searchCtrl = Get.find<SearchActivityController>()
      ..setup(_communityId, _activityRefType.value);
  }

  @override
  void dispose() {
    _detailsController.dispose();
    _activitySearchController.dispose();
    Get.delete<SearchActivityController>();
    super.dispose();
  }

  // ── Actions ───────────────────────────────────────────────────────────────
  void _onAnnouncementTypeChanged(String? label) {
    final picked = AnnouncementType.values.firstWhere(
      (t) => t.label == label,
      orElse: () => AnnouncementType.notice,
    );
    _announcementType.value = picked;
    _attachment.value = null;
  }

  void _onActivityTypeChanged(String? value) {
    final type = ActivityRefType.fromString(value);
    _activityRefType.value = type;
    _selectedActivityId.value = null;
    _showSuggestions.value = false;
    _activitySearchController.clear();
    _searchCtrl.changeType(type);
  }

  void _onActivitySearchChanged(String value) {
    _selectedActivityId.value = null;
    _showSuggestions.value = value.trim().isNotEmpty;
    _searchCtrl.onSearchChanged(value);
  }

  void _onActivitySelected(String id, String title) {
    _activitySearchController.text = title;
    _selectedActivityId.value = id;
    _showSuggestions.value = false;
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
    );
    if (result != null && result.files.single.path != null) {
      _attachment.value = File(result.files.single.path!);
    }
  }

  Future<void> _publish() async {
    if (!_formKey.currentState!.validate()) return;

    final fields = <String, String>{
      'type': _announcementType.value.toJson,
      'communityId': _communityId,
    };

    switch (_announcementType.value) {
      case AnnouncementType.notice:
      case AnnouncementType.question:
      case AnnouncementType.offer:
        fields['details'] = _detailsController.text.trim();
      case AnnouncementType.activity:
        fields['activityRefType'] = _activityRefType.value.name;
        fields['activityId'] = _selectedActivityId.value ?? '';
        fields['description'] = _detailsController.text.trim();
    }

    if (_postAsBusiness && Get.isRegistered<MyCommunityController>()) {
      final businessId =
          Get.find<MyCommunityController>().community.value?.business.id;
      if (businessId != null && businessId.isNotEmpty) {
        fields['businessId'] = businessId;
      }
    }

    final success = await _createCtrl.createAnnouncement(
      fields: fields,
      image: _announcementType.value == AnnouncementType.offer
          ? _attachment.value
          : null,
    );

    if (success && mounted) Get.back();
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: const CustomAppbar(title: "Create Announcement"),
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
                    _buildHeader(colors),
                    const SizedBox(height: 20),
                    Obx(() => _buildTypeDropdown(colors)),
                    const SizedBox(height: 20),
                    Obx(() => _buildFormForType(colors)),
                  ],
                ),
              ),
            ),
          ),
          _buildPublishButton(),
        ],
      ),
    );
  }

  // ── UI Builders ───────────────────────────────────────────────────────────

  Widget _buildHeader(ColorScheme colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Announcement Detail",
          style: AppTextStyle.textLg(
            color: colors.onSurface,
            weight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Please provide the necessary details to create an announcement for the community.",
          style: AppTextStyle.textSm(color: colors.onSurfaceVariant),
        ),
      ],
    );
  }

  Widget _buildTypeDropdown(ColorScheme colors) {
    return CustomDropdown(
      title: "Announcement type",
      dropdownColor: colors.surfaceContainerHigh,
      borderColor: colors.outline,
      hintText: "Select type",
      textFontSize: 14,
      hintFontSize: 14,
      hintColor: colors.onSurfaceVariant,
      textColor: colors.onSurface,
      value: _announcementType.value.label,
      items:
          [
                AnnouncementType.activity,
                AnnouncementType.offer,
                AnnouncementType.notice,
              ]
              .map(
                (t) => DropdownMenuItem(value: t.label, child: Text(t.label)),
              )
              .toList(),
      onChanged: _onAnnouncementTypeChanged,
    );
  }

  Widget _buildFormForType(ColorScheme colors) {
    return switch (_announcementType.value) {
      AnnouncementType.activity => _buildActivityForm(colors),
      AnnouncementType.offer => _buildOfferForm(colors),
      _ => _buildDetailsField(colors),
    };
  }

  Widget _buildDetailsField(ColorScheme colors) {
    return Column(
      children: [
        CustomTextField(
          controller: _detailsController,
          title: "Details",
          hintText: "Enter details...",
          maxLine: 4,
          borderColor: colors.outline,
          textColor: colors.onSurface,
          validator: (v) => v!.isNotEmpty ? null : "Please enter details",
        ),
        const SizedBox(height: 4),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            "Limit: 2000 char",
            style: AppTextStyle.textXs(color: colors.onSurfaceVariant),
          ),
        ),
      ],
    );
  }

  Widget _buildOfferForm(ColorScheme colors) {
    return Column(
      children: [
        _buildDetailsField(colors),
        const SizedBox(height: 20),
        _buildAttachmentPicker(colors),
      ],
    );
  }

  Widget _buildAttachmentPicker(ColorScheme colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Attachment",
          style: AppTextStyle.textMd(
            color: colors.onSurface,
            weight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Obx(
          () => _attachment.value != null
              ? _buildFilePreview(colors)
              : _buildPickFileButton(colors),
        ),
      ],
    );
  }

  Widget _buildFilePreview(ColorScheme colors) {
    final file = _attachment.value!;
    final isPdf = file.path.toLowerCase().endsWith('.pdf');
    final fileName = file.path.split('/').last;

    return Card(
      color: colors.surfaceContainerHigh,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(
              isPdf ? Icons.picture_as_pdf : Icons.image_outlined,
              color: isPdf ? Colors.red : colors.onSurfaceVariant,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fileName,
                    style: AppTextStyle.textSm(weight: FontWeight.w500),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    isPdf ? "PDF Document" : "Image",
                    style: AppTextStyle.textXs(color: colors.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () => _attachment.value = null,
              icon: const Icon(Icons.delete_outline, color: AppColors.danger),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPickFileButton(ColorScheme colors) {
    return InkWell(
      onTap: _pickFile,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: colors.onPrimaryContainer,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: colors.outline),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.attach_file, size: 20, color: colors.onSurface),
            const SizedBox(width: 8),
            Text(
              "Add Attachment",
              style: AppTextStyle.textSm(
                weight: FontWeight.w600,
                color: colors.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityForm(ColorScheme colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomDropdown(
          title: "Activity Type",
          dropdownColor: colors.surfaceContainerHigh,
          borderColor: colors.outline,
          hintText: "Select activity type",
          textFontSize: 14,
          hintFontSize: 14,
          hintColor: colors.onSurfaceVariant,
          textColor: colors.onSurface,
          value: _activityRefType.value.name,
          items:
              [
                    ActivityRefType.event,
                    ActivityRefType.route,
                    ActivityRefType.raffle,
                  ]
                  .map(
                    (t) => DropdownMenuItem(
                      value: t.name,
                      child: Text(t.name.capitalize!),
                    ),
                  )
                  .toList(),
          onChanged: _onActivityTypeChanged,
        ),
        const SizedBox(height: 20),
        CustomTextField(
          controller: _activitySearchController,
          title: "Activity",
          hintText: "Search activity...",
          borderColor: colors.outline,
          fontSize: 14,
          textColor: colors.onSurface,
          hintTextColor: colors.onSurfaceVariant,
          showClearButton: true,
          validator: (_) => (_selectedActivityId.value?.isEmpty ?? true)
              ? "Please select an activity"
              : null,
          onChanged: _onActivitySearchChanged,
          suffixIcon: Icon(
            Icons.search,
            color: colors.onSurfaceVariant,
          ),
        ),
        Obx(
          () => _showSuggestions.value
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    _buildActivitySuggestions(colors),
                  ],
                )
              : const SizedBox.shrink(),
        ),
        const SizedBox(height: 20),
        _buildDetailsField(colors),
      ],
    );
  }

  Widget _buildActivitySuggestions(ColorScheme colors) {
    return Obx(() {
      final ctrl = Get.find<SearchActivityController>();
      return Container(
        decoration: BoxDecoration(
          color: colors.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: colors.outline),
        ),
        child: ctrl.isLoading.value
            ? const Padding(
                padding: EdgeInsets.all(12),
                child: Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              )
            : ctrl.activities.isEmpty
            ? Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  "No activities found",
                  style: AppTextStyle.textSm(color: colors.onSurfaceVariant),
                ),
              )
            : Column(
                children: [
                  NotificationListener<ScrollNotification>(
                    onNotification: (n) {
                      if (n is ScrollEndNotification &&
                          n.metrics.extentAfter < 50) {
                        ctrl.fetchMore();
                      }
                      return false;
                    },
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 200),
                      child: ListView.separated(
                        shrinkWrap: true,
                        physics: const ClampingScrollPhysics(),
                        itemCount: ctrl.activities.length,
                        separatorBuilder: (_, __) =>
                            Divider(height: 1, color: colors.outline),
                        itemBuilder: (context, index) {
                          final activity = ctrl.activities[index];
                          return ListTile(
                            dense: true,
                            title: Text(
                              activity.title,
                              style: AppTextStyle.textSm(
                                color: colors.onSurface,
                              ),
                            ),
                            onTap: () => _onActivitySelected(
                              activity.id,
                              activity.title,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  if (ctrl.isPaginationLoading.value)
                    const PaginationLoader(size: 2),
                ],
              ),
      );
    });
  }

  Widget _buildPublishButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: Obx(() {
        final ctrl = Get.find<CreateAnnouncementController>();
        return SizedBox(
          width: double.infinity,
          height: 50,
          child: CustomButton(
            onPressed: ctrl.isLoading.value ? null : _publish,
            text: ctrl.isLoading.value ? "Publishing..." : "Publish",
          ),
        );
      }),
    );
  }
}
