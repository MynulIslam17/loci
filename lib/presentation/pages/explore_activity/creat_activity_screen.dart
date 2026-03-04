import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/presentation/widgets/custom_appbar.dart';
import 'package:loci/presentation/widgets/custom_dropdown.dart';
import 'package:loci/presentation/widgets/custom_image_container.dart';
import 'package:loci/presentation/widgets/custom_imagepicker.dart';

import '../../../core/utils/date_parser.dart';
import '../../../gen/assets.gen.dart';
import '../../widgets/common/company_info_card.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class CreateActivityScreen extends StatefulWidget {
  const CreateActivityScreen({super.key});

  @override
  State<CreateActivityScreen> createState() => _CreateActivityScreenState();
}

class _CreateActivityScreenState extends State<CreateActivityScreen> {
  // ----controller for textFiled
  final dateTEController = TextEditingController();
  final timeTEController = TextEditingController();

  File? bannerImage;

  List<String> createCategory = ["Event", "Routes", "Raffles"];

  String? selectedCategory;

  String? selectedDate;
  String? selectTime;

  bool isPublic = false;


  //--- for picked date
  void showCalendar() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      firstDate: DateTime(1940),
      initialDate: DateTime.now(),
      lastDate: DateTime(2049),
    );

    if (pickedDate != null) {
      setState(() {
        selectedDate = DateParserHelper.toFriendlyDate(pickedDate);
        dateTEController.text = DateParserHelper.toFriendlyDate(pickedDate);
      });
    }
  }

  //--- for picked time
  void showTime() async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null) {
      setState(() {
        selectTime = pickedTime.toString();
        timeTEController.text = pickedTime.format(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: CustomAppbar(title: "Create Activity"),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              //--- Banner Image ---
              CustomImagePicker(
                backgroundColor: colorScheme.surfaceContainerHigh,
                selectedImage: bannerImage,
                onImageSelected: (file) {
                  setState(() {
                    bannerImage = file;
                  });
                },
                height: 200,

                placeholder: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_a_photo,
                      color: colorScheme.onSurfaceVariant,
                      size: 50,
                    ),
                    const SizedBox(height: 12),

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
              const SizedBox(height: 16),

              //-- common top filed
              _commonTopField(),

              _middleField(),


              _bottomField()


            ],
          ),
        ),
      ),
    );
  }

  //--- widget for common top filed

  Widget _commonTopField() {
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
            setState(() {
              selectedCategory = value;
            });
          },

          items: createCategory
              .map(
                (category) =>
                    DropdownMenuItem(value: category, child: Text(category)),
              )
              .toList(),
        ),
        const SizedBox(height: 16),
        CustomTextField(
          title: "Title",
          hintText: "Enter titles",
          borderColor: colorScheme.outline,
          textColor: colorScheme.onSurface,
          fontSize: 14,
          fillColor: Colors.transparent,
        ),
        const SizedBox(height: 16),

        CustomTextField(
          title: "Details",
          hintText: "Enter details",
          maxLine: 5,
          borderColor: colorScheme.outline,
          textColor: colorScheme.onSurface,
          fontSize: 14,
          fillColor: Colors.transparent,
        ),

        const SizedBox(height: 16),
      ],
    );
  }

  //----widget for middle field(changeble)

  Widget _middleField() {
    final colorScheme = context.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        //--event schedule part
        Text(
          "Event Schedule and Sets",
          style: AppTextStyle.textSm(weight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                onTap: showCalendar,
                controller: dateTEController,
                readOnly: true,
                hintText: "Mon, Jan 19",
                fontSize: 13,
                contentPaddingVertical: 12,
                suffixIcon: Icon(
                  Icons.calendar_today_outlined,
                  size: 18,
                  color: colorScheme.onSurfaceVariant,
                ),
                borderColor: colorScheme.outline,
                hintTextColor: colorScheme.onSurfaceVariant,
                textColor: colorScheme.onSurface,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CustomTextField(
                controller: timeTEController,
                onTap: showTime,
                readOnly: true,
                hintText: "2:50 PM",
                fontSize: 13,
                contentPaddingVertical: 12,
                suffixIcon: Icon(
                  Icons.access_time,
                  size: 18,
                  color: colorScheme.onSurfaceVariant,
                ),
                borderColor: colorScheme.outline,
                hintTextColor: colorScheme.onSurfaceVariant,
                textColor: colorScheme.onSurface,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CustomTextField(
                hintText: "Person",
                keyboardType: TextInputType.number,
                fontSize: 13,
                contentPaddingVertical: 12,
                suffixIcon: Icon(
                  Icons.person_outline,
                  size: 18,
                  color: colorScheme.onSurfaceVariant,
                ),
                borderColor: colorScheme.outline,
                hintTextColor: colorScheme.onSurfaceVariant,
                textColor: colorScheme.onSurface,
                fillColor: Colors.transparent,
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        CustomTextField(
          title: "Location",
          hintText: "Enter location",
          prefixIcon: Icon(Icons.location_on),
          borderColor: colorScheme.outline,
          textColor: colorScheme.onSurface,
          fontSize: 14,
          fillColor: Colors.transparent,
        ),
        const SizedBox(height: 12),

        Card(
          color: context.colorScheme.surfaceContainerHigh,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                ClipRRect(
                  child: Image.asset(Assets.images.location.path),
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  title: "URL",
                  hintText: "http://",
                  borderColor: colorScheme.outline,
                  textColor: colorScheme.onSurface,
                  fontSize: 14,
                  fillColor: Colors.transparent,
                ),

              ],
            ),
          )
        ),


      ],
    );
  }

  //--- widget for common bottom filed
  Widget _bottomField() {
    final colorScheme = context.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        _buildOrganizerToggle(),
        const SizedBox(height: 10,),

        CompanyInfoCard(
          title: "Marland Clutch",
          description:
          "Lorem Ipsum is simply dummy text of the printing and typesetting industry...",
          imagePath: Assets.images.companyLogo.path,

        ),

        const SizedBox(height: 10,),

        CustomButton(
          text: "Publish",
          backgroundColor: colorScheme.primary,
          textColor: colorScheme.onPrimary,
          onPressed: () {},

        )



      ],
    );
  }



  Widget _buildOrganizerToggle() {
    final colorScheme = context.colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Text(
            "Organizer",
            style: AppTextStyle.textSm(weight: FontWeight.w700),
          ),
          const Spacer(),
          Text(
           isPublic? "Public" :"Private",
            style: AppTextStyle.textSm(color: Colors.grey[700]),
          ),
          const SizedBox(width: 8),
          // Switch widget for the toggle shown in
          Switch(
            value: isPublic,
            onChanged: (value) {
              setState(() => isPublic = value);
            },
            activeColor: colorScheme.primary,
          ),
        ],
      ),
    );
  }




}
