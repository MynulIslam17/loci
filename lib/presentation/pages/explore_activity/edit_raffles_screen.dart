import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/presentation/pages/explore_activity/widgets/coupon_card.dart';
import 'package:loci/presentation/widgets/custom_appbar.dart';
import 'package:loci/presentation/widgets/custom_imagepicker.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/date_parser.dart';
import '../../../data/models/task_model.dart';
import '../../../gen/assets.gen.dart';
import '../../widgets/common/company_info_card.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/task_card.dart';

class EditRafflesScreen extends StatefulWidget {
  const EditRafflesScreen({super.key});

  @override
  State<EditRafflesScreen> createState() => _EditRafflesScreenState();
}

class _EditRafflesScreenState extends State<EditRafflesScreen> {

  /// ===============================================================
  /// AppBar Title
  /// ===============================================================
  late String appBarTitle;

  /// ===============================================================
  /// Text Controllers
  /// ===============================================================
  final TextEditingController titleController =
  TextEditingController(text: "Coffee Lovers Bundle");

  final TextEditingController detailsController = TextEditingController(
    text: "Experience the best craft beer spots in downtown...",
  );

  final TextEditingController dateTEController = TextEditingController();
  final TextEditingController maxSupplyController = TextEditingController();

  /// Task Search Controller (BottomSheet)
  final TextEditingController taskController = TextEditingController();

  /// ===============================================================
  /// State Variables
  /// ===============================================================
  File? couponFile;
  File? bannerImage;

  bool isPublic = true;

  /// ===============================================================
  /// Dummy Task Data
  /// ===============================================================
  List<TaskModel> tasks = [
    TaskModel(
      title: "David Smith",
      description: "Lorem Ipsum is simply dummy text...",
      logoUrl: "assets/images/logo.png",
    ),
    TaskModel(
      title: "David Smith",
      description: "Lorem Ipsum is simply dummy text...",
      logoUrl: "assets/images/logo.png",
    ),
    TaskModel(
      title: "David Smith",
      description: "Lorem Ipsum is simply dummy text...",
      logoUrl: "assets/images/logo.png",
    ),
  ];

  /// ===============================================================
  /// Lifecycle
  /// ===============================================================

  @override
  void initState() {
    super.initState();

    /// Receive title from previous screen
    var args = Get.arguments;
    appBarTitle =
    (args != null && args is Map) ? args["title"] ?? "Edit Raffle" : "Edit Raffle";
  }

  @override
  void dispose() {
    titleController.dispose();
    detailsController.dispose();
    dateTEController.dispose();
    maxSupplyController.dispose();
    taskController.dispose();
    super.dispose();
  }

  /// ===============================================================
  /// Date Picker
  /// ===============================================================
  void showCalendar() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      firstDate: DateTime(1940),
      initialDate: DateTime.now(),
      lastDate: DateTime(2049),
    );

    if (pickedDate != null) {
      setState(() {
        dateTEController.text =
            DateParserHelper.toFriendlyDate(pickedDate);
      });
    }
  }

  /// ===============================================================
  /// Pick Coupon File (PDF/Image)
  /// ===============================================================
  Future<void> _pickCoupon() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
    );

    if (result == null) return;

    final path = result.files.single.path;
    if (path == null) return;

    setState(() {
      couponFile = File(path);
    });
  }

  /// ===============================================================
  /// Add Task
  /// ===============================================================
  void _addTask() {
    setState(() {
      tasks.add(
        TaskModel(
          title: taskController.text.isEmpty
              ? "Task"
              : taskController.text,
          description: "New Task",
          logoUrl: "assets/images/logo.png",
        ),
      );
    });

    taskController.clear();
  }

  /// ===============================================================
  /// Main UI
  /// ===============================================================
  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: CustomAppbar(title: appBarTitle),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// Banner Image
            _buildBanner(colorScheme),

            const SizedBox(height: 18),

            /// Title Section
            _buildHeaderSection(colorScheme),

            const SizedBox(height: 6),

            /// Description Text
            Text(
              detailsController.text,
              style:
              AppTextStyle.textXs(color: colorScheme.onSurfaceVariant),
            ),

            const SizedBox(height: 22),

            /// Due Date + Supply
            _buildDueDateAndSupply(colorScheme),

            const SizedBox(height: 20),

            /// Coupon Upload Section
            _buildPriceSection(colorScheme),

            const SizedBox(height: 20),

            /// Tasks Section
            _buildTasksSection(colorScheme),

            const SizedBox(height: 24),

            /// Sponsor Toggle
            _buildSponsorToggle(colorScheme),

            const SizedBox(height: 12),

            /// Company Info
            CompanyInfoCard(
              title: "Marland Clutch",
              description: "Lorem Ipsum is simply dummy text...",
              imagePath: Assets.images.companyLogo.path,
            ),

            const SizedBox(height: 28),

            /// Bottom Buttons
            _buildBottomButtons(colorScheme),
          ],
        ),
      ),
    );
  }

  /// ===============================================================
  /// Banner Image Picker
  /// ===============================================================
  Widget _buildBanner(ColorScheme colorScheme) {
    return CustomImagePicker(
      height: 200,
      backgroundColor: colorScheme.surfaceContainerHigh,
      selectedImage: bannerImage,
      onImageSelected: (file) {
        setState(() {
          bannerImage = file;
        });
      },
      placeholder: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_upload_outlined,
                color: colorScheme.onSurface, size: 30),
            const SizedBox(height: 6),
            Text(
              "Browse image",
              style: AppTextStyle.textMd(
                color: colorScheme.onSurface,
                weight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ===============================================================
  /// Header Section (Title + Edit Button)
  /// ===============================================================
  Widget _buildHeaderSection(ColorScheme colorScheme) {
    return Row(
      children: [
        Expanded(
          child: Text(
            titleController.text,
            style: AppTextStyle.textMd(
              weight: FontWeight.w700,
              color: colorScheme.onSurface,
            ),
          ),
        ),
        IconButton(
          onPressed: _showEditBottomSheet,
          icon: Icon(Icons.edit_outlined,
              color: colorScheme.primary, size: 20),
        ),
      ],
    );
  }

  /// ===============================================================
  /// Due Date + Max Supply
  /// ===============================================================
  Widget _buildDueDateAndSupply(ColorScheme colorScheme) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Due date",
                  style: AppTextStyle.textSm(
                      weight: FontWeight.w700,
                      color: colorScheme.onSurface)),
              const SizedBox(height: 8),
              CustomTextField(
                onTap: showCalendar,
                controller: dateTEController,
                readOnly: true,
                hintText: "Select date",
                suffixIcon: Icon(Icons.calendar_today_outlined,
                    size: 18,
                    color: colorScheme.onSurfaceVariant),
                borderColor: colorScheme.outline,
              ),
            ],
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Max Supply",
                  style: AppTextStyle.textSm(
                      weight: FontWeight.w700,
                      color: colorScheme.onSurface)),
              const SizedBox(height: 8),
              CustomTextField(
                controller: maxSupplyController,
                keyboardType: TextInputType.number,
                hintText: "Enter supply",
                borderColor: colorScheme.outline,
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// ===============================================================
  /// Coupon Upload Section
  /// ===============================================================
  Widget _buildPriceSection(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Voucher",
          style: AppTextStyle.textSm(
            weight: FontWeight.w700,
            color: colorScheme.onSurface,
          ),
        ),

        const SizedBox(height: 12),

        CouponUploadCard(
          file: couponFile,
          onTap: _pickCoupon,
          onDelete: () {
            setState(() {
              couponFile = null;
            });
          },
        )
      ],
    );
  }

  /// ===============================================================
  /// Tasks Section
  /// ===============================================================
  Widget _buildTasksSection(ColorScheme colorScheme) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      color: colorScheme.surfaceContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),

      child: Padding(
        padding: const EdgeInsets.all(12.0),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// Section Title
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'Tasks required ',
                    style: AppTextStyle.textSm(
                      weight: FontWeight.w700,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  TextSpan(
                    text: '(Check-in):',
                    style: AppTextStyle.textXs(
                      weight: FontWeight.w400,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            /// Task List
            if (tasks.isNotEmpty)
              ListView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: tasks.length,
                itemBuilder: (context, index) => TaskCard(
                  title: tasks[index].title,
                  description: tasks[index].description,
                  imageUrl: tasks[index].logoUrl,
                  onRemove: () {
                    setState(() {
                      tasks.removeAt(index);
                    });
                  },
                ),
              ),

            const SizedBox(height: 12),

            /// Add Task Button
            CustomButton(
              backgroundColor: colorScheme.surface,
              side: BorderSide(color: colorScheme.primary),
              onPressed: _showBottomSheet,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add,
                      color: colorScheme.primary, size: 22),
                  const SizedBox(width: 8),
                  Text(
                    "Add requirement",
                    style: AppTextStyle.textMd(
                      color: colorScheme.primary,
                      weight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ===============================================================
  /// Sponsor Toggle
  /// ===============================================================
  Widget _buildSponsorToggle(ColorScheme colorScheme) {
    return Row(
      children: [
        Text(
          "Sponsor",
          style: AppTextStyle.textMd(
            weight: FontWeight.w700,
            color: colorScheme.onSurface,
          ),
        ),
        const Spacer(),
        Text(
          isPublic ? "Public" : "Private",
          style: AppTextStyle.textSm(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(width: 8),
        Switch(
          value: isPublic,
          activeColor: colorScheme.primary,
          onChanged: (v) => setState(() => isPublic = v),
        ),
      ],
    );
  }

  /// ===============================================================
  /// Bottom Buttons
  /// ===============================================================
  Widget _buildBottomButtons(ColorScheme colorScheme) {
    return Row(
      children: [
        Expanded(
          child: CustomButton(
            text: "Cancel",
            backgroundColor: Colors.transparent,
            side: BorderSide(color: colorScheme.outline),
            textColor: colorScheme.onSurface,
            onPressed: () => Navigator.pop(context),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: CustomButton(
            text: "Update",
            backgroundColor: colorScheme.primary,
            textColor: colorScheme.onPrimary,
            onPressed: () {},
          ),
        ),
      ],
    );
  }

  /// ===============================================================
  /// BottomSheet : Add Task
  /// ===============================================================
  void _showBottomSheet() {
    final colorScheme = context.colorScheme;

    showModalBottomSheet(
      backgroundColor: colorScheme.surface,
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius:
        BorderRadius.vertical(top: Radius.circular(20)),
      ),

      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom:
            MediaQuery.of(context).viewInsets.bottom + 20,
          ),

          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [

                /// Header
                Row(
                  mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Add Requirement",
                      style: AppTextStyle.textLg(
                        weight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    IconButton(
                      onPressed: () =>
                          Navigator.pop(context),
                      icon: Icon(Icons.cancel,
                          color: colorScheme.onSurface),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                /// Task Input
                CustomTextField(
                  controller: taskController,
                  hintText: "Add requirement",
                  borderColor: colorScheme.outline,
                  fontSize: 14,
                  textColor: colorScheme.onSurface,
                  hintTextColor:
                  colorScheme.onSurfaceVariant,
                  suffixIcon: Icon(
                    Icons.search,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),

                const SizedBox(height: 20),

                /// Add Button
                Row(
                  mainAxisAlignment:
                  MainAxisAlignment.end,
                  children: [
                    CustomButton(
                      width: 120,
                      height: 50,
                      text: "Add",
                      onPressed: () {
                        _addTask();
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// ===============================================================
  /// BottomSheet : Edit Title & Description
  /// ===============================================================
  void _showEditBottomSheet() {
    final colorScheme = context.colorScheme;

    showModalBottomSheet(
      context: context,
      backgroundColor: colorScheme.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius:
        BorderRadius.vertical(top: Radius.circular(20)),
      ),

      builder: (context) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom:
          MediaQuery.of(context).viewInsets.bottom + 20,
        ),

        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            /// Title Field
            CustomTextField(
              controller: titleController,
              hintText: "Title",
              borderColor: colorScheme.outline,
            ),

            const SizedBox(height: 16),

            /// Description Field
            CustomTextField(
              controller: detailsController,
              hintText: "Description",
              maxLine: 4,
              borderColor: colorScheme.outline,
            ),

            const SizedBox(height: 20),

            /// Save Button
            CustomButton(
              text: "Done",
              onPressed: () {
                setState(() {});
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}