import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/constants/app_url.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/core/utils/acitvity_validator.dart';
import 'package:loci/presentation/controllers/my_business/create_actvity_controller.dart';
import 'package:loci/presentation/controllers/my_business/get_my_business_list _controller.dart';
import 'package:loci/presentation/pages/clam_business/widgets/my_business.dart';
import 'package:loci/presentation/widgets/custom_appbar.dart';
import 'package:loci/presentation/widgets/custom_dropdown.dart';
import 'package:loci/presentation/widgets/custom_imagepicker.dart';
import 'package:loci/presentation/widgets/task_card.dart';
import '../../../core/enums/routeType.dart';
import '../../../core/enums/activity_type.dart';
import '../../../core/utils/date_parser.dart';
import '../../../core/utils/show_snackbar.dart';
import '../../../core/utils/time_parser.dart';
import '../../../data/models/task_model.dart';
import 'widgets/coupon_card.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

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
  final TextEditingController raffleDateController = TextEditingController();
  final TextEditingController couponTitleController = TextEditingController();

  //---get x controller
  final createActivityController = Get.find<CreateActivityController>();

  final _formKey = GlobalKey<FormState>();

  // EVENT
  DateTime? eventDate;
  TimeOfDay? eventTime;

  // ROUTE
  TimeOfDay? routeOpeningTime;

  // RAFFLE (range)
  DateTimeRange? raffleRange;

  File? bannerImage;
  File? rafflePrizeImage;

  List<TaskModel> tasks = [];

  ActivityType selectedCategory = ActivityType.event;
  RouteType? selectedRouteCondition;
  bool isPublic = false;

  late final String businessId;
  late final String businessName;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    final args = Get.arguments as Map<String, dynamic>?;

    businessId = args?["businessId"] ?? "";
    businessName = args?["businessName"] ?? "";
  }

  @override
  void dispose() {
    dateTEController.dispose();
    timeTEController.dispose();
    titleController.dispose();
    detailsController.dispose();
    personController.dispose();
    locationController.dispose();
    raffleDateController.dispose();
    urlController.dispose();
    maxSupplyController.dispose();
    couponTitleController.dispose();
    super.dispose();
  }

  void showCalendar() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      initialDate: DateTime.now(),
      lastDate: DateTime(2049),
    );

    if (pickedDate == null) return;

    setState(() {
      if (selectedCategory == ActivityType.event) {
        eventDate = pickedDate;
        dateTEController.text = DateParserHelper.toFriendlyDate(pickedDate);
      }

      if (selectedCategory == ActivityType.raffles) {}
    });
  }

  void pickRaffleRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime(2049),
    );

    if (picked == null) return;

    setState(() {
      raffleRange = picked;

      raffleDateController.text =
          "${DateParserHelper.shortDate(picked.start)} → "
          "${DateParserHelper.shortDate(picked.end)}";
    });
  }

  void showTime() async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: child!,
        );
      },
    );

    if (pickedTime == null) return;

    setState(() {
      if (selectedCategory == ActivityType.event) {
        eventTime = pickedTime;
      }

      if (selectedCategory == ActivityType.routes) {
        routeOpeningTime = pickedTime;
      }

      timeTEController.text = pickedTime.format(context);
    });
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
      rafflePrizeImage = File(path);
    });
  }

  void _addTask() {
    setState(() {
      tasks.add(
        TaskModel(
          title: "Task1",
          description: "afafafaf",
          logoUrl: 'assets/images/finedine.png',
        ),
      );
    });
  }

  void _removeTask(int index) {
    setState(() {
      tasks.removeAt(index);
    });
  }

  // clear data when do switch category
  void _clearCategoryData() {
    setState(() {
      dateTEController.clear();
      timeTEController.clear();
      titleController.clear();
      detailsController.clear();
      personController.clear();
      locationController.clear();
      urlController.clear();
      maxSupplyController.clear();
      raffleDateController.clear();

      bannerImage = null;
      rafflePrizeImage = null;

      tasks.clear();

      selectedRouteCondition = null;
      isPublic = false;

      // reset dates/times
      eventDate = null;
      eventTime = null;
      routeOpeningTime = null;
      raffleRange = null;
    });
  }

  void _publishHandler() async {
    final error = ActivityValidator.validateAll(
      formKey: _formKey,
      bannerPath: bannerImage?.path,
      category: selectedCategory,

      // EVENT
      eventDate: eventDate,
      eventTime: eventTime,

      // ROUTE
      routeOpeningTime: routeOpeningTime,
      routeType: selectedRouteCondition,

      // RAFFLE
      raffleRange: raffleRange,

      hasCoupon: rafflePrizeImage != null,
      hasTasks: tasks.isNotEmpty,
    );

    //----show the error  ---------------
    if (error != null) {
      if (error != "FORM_INVALID") {
        SnackbarService.warning(error);
      }
      return;
    }

    /// =========================
    /// BUILD BODY (CLEAN & SAFE)
    /// =========================
    final Map<String, String> body = {
      "activityType": selectedCategory.toJson,
      "title": titleController.text.trim(),
      "details": detailsController.text.trim(),
      "isPublic": isPublic.toString(),
      "organizerBusiness": businessId ?? '',
    };

    /// EVENT payload
    if (selectedCategory == ActivityType.event) {
      body.addAll({
        "eventDate": combineToUtcIso(eventDate!, eventTime!),
        "eventTime": eventTime!.format(context),
        "maxParticipants": personController.text.trim(),
        "location": locationController.text.trim(),
        "url": urlController.text.trim(),
      });
    }

    /// ROUTE payload
    if (selectedCategory == ActivityType.routes) {
      body.addAll({
        "openingTime": routeOpeningTime!.format(context),
        "availabilityType": selectedRouteCondition?.apiValue ?? '',
        "location": locationController.text.trim(),
        "url": urlController.text.trim(),
      });
    }

    /// RAFFLE payload
    if (selectedCategory == ActivityType.raffles) {
      body.addAll({
        "startDate": raffleRange!.start.toIso8601String(),
        "endDate": raffleRange!.end.toIso8601String(),
        "maxSupply": maxSupplyController.text.trim(),
        "raffleBundleName": couponTitleController.text.trim(),
      });
    }

    /// =========================
    /// API CALL
    /// =========================

    final String url = selectedCategory == ActivityType.event
        ? AppUrl.createEvent
        : selectedCategory == ActivityType.routes
        ? AppUrl.createRoute
        : AppUrl.createRaffle;

    final success = await createActivityController.createActivity(
      url: url,
      body: body,
      files: {"banner": bannerImage!, if (rafflePrizeImage != null) "rafflePrizeImage": rafflePrizeImage!},
    );

    if (success) {
      Get.back();
      SnackbarService.success(createActivityController.message);
    } else {
      SnackbarService.error(createActivityController.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colorScheme.surface,
      appBar: const CustomAppbar(title: "Create Activity"),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
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
      ),
    );
  }

  Widget _bannerImagePicker() {
    final colorScheme = context.colorScheme;
    return CustomImagePicker(
      backgroundColor: context.colorScheme.surfaceContainerHigh,
      selectedImage: bannerImage,
      height: 200,
      onImageSelected: (file) => setState(() => bannerImage = file),
      placeholder: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.cloud_upload_outlined,
              color: colorScheme.onSurface,
              size: 30,
            ),
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

  Widget _topFields() {
    final colorScheme = context.colorScheme;
    return Column(
      children: [
        CustomDropdown<ActivityType>(
          value: selectedCategory,
          hintText: "Select Category",
          dropdownColor: colorScheme.surfaceContainerHigh,
          borderColor: colorScheme.outline,
          hintColor: colorScheme.onSurfaceVariant,
          textColor: colorScheme.onSurface,
          textFontSize: 14,
          hintFontSize: 14,
          items: ActivityType.values.map((type) {
            return DropdownMenuItem<ActivityType>(
              value: type,
              child: Text(type.label),
            );
          }).toList(),
          onChanged: (value) {
            if (value != selectedCategory) {
              _clearCategoryData();
            }
            setState(() => selectedCategory = value!);
          },
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: titleController,
          title: "Title",
          hintText: "Enter title",
          borderColor: colorScheme.outline,
          textColor: colorScheme.onSurface,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return "Title is required";
            }
            if (value.length < 3) {
              return "Title should be at least 3 characters";
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: detailsController,
          title: "Details",
          hintText: "Enter details",
          maxLine: 5,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return "Details are required";
            }

            if (value.trim().length > 200) {
              return "Details must be under 200 characters";
            }

            return null;
          },
          borderColor: colorScheme.outline,
          textColor: colorScheme.onSurface,
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _middleField() {
    switch (selectedCategory) {
      case ActivityType.event:
        return _eventFields();
      case ActivityType.routes:
        return _routeFields();
      case ActivityType.raffles:
        return _raffleFields();
    }
  }

  Widget _eventFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Event Schedule and Seats",
          style: AppTextStyle.textSm(weight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                controller: dateTEController,
                readOnly: true,
                onTap: showCalendar,
                hintText: "Select date",
                suffixIcon: Icon(
                  Icons.calendar_today_outlined,
                  size: 18,
                  color: context.colorScheme.onSurfaceVariant,
                ),
                borderColor: context.colorScheme.outline,
                textColor: context.colorScheme.onSurface,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "required date";
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CustomTextField(
                controller: timeTEController,
                readOnly: true,
                onTap: showTime,
                hintText: "Select time",
                suffixIcon: Icon(
                  Icons.access_time,
                  size: 18,
                  color: context.colorScheme.onSurfaceVariant,
                ),
                borderColor: context.colorScheme.outline,
                textColor: context.colorScheme.onSurface,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "required time";
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CustomTextField(
                controller: personController,
                hintText: "Person",
                keyboardType: TextInputType.number,
                suffixIcon: Icon(
                  Icons.person_outline,
                  size: 18,
                  color: context.colorScheme.onSurfaceVariant,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Person is required";
                  }
                  return null;
                },
                borderColor: context.colorScheme.outline,
                textColor: context.colorScheme.onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _routeFields() {
    final colorScheme = context.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Route Details",
          style: AppTextStyle.textSm(weight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                controller: timeTEController,
                readOnly: true,
                title: "Opening",
                onTap: showTime,
                hintText: "Select time",
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Required opening time";
                  }
                  return null;
                },
                suffixIcon: Icon(
                  Icons.access_time,
                  size: 18,
                  color: context.colorScheme.onSurfaceVariant,
                ),
                borderColor: context.colorScheme.outline,
                textColor: context.colorScheme.onSurface,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Expanded(
                child: CustomDropdown<RouteType>(
                  dropdownColor: colorScheme.surfaceContainerHigh,
                  borderColor: colorScheme.outline,
                  hintColor: colorScheme.onSurfaceVariant,
                  textColor: colorScheme.onSurface,
                  textFontSize: 14,
                  hintFontSize: 14,
                  title: "Availability types",
                  value: selectedRouteCondition,
                  hintText: "Route type",

                  items: RouteType.values.map((type) {
                    return DropdownMenuItem<RouteType>(
                      value: type,
                      child: Text(type.label),
                    );
                  }).toList(),

                  onChanged: (value) {
                    setState(() {
                      selectedRouteCondition = value;
                    });
                  },

                  validator: (value) {
                    if (value == null) {
                      return "Required Availability type";
                    }
                    return null;
                  },
                ),
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
                controller: raffleDateController,
                title: "Date validity",
                readOnly: true,
                onTap: pickRaffleRange,
                hintText: "Select date range",
                suffixIcon: Icon(
                  Icons.calendar_today_outlined,
                  size: 18,
                  color: context.colorScheme.onSurfaceVariant,
                ),
                borderColor: context.colorScheme.outline,
                textColor: context.colorScheme.onSurface,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "required date";
                  }
                  return null;
                },
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
                suffixIcon: Icon(
                  Icons.person_outline,
                  size: 18,
                  color: context.colorScheme.onSurfaceVariant,
                ),
                borderColor: context.colorScheme.outline,
                textColor: context.colorScheme.onSurface,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "required supply";
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        CustomTextField(
          controller: couponTitleController,
          title: "coupon",
          hintText: "Enter coupon title",
          prefixIcon: const Icon(Icons.card_giftcard),
          borderColor: context.colorScheme.outline,
          textColor: context.colorScheme.onSurface,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return "Coupon title is required";
            }
            return null;
          },
        ),

        const SizedBox(height: 12),
        CouponUploadCard(
          file: rafflePrizeImage,
          onTap: _pickCoupon,
          onDelete: () {
            setState(() {
              rafflePrizeImage = null;
            });
          },
        ),
        const SizedBox(height: 16),

        Card(
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
                        _removeTask(index);
                      },
                    ),
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
        ),
      ],
    );
  }

  Widget _bottomFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (selectedCategory != ActivityType.raffles) ...[
          CustomTextField(
            controller: locationController,
            title: "Location",
            hintText: "Enter location",
            prefixIcon: const Icon(Icons.location_on),
            borderColor: context.colorScheme.outline,
            textColor: context.colorScheme.onSurface,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return "Location is required";
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          CustomTextField(
            controller: urlController,
            title: "Map Url",
            hintText: "Enter url",
            prefixIcon: const Icon(Icons.location_disabled),
            borderColor: context.colorScheme.outline,
            textColor: context.colorScheme.onSurface,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return "Location url is required";
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
        ],

        _organizerToggle(),
        const SizedBox(height: 10),


          MyOwnBusiness(businessName: businessName),

        const SizedBox(height: 10),
        GetBuilder<CreateActivityController>(
          builder: (controller) {
            return CustomButton(
              isLoading: controller.isLoading,
              text: "Publish",
              backgroundColor: context.colorScheme.primary,
              textColor: context.colorScheme.onPrimary,
              onPressed: _publishHandler,
            );
          },
        ),
      ],
    );
  }

  Widget _organizerToggle() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(
            "Organizer",
            style: AppTextStyle.textMd(
              weight: FontWeight.w700,
              color: context.colorScheme.onSurface,
            ),
          ),
          const Spacer(),
          Text(
            isPublic ? "Public" : "Private",
            style: AppTextStyle.textSm(
              weight: FontWeight.w700,
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
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

  void _showBottomSheet() {
    final colorScheme = context.colorScheme;
    showModalBottomSheet(
      backgroundColor: colorScheme.surface,
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
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
          child: SingleChildScrollView(
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
                CustomTextField(
                  hintText: "Add requirement",
                  borderColor: colorScheme.outline,
                  fontSize: 14,
                  textColor: colorScheme.onSurface,
                  hintTextColor: colorScheme.onSurfaceVariant,
                  suffixIcon: Icon(
                    Icons.search,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
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
}
