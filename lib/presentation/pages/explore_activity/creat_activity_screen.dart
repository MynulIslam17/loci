import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/presentation/widgets/custom_appbar.dart';
import 'package:loci/presentation/widgets/custom_dropdown.dart';
import 'package:loci/presentation/widgets/custom_image_container.dart';
import 'package:loci/presentation/widgets/custom_imagepicker.dart';
import 'package:loci/presentation/widgets/custom_rich_text.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/date_parser.dart';
import '../../../data/task_model.dart';
import '../../../gen/assets.gen.dart';
import '../../widgets/common/company_info_card.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

enum ActivityType { Event, Routes, Raffles }

class CreateActivityScreen extends StatefulWidget {
  const CreateActivityScreen({super.key});

  @override
  State<CreateActivityScreen> createState() => _CreateActivityScreenState();
}

class _CreateActivityScreenState extends State<CreateActivityScreen> {
  final TextEditingController dateTEController = TextEditingController();
  final TextEditingController timeTEController = TextEditingController();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController detailsController = TextEditingController();
  final TextEditingController personController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController urlController = TextEditingController();
  final TextEditingController maxSupplyController = TextEditingController();

  File? bannerImage;
  File? coupon;

  List<TaskModel> tasks = [];

  List<String> createCategory = ActivityType.values.map((e) => e.name).toList();
  List<String> routeCondition = ["Easy", "Medium", "Hard"];

  String? selectedCategory = ActivityType.Event.name;
  String? selectedRouteCondition;
  bool isPublic = false;

  @override
  void dispose() {
    dateTEController.dispose();
    timeTEController.dispose();
    titleController.dispose();
    detailsController.dispose();
    personController.dispose();
    locationController.dispose();
    urlController.dispose();
    maxSupplyController.dispose();
    super.dispose();
  }

  void showCalendar() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      firstDate: DateTime(1940),
      initialDate: DateTime.now(),
      lastDate: DateTime(2049),
    );

    if (pickedDate != null) {
      setState(() {
        dateTEController.text = DateParserHelper.toFriendlyDate(pickedDate);
      });
    }
  }

  void showTime() async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null) {
      setState(() {
        timeTEController.text = pickedTime.format(context);
      });
    }
  }

  Future<void> _pickCoupon() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
    );

    if (result == null) return;

    final path = result.files.single.path;
    if (path == null) return;

    setState(() {
      coupon = File(path);
    });
  }

  void _addTask() {
    setState(() {
      tasks.add(TaskModel(
        title: "Task1",
        description: "afafafaf",
        logoUrl: 'assets/images/finedine.png',
      ));
    });
  }

  void _removeTask(int index) {
    setState(() {
      tasks.removeAt(index);
    });
  }

  void _clearCategoryData() {
    dateTEController.clear();
    timeTEController.clear();
    titleController.clear();
    detailsController.clear();
    personController.clear();
    locationController.clear();
    urlController.clear();
    maxSupplyController.clear();
    bannerImage = null;
    coupon = null;
    tasks.clear();
    selectedRouteCondition = null;
    isPublic = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colorScheme.surface,
      appBar: const CustomAppbar(title: "Create Activity"),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              _bannerImagePicker(),
              const SizedBox(height: 16),
              _topFields(),
              _middleField(),
              _bottomFields(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _bannerImagePicker() {
    return CustomImagePicker(
      backgroundColor: context.colorScheme.surfaceContainerHigh,
      selectedImage: bannerImage,
      height: 200,
      onImageSelected: (file) => setState(() => bannerImage = file),
      placeholder: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.add_a_photo, color: context.colorScheme.onSurfaceVariant, size: 50),
          const SizedBox(height: 12),
          Text(
            "Browse image",
            style: AppTextStyle.textMd(
              color: context.colorScheme.onSurface,
              weight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _topFields() {
    final colorScheme = context.colorScheme;
    return Column(
      children: [
        CustomDropdown(
          title: "Activity type",
          dropdownColor: colorScheme.surfaceContainerHigh,
          value: selectedCategory,
          borderColor: colorScheme.outline,
          hintText: "Select Category",
          hintColor: colorScheme.onSurfaceVariant,
          textColor: colorScheme.onSurface,
          onChanged: (value) {
            if (value != selectedCategory) {
              _clearCategoryData();
            }
            setState(() => selectedCategory = value);
          },
          items: createCategory.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: titleController,
          title: "Title",
          hintText: "Enter title",
          borderColor: colorScheme.outline,
          textColor: colorScheme.onSurface,
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: detailsController,
          title: "Details",
          hintText: "Enter details",
          maxLine: 5,
          borderColor: colorScheme.outline,
          textColor: colorScheme.onSurface,
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _middleField() {
    switch (selectedCategory) {
      case "Event":
        return _eventFields();
      case "Routes":
        return _routeFields();
      case "Raffles":
        return _raffleFields();
      default:
        return const SizedBox();
    }
  }

  Widget _eventFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Event Schedule and Seats", style: AppTextStyle.textSm(weight: FontWeight.w700)),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                controller: dateTEController,
                readOnly: true,
                onTap: showCalendar,
                hintText: "Select date",
                suffixIcon: Icon(Icons.calendar_today_outlined, size: 18, color: context.colorScheme.onSurfaceVariant),
                borderColor: context.colorScheme.outline,
                textColor: context.colorScheme.onSurface,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CustomTextField(
                controller: timeTEController,
                readOnly: true,
                onTap: showTime,
                hintText: "Select time",
                suffixIcon: Icon(Icons.access_time, size: 18, color: context.colorScheme.onSurfaceVariant),
                borderColor: context.colorScheme.outline,
                textColor: context.colorScheme.onSurface,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CustomTextField(
                controller: personController,
                hintText: "Person",
                keyboardType: TextInputType.number,
                suffixIcon: Icon(Icons.person_outline, size: 18, color: context.colorScheme.onSurfaceVariant),
                borderColor: context.colorScheme.outline,
                textColor: context.colorScheme.onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        CustomTextField(
          controller: locationController,
          title: "Location",
          hintText: "Enter location",
          prefixIcon: const Icon(Icons.location_on),
          borderColor: context.colorScheme.outline,
          textColor: context.colorScheme.onSurface,
        ),
        const SizedBox(height: 12),
        Card(
          color: context.colorScheme.surfaceContainerHigh,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                ClipRRect(child: Image.asset(Assets.images.location.path)),
                const SizedBox(height: 12),
                CustomTextField(
                  controller: urlController,
                  title: "URL",
                  hintText: "http://",
                  borderColor: context.colorScheme.outline,
                  textColor: context.colorScheme.onSurface,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _routeFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Route Details", style: AppTextStyle.textSm(weight: FontWeight.w700)),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                controller: timeTEController,
                readOnly: true,
                onTap: showTime,
                hintText: "Select time",
                suffixIcon: Icon(Icons.access_time, size: 18, color: context.colorScheme.onSurfaceVariant),
                borderColor: context.colorScheme.outline,
                textColor: context.colorScheme.onSurface,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CustomDropdown(
                dropdownColor: context.colorScheme.surfaceContainerHigh,
                borderColor: context.colorScheme.outline,
                hintColor: context.colorScheme.onSurfaceVariant,
                textColor: context.colorScheme.onSurface,
                hintText: "Route type",
                value: selectedRouteCondition,
                items: routeCondition.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
                onChanged: (value) => setState(() => selectedRouteCondition = value),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _raffleFields() {
    final colorScheme = context.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                controller: dateTEController,
                title: "Due date",
                readOnly: true,
                onTap: showCalendar,
                hintText: "Select date",
                suffixIcon: Icon(Icons.calendar_today_outlined, size: 18, color: context.colorScheme.onSurfaceVariant),
                borderColor: context.colorScheme.outline,
                textColor: context.colorScheme.onSurface,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CustomTextField(
                controller: maxSupplyController,
                textInputAction: TextInputAction.next,
                title: "Max Supply",
                hintText: "Enter supply",
                keyboardType: TextInputType.number,
                suffixIcon: Icon(Icons.person_outline, size: 18, color: context.colorScheme.onSurfaceVariant),
                borderColor: context.colorScheme.outline,
                textColor: context.colorScheme.onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text("Price (Coupon)", style: AppTextStyle.textSm(weight: FontWeight.w700, color: colorScheme.onSurface)),
        const SizedBox(height: 12),
        _buildCoupon(file: coupon, onTap: _pickCoupon),
        const SizedBox(height: 16),
        Card(
          elevation: 2,
          margin: EdgeInsets.zero,
          color: colorScheme.surfaceContainer,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'Tasks required ',
                        style: AppTextStyle.textSm(weight: FontWeight.w700, color: colorScheme.onSurface),
                      ),
                      TextSpan(
                        text: '(Check-in):',
                        style: AppTextStyle.textXs(weight: FontWeight.w400, color: colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                if (tasks.isNotEmpty)
                  ListView.builder(
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: tasks.length,
                    itemBuilder: (context, index) => _buildTaskCard(tasks[index], index),
                  ),
                const SizedBox(height: 12),
                CustomButton(
                  backgroundColor: colorScheme.surface,
                  side: BorderSide(color: colorScheme.primary),
                  onPressed: _showBottomSheet,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add, color: colorScheme.primary, size: 22),
                      const SizedBox(width: 8),
                      Text("Add requirement", style: AppTextStyle.textMd(color: colorScheme.primary, weight: FontWeight.w500)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _bottomFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _organizerToggle(),
        const SizedBox(height: 10),
        CompanyInfoCard(
          title: "Marland Clutch",
          description: "Lorem Ipsum is simply dummy text of the printing and typesetting industry...",
          imagePath: Assets.images.companyLogo.path,
        ),
        const SizedBox(height: 10),
        CustomButton(
          text: "Publish",
          backgroundColor: context.colorScheme.primary,
          textColor: context.colorScheme.onPrimary,
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _organizerToggle() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text("Organizer", style: AppTextStyle.textMd(weight: FontWeight.w700, color: context.colorScheme.onSurface)),
          const Spacer(),
          Text(isPublic ? "Public" : "Private", style: AppTextStyle.textSm(weight: FontWeight.w700, color: context.colorScheme.onSurfaceVariant)),
          const SizedBox(width: 8),
          Switch(
            value: isPublic,
            activeColor: context.colorScheme.primary,
            onChanged: (value) => setState(() => isPublic = value),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskCard(TaskModel task, int index) {
    final colorScheme = context.colorScheme;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(40),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        child: Row(
          children: [
            InkWell(
              onTap: () => _removeTask(index),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: AppColors.danger, shape: BoxShape.circle),
                child: const Icon(Icons.close, size: 20, color: AppColors.base50),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(color: colorScheme.primary, shape: BoxShape.circle),
              child: CustomCachedImage(width: 50, height: 50, isCircle: true, imageUrl: task.logoUrl),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(task.title, style: AppTextStyle.textSm(color: colorScheme.onSurface, weight: FontWeight.w600)),
                  Text(task.description, overflow: TextOverflow.ellipsis, maxLines: 2, style: AppTextStyle.textXs(color: colorScheme.onSurfaceVariant)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCoupon({required File? file, VoidCallback? onTap}) {
    final colorScheme = context.colorScheme;

    if (file == null) {
      return GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colorScheme.primary.withOpacity(0.3), width: 1.5),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [colorScheme.primary.withOpacity(0.05), colorScheme.primary.withOpacity(0.12)],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: colorScheme.primary.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
                  child: Icon(Icons.discount_outlined, color: colorScheme.primary, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Upload Coupon", style: AppTextStyle.textSm(weight: FontWeight.w600)),
                      const SizedBox(height: 2),
                      Text("PDF or image accepted", style: AppTextStyle.textXs(color: colorScheme.onSurfaceVariant)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: colorScheme.primary, borderRadius: BorderRadius.circular(20)),
                  child: Text("Browse", style: AppTextStyle.textXs(weight: FontWeight.w600, color: colorScheme.onPrimary)),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final isPdf = file.path.toLowerCase().endsWith(".pdf");
    final fileName = file.path.split("/").last;
    final fileColor = isPdf ? AppColors.danger : colorScheme.primary;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: colorScheme.surfaceContainerHigh,
        boxShadow: [BoxShadow(color: colorScheme.shadow.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(width: 4, color: fileColor),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(color: fileColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                        child: Icon(isPdf ? Icons.picture_as_pdf_rounded : Icons.image_rounded, color: fileColor, size: 20),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(fileName, style: AppTextStyle.textSm(weight: FontWeight.w600, color: colorScheme.onSurface), maxLines: 1, overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 3),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(color: fileColor.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                                  child: Text(isPdf ? "PDF" : "Image", style: AppTextStyle.textXs(weight: FontWeight.w600, color: fileColor)),
                                ),
                                const SizedBox(width: 6),
                                Text("Coupon uploaded", style: AppTextStyle.textXs(color: colorScheme.onSurfaceVariant)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Material(
                        color: AppColors.danger.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(10),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(10),
                          onTap: () => setState(() => coupon = null),
                          child: Padding(padding: const EdgeInsets.all(8), child: Icon(Icons.delete_outline_rounded, color: AppColors.danger, size: 18)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showBottomSheet() {
    final colorScheme = context.colorScheme;
    showModalBottomSheet(
      backgroundColor: colorScheme.surface,
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: MediaQuery.of(context).viewInsets.bottom + 20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Add Requirement", style: AppTextStyle.textLg(weight: FontWeight.w600, color: colorScheme.onSurface)),
                    IconButton(onPressed: () => Navigator.pop(context), icon: Icon(Icons.cancel, color: colorScheme.onSurface)),
                  ],
                ),
                const SizedBox(height: 20),
                CustomTextField(
                  hintText: "Add requirement",
                  borderColor: colorScheme.outline,
                  fontSize: 14,
                  textColor: colorScheme.onSurface,
                  hintTextColor: colorScheme.onSurfaceVariant,
                  suffixIcon: Icon(Icons.search, color: colorScheme.onSurfaceVariant),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    CustomButton(width: 120, height: 50, text: "Add", onPressed: () {
                      _addTask();
                      Navigator.pop(context);
                    }),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}