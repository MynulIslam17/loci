import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/enums/acitivty_ref_type.dart';
import 'package:loci/core/enums/announcement_type.dart';
import 'package:loci/core/theme/app_colors.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/presentation/controllers/community/create_announcement_controller.dart';
import 'package:loci/presentation/controllers/community/search_activity_controller.dart';
import 'package:loci/presentation/widgets/custom_appbar.dart';
import 'package:loci/presentation/widgets/custom_button.dart';
import 'package:loci/presentation/widgets/custom_dropdown.dart';
import 'package:loci/presentation/widgets/custom_text_field.dart';
import 'package:loci/presentation/widgets/pagination_loading.dart';

class CreateAnnouncementScreen extends StatefulWidget {
  const CreateAnnouncementScreen({super.key});

  @override
  State<CreateAnnouncementScreen> createState() => _CreateAnnouncementScreenState();
}

class _CreateAnnouncementScreenState extends State<CreateAnnouncementScreen> {
  // ── Form ──────────────────────────────────────────────────────────────────
  final _formKey = GlobalKey<FormState>();
  final _detailsController = TextEditingController();
  final _activitySearchController = TextEditingController();

  // ── Controllers ───────────────────────────────────────────────────────────

  final _createCtrl = Get.put(CreateAnnouncementController());
  late final SearchActivityController _searchCtrl;

  // ── State ─────────────────────────────────────────────────────────────────
  late final String _communityId;
  AnnouncementType _announcementType = AnnouncementType.notice;
  ActivityRefType _activityRefType = ActivityRefType.event;
  String? _selectedActivityId;
  bool _showSuggestions = false;
  File? _attachment;

  // ── Lifecycle ─────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _communityId = (Get.arguments as Map)['communityId'] as String;

    // SearchActivityController needs communityId + activityRefType at setup,

    _searchCtrl = Get.find<SearchActivityController>()
      ..setup(_communityId, _activityRefType);
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
    setState(() {
      _announcementType = picked;
      _attachment = null;
    });
  }

  void _onActivityTypeChanged(String? value) {
    final type = ActivityRefType.fromString(value);
    setState(() {
      _activityRefType = type;
      _selectedActivityId = null;
      _showSuggestions = false;
      _activitySearchController.clear();
    });
    _searchCtrl.changeType(type);
  }

  void _onActivitySearchChanged(String value) {
    setState(() {
      _selectedActivityId = null;
      _showSuggestions = value.trim().isNotEmpty;
    });
    _searchCtrl.onSearchChanged(value);
  }

  void _onActivitySelected(String id, String title) {
    setState(() {
      _activitySearchController.text = title;
      _selectedActivityId = id;
      _showSuggestions = false;
    });
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
    );
    if (result != null && result.files.single.path != null) {
      setState(() => _attachment = File(result.files.single.path!));
    }
  }

  Future<void> _publish() async {
    if (!_formKey.currentState!.validate()) return;

    final fields = <String, String>{
      'type': _announcementType.toJson,
      'communityId': _communityId,
    };

    switch (_announcementType) {
      case AnnouncementType.notice:
      case AnnouncementType.question:
      case AnnouncementType.offer:
        fields['details'] = _detailsController.text.trim();
      case AnnouncementType.activity:
        fields['activityRefType'] = _activityRefType.name;
        fields['activityId'] = _selectedActivityId ?? '';
        fields['description'] = _detailsController.text.trim();
    }

    final success = await _createCtrl.createAnnouncement(
      fields: fields,
      image: _announcementType == AnnouncementType.offer ? _attachment : null,
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
                    _buildTypeDropdown(colors),
                    const SizedBox(height: 20),
                    _buildFormForType(colors),
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
          style: AppTextStyle.textLg(color: colors.onSurface, weight: FontWeight.w600),
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
      value: _announcementType.label,
      items: [AnnouncementType.activity, AnnouncementType.offer, AnnouncementType.notice]
          .map((t) => DropdownMenuItem(value: t.label, child: Text(t.label)))
          .toList(),
      onChanged: _onAnnouncementTypeChanged,
    );
  }

  Widget _buildFormForType(ColorScheme colors) {
    return switch (_announcementType) {
      AnnouncementType.activity => _buildActivityForm(colors),
      AnnouncementType.offer    => _buildOfferForm(colors),
      _                         => _buildDetailsField(colors),
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
          style: AppTextStyle.textMd(color: colors.onSurface, weight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        if (_attachment != null)
          _buildFilePreview(colors)
        else
          _buildPickFileButton(colors),
      ],
    );
  }

  Widget _buildFilePreview(ColorScheme colors) {
    final isPdf = _attachment!.path.toLowerCase().endsWith('.pdf');
    final fileName = _attachment!.path.split('/').last;

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
              onPressed: () => setState(() => _attachment = null),
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
              style: AppTextStyle.textSm(weight: FontWeight.w600, color: colors.onSurface),
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
          value: _activityRefType.name,
          items: [ActivityRefType.event, ActivityRefType.route, ActivityRefType.raffle]
              .map((t) => DropdownMenuItem(value: t.name, child: Text(t.name.capitalize!)))
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
          validator: (_) => (_selectedActivityId?.isEmpty ?? true)
              ? "Please select an activity"
              : null,
          onChanged: _onActivitySearchChanged,
        ),
        if (_showSuggestions) ...[
          const SizedBox(height: 4),
          _buildActivitySuggestions(colors),
        ],
        const SizedBox(height: 20),
        _buildDetailsField(colors),
      ],
    );
  }

  Widget _buildActivitySuggestions(ColorScheme colors) {
    return GetBuilder<SearchActivityController>(
      builder: (ctrl) => Container(
        decoration: BoxDecoration(
          color: colors.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: colors.outline),
        ),
        child: ctrl.isLoading
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
                if (n is ScrollEndNotification && n.metrics.extentAfter < 50) {
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
                  separatorBuilder: (_, __) => Divider(height: 1, color: colors.outline),
                  itemBuilder: (context, index) {
                    final activity = ctrl.activities[index];
                    return ListTile(
                      dense: true,
                      title: Text(
                        activity.title,
                        style: AppTextStyle.textSm(color: colors.onSurface),
                      ),
                      onTap: () => _onActivitySelected(activity.id, activity.title),
                    );
                  },
                ),
              ),
            ),
            if (ctrl.isPaginationLoading) const PaginationLoader(size: 2),
          ],
        ),
      ),
    );
  }

  Widget _buildPublishButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: GetBuilder<CreateAnnouncementController>(
        builder: (ctrl) => SizedBox(
          width: double.infinity,
          height: 50,
          child: CustomButton(
            onPressed: ctrl.isLoading ? null : _publish,
            text: ctrl.isLoading ? "Publishing..." : "Publish",
          ),
        ),
      ),
    );
  }
}