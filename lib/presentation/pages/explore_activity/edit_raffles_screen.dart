import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/core/utils/show_snackbar.dart';
import 'package:loci/data/models/raffles/raffles_details_model.dart';
import 'package:loci/data/models/raffles/raffles_model.dart';
import 'package:loci/presentation/controllers/explore_acitivity/business_raffle_detils_controller.dart';
import 'package:loci/presentation/pages/explore_activity/widgets/coupon_card.dart';
import 'package:loci/presentation/widgets/custom_appbar.dart';
import 'package:loci/presentation/widgets/custom_imagepicker.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/date_parser.dart';
import '../../../data/models/explore_activity/raffle_update_request_model.dart';
import '../../../data/models/task_model.dart';
import '../../../gen/assets.gen.dart';
import '../../controllers/explore_acitivity/raffle_edit_controller.dart';
import '../../controllers/explore_acitivity/task_controller.dart';
import '../../widgets/common/company_info_card.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/task_card.dart';

import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/data/models/raffles/raffles_model.dart';
import 'package:loci/presentation/controllers/explore_acitivity/business_raffle_detils_controller.dart';
import 'package:loci/presentation/pages/explore_activity/widgets/coupon_card.dart';
import 'package:loci/presentation/widgets/custom_appbar.dart';
import 'package:loci/presentation/widgets/custom_imagepicker.dart';

import '../../../core/utils/date_parser.dart';
import '../../../data/models/raffles/raffles_details_model.dart';
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
  final raffleDetailsController = Get.find<BusinessRaffleDetailsController>();
  final taskController = Get.find<TaskController>();
  final editController = Get.find<RaffleEditController>();

  late final String raffleId;
  final GlobalKey<FormState> _mainFormKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    var args = Get.arguments as Map<String, dynamic>?;
    raffleId = args?["raffleId"] ?? "";

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      //----call api to get data
      await raffleDetailsController.fetchRaffleDetails(raffleId);

      final details = raffleDetailsController.raffleDetails;

      if (details != null) {
        editController.setData(details);
      }
    });
  }

  void _onUpdate() async {
    final ctr = editController;

    if (!(_mainFormKey.currentState?.validate() ?? false)) return;

    // -----------------------------
    // UI LEVEL VALIDATION (FAST FAIL)
    // -----------------------------

    // Banner validation
    final hasBanner =
        ctr.bannerImage != null ||
        (ctr.initialRaffle?.banner.isNotEmpty ?? false);

    if (!hasBanner) {
      SnackbarService.error("Banner image is required");
      return;
    }

    // Coupon validation
    final hasCoupon =
        ctr.couponFile != null ||
        (ctr.existingCouponUrl != null && ctr.removeCoupon == false);

    if (!hasCoupon) {
      SnackbarService.error("Coupon image is required");
      return;
    }

    // Tasks validation
    if (ctr.tasks.isEmpty) {
      SnackbarService.error("At least one task is required");
      return;
    }

    // -----------------------------
    // BUILD REQUEST
    // -----------------------------
    final request = ctr.buildRequest();

    // -----------------------------
    // API CALL
    // -----------------------------
    final success = await ctr.updateRaffles(request);

    if (success) {
      Get.back(result: true);
      SnackbarService.success("Raffle updated");
    } else {
      SnackbarService.error(ctr.errorMessage ?? "Update failed");
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return GetBuilder<RaffleEditController>(
      builder: (editController) {
        return Scaffold(
          backgroundColor: colorScheme.surface,
          appBar: const CustomAppbar(title: "Edit Raffle"),
          body: GetBuilder<BusinessRaffleDetailsController>(
            builder: (detailsCtr) {
              if (detailsCtr.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              final raffle = detailsCtr.raffleDetails?.raffleModel;
              final sponsor = detailsCtr.raffleDetails?.sponsor;

              if (raffle == null)
                return const Center(child: Text("Raffle not found"));

              return Form(
                key: _mainFormKey,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildBanner(colorScheme, editController),
                      const SizedBox(height: 18),
                      _buildHeaderSection(colorScheme, editController),
                      const SizedBox(height: 6),
                      Text(
                        editController.detailsController.text,
                        style: AppTextStyle.textXs(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 22),
                      _buildDueDateAndSupply(colorScheme, editController),
                      const SizedBox(height: 20),
                      _buildVoucherSection(colorScheme, editController),
                      const SizedBox(height: 20),
                      _buildTasksSection(colorScheme, editController),
                      const SizedBox(height: 24),
                      _buildSponsorToggle(colorScheme, editController),
                      const SizedBox(height: 12),
                      CompanyInfoCard(
                        title: sponsor?.name ?? "No Name",
                        description: sponsor?.description ?? "No Description",
                        imagePath: sponsor?.logo ?? "",
                      ),
                      const SizedBox(height: 28),
                      _buildBottomButtons(colorScheme, editController),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  /// Banner Image
  Widget _buildBanner(ColorScheme colorScheme, RaffleEditController ctr) {
    return CustomImagePicker(
      imageUrl: ctr.initialRaffle?.banner,
      height: 200,
      backgroundColor: colorScheme.surfaceContainerHigh,
      selectedImage: ctr.bannerImage,
      onImageSelected: (file) => ctr.setBanner(file),
      placeholder: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.cloud_upload_outlined,
              color: colorScheme.onSurface,
              size: 30,
            ),
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

  /// Title + Edit Icon
  Widget _buildHeaderSection(
    ColorScheme colorScheme,
    RaffleEditController ctr,
  ) {
    return Row(
      children: [
        Expanded(
          child: Text(
            ctr.titleController.text,
            style: AppTextStyle.textMd(
              weight: FontWeight.w700,
              color: colorScheme.onSurface,
            ),
          ),
        ),
        IconButton(
          onPressed: _showEditBottomSheet,
          icon: Icon(Icons.edit_outlined, color: colorScheme.primary, size: 20),
        ),
      ],
    );
  }

  /// Date & Supply Fields
  Widget _buildDueDateAndSupply(
    ColorScheme colorScheme,
    RaffleEditController ctr,
  ) {
    return Row(
      children: [
        Expanded(
          child: CustomTextField(
            title: "Expire Date",
            onTap: _showDateRangePicker,
            controller: ctr.dateController,
            readOnly: true,
            hintText: "Select date",
            suffixIcon: Icon(
              Icons.calendar_today_outlined,
              size: 18,
              color: colorScheme.onSurfaceVariant,
            ),
            borderColor: colorScheme.outline,
            validator: (v) => v == null || v.isEmpty ? 'Required' : null,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: CustomTextField(
            title: "Max Supply",
            controller: ctr.maxSupplyController,
            keyboardType: TextInputType.number,
            hintText: "Enter supply",
            borderColor: colorScheme.outline,
            onChanged: (v) => ctr.update(),
            validator: (v) => v == null || v.isEmpty ? 'Required' : null,
          ),
        ),
      ],
    );
  }

  /// Voucher Section
  Widget _buildVoucherSection(
    ColorScheme colorScheme,
    RaffleEditController ctr,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextField(
          controller: ctr.raffleBundleNameTEController,
          title: "coupon",
          hintText: "Enter coupon title",
          prefixIcon: const Icon(Icons.card_giftcard),
          borderColor: context.colorScheme.outline,
          textColor: context.colorScheme.onSurface,
          validator: (v) => v == null || v.isEmpty ? "Required" : null,
        ),

        const SizedBox(height: 12),
        CouponUploadCard(
          file: ctr.couponFile,
          imageUrl: ctr.removeCoupon
              ? null
              : (ctr.couponFile == null ? ctr.existingCouponUrl : null),
          onTap: _pickCoupon,
          onDelete: () => ctr.removeCouponFile(),
        ),
      ],
    );
  }

  /// Tasks Section
  Widget _buildTasksSection(ColorScheme colorScheme, RaffleEditController ctr) {

    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      color: colorScheme.surfaceContainer,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Tasks required (Check-in):",
              style: AppTextStyle.textSm(
                weight: FontWeight.w700,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            ...ctr.tasks.map((task) {
              final activity = task.activity;
              return TaskCard(
                id: activity?.id ?? "",
                title: activity?.title ?? "No title",
                description: activity?.details ?? "No description",
                imageUrl: activity?.banner ?? "",
                onRemove: () => ctr.removeTask(activity?.id ?? ""),
              );
            }),
            const SizedBox(height: 12),
            CustomButton(
              backgroundColor: colorScheme.surface,
              side: BorderSide(color: colorScheme.primary),
              onPressed: () {

                _taskBottomSheet(raffleDetailsController.raffleDetails!);
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add, color: colorScheme.primary, size: 22),
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

  /// Toggle Section
  Widget _buildSponsorToggle(
    ColorScheme colorScheme,
    RaffleEditController ctr,
  ) {
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
          ctr.isPublic ? "Public" : "Private",
          style: AppTextStyle.textSm(color: colorScheme.onSurfaceVariant),
        ),
        Switch(
          value: ctr.isPublic,
          activeColor: colorScheme.primary,
          onChanged: (v) => ctr.togglePublic(v),
        ),
      ],
    );
  }

  /// Bottom Buttons
  Widget _buildBottomButtons(
    ColorScheme colorScheme,
    RaffleEditController ctr,
  ) {
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
            isLoading: ctr.isLoading,
            text: "Update",
            backgroundColor: colorScheme.primary,
            textColor: colorScheme.onPrimary,
            onPressed: ctr.hasChanged() ? _onUpdate : null,
          ),
        ),
      ],
    );
  }

  Future<void> _showDateRangePicker() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      initialDateRange:
          editController.startDate != null && editController.endDate != null
          ? DateTimeRange(
              start: editController.startDate!,
              end: editController.endDate!,
            )
          : null,
    );
    if (picked != null) {
      editController.updateDateRange(picked.start, picked.end);
    }
  }

  Future<void> _pickCoupon() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'png', 'pdf'],
    );
    if (result != null)
      editController.setCoupon(File(result.files.single.path!));
  }

  void _showEditBottomSheet() {
    final colorScheme = context.colorScheme;
    final localTitle = TextEditingController(
      text: editController.titleController.text,
    );
    final localDetails = TextEditingController(
      text: editController.detailsController.text,
    );
    final _formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Update Info",
                style: AppTextStyle.textMd(color: colorScheme.onSurface),
              ),

              CustomTextField(
                title: "Title",
                controller: localTitle,
                borderColor: colorScheme.outline,
                validator: (v) => v == null || v.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                title: "Description",
                controller: localDetails,
                borderColor: colorScheme.outline,
                maxLine: 4,
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 20),
              CustomButton(
                text: "Done",
                onPressed: () {
                  if (!_formKey.currentState!.validate()) return;

                  editController.titleController.text = localTitle.text;
                  editController.detailsController.text = localDetails.text;
                  editController.update();
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _taskBottomSheet(RaffleDetailsModel raffleDetails) {
    final colorScheme = context.colorScheme;

    showModalBottomSheet(
      backgroundColor: colorScheme.surface,
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Add Requirement",
                    style: AppTextStyle.textLg(
                      weight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.cancel, color: colorScheme.onSurface),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // --- SEARCH FIELD ---
              CustomTextField(
                hintText: "Search for raffles task...",
                borderColor: colorScheme.outline,
                fontSize: 14,
                textColor: colorScheme.onSurface,
                hintTextColor: colorScheme.onSurfaceVariant,
                suffixIcon: Icon(
                  Icons.search,
                  color: colorScheme.onSurfaceVariant,
                ),
                // Use onChanged for real-time searching
                onChanged: (value) {
                  if (value.isNotEmpty) {
                    taskController.fetchTasks(
                      isRefresh: true,
                      query: value,
                      businessId: raffleDetails.sponsor.id

                    );
                  }
                },
              ),

              const SizedBox(height: 10),

              // --- SEARCH RESULTS ---
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.4,
                ),
                child: GetBuilder<TaskController>(
                  builder: (controller) {
                    if (controller.isLoading) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20.0),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }

                    if (controller.taskList.isEmpty) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20.0),
                          child: Text("Search for activities to add"),
                        ),
                      );
                    }

                    return NotificationListener<ScrollNotification>(
                      onNotification: (ScrollNotification scrollNotify) {
                        if (scrollNotify.metrics.pixels >=
                            scrollNotify.metrics.maxScrollExtent - 200) {
                          if (!controller.isPaginationLoading &&
                              controller.hasMore) {
                            controller.loadMoreTasks(
                              businessId: raffleDetails.sponsor.id,
                            );
                          }
                        }

                        return false;
                      },

                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: controller.taskList.length + 1,
                        itemBuilder: (context, index) {
                          //-------pagination loader on last index-------------

                          if (index == controller.taskList.length) {
                            //----loader
                            if (controller.isPaginationLoading) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                child: Center(
                                  child: SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(),
                                  ),
                                ),
                              );
                            }

                            //--if  no more data
                            if (!controller.hasMore) {
                              return const Padding(
                                padding: EdgeInsets.symmetric(vertical: 16),
                                child: Center(child: Text("No more activity")),
                              );
                            }

                            return const SizedBox.shrink(); // nothing to show
                          }

                          final item = controller.taskList[index];

                          return ListTile(
                            title: Text(item.title),
                            subtitle: Text(item.activityType),
                            trailing: Icon(
                              Icons.add_circle,
                              color: colorScheme.primary,
                            ),
                            onTap: () {

                              editController.addTask(item);
                              Navigator.pop(context);

                            },
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
