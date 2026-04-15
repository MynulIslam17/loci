import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loci/core/enums/category_enum.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/presentation/controllers/my_business/my_business_profile_controller.dart';
import 'package:loci/presentation/widgets/custom_button.dart';
import 'package:loci/presentation/pages/clam_business/widgets/review_card.dart';
import 'package:loci/presentation/widgets/custom_text_field.dart';
import 'package:loci/routes/app_routes.dart';
import '../../../core/constants/app_text_style.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/busniess/business_profile_model.dart';
import '../../widgets/custom_appbar.dart';
import '../../widgets/custom_image_container.dart';
import '../home/widgets/post_input_filed.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

class MyBusinessProfile extends StatefulWidget {
  const MyBusinessProfile({super.key});

  @override
  State<MyBusinessProfile> createState() => _MyBusinessProfileState();
}

class _MyBusinessProfileState extends State<MyBusinessProfile> {
  File? _profileImage;
  final List<File> _photos = [];

  final GlobalKey<FormState> _businessFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _descriptionFormKey = GlobalKey<FormState>();

  late final String businessId;

  final profileController = Get.find<MyBusinessProfileController>();



  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    final args = Get.arguments;
    businessId = (args is Map && args['businessId'] != null)
        ? args['businessId']
        : '';

    profileController.fetchBusinessProfile(businessId);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: CustomAppbar(title: "Business profile"),
      body: RefreshIndicator(
        onRefresh: () async {
         await profileController.refreshBusinessProfile(businessId);
        },
        child: GetBuilder<MyBusinessProfileController>(
          builder: (controller) {
            if (controller.isLoading) {
              return Center(child: CircularProgressIndicator());
            }

            if (controller.errorMessage != null) {
              return Center(child: Text(controller.errorMessage!));
            }

            if (!controller.isLoading && controller.business == null) {
              return const Center(child: Text("No business found"));
            }


            final business = controller.business!;



            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _buildProfileHeader(business),
                  const SizedBox(height: 20),
                  _buildDescriptionCard(context,business),
                  const SizedBox(height: 25),
                  _buildSectionHeader("Photos"),
                  _buildPhotoGrid(business),
                  const SizedBox(height: 10),

                  if (_photos.isNotEmpty) Align(
                      alignment: Alignment.topRight,
                      child: _buildUploadButton()),
                  const SizedBox(height: 20),

                  _buildSectionHeader("Advertisements"),
                  _buildPollCreator(),
                  const SizedBox(height: 12),
                  CustomButton(
                    text: "Explore Activities",
                    backgroundColor: colorScheme.primary,
                    onPressed: () {
                      //TODO --go to explore activity
                      Get.toNamed(
                        AppRoutes.exploreActivity,
                        arguments: {"businessId": businessId},
                      );
                    },
                    textStyle: AppTextStyle.textSm(
                      weight: FontWeight.w600,
                      color: colorScheme.onPrimary,
                    ),
                  ),
                  const SizedBox(height: 25),
                  _buildSectionHeader("Hero Ads"),
                  _buildHeroAd(),
                  const SizedBox(height: 12),
                  CustomButton(
                    backgroundColor: colorScheme.primary,
                    onPressed: () {
                      Get.toNamed(AppRoutes.createAdd);
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add, color: colorScheme.onPrimary, size: 20),
                        const SizedBox(width: 4),
                        Text(
                          "Create New Ads",
                          style: AppTextStyle.textSm(
                            weight: FontWeight.w600,
                            color: colorScheme.onPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 25),
                  _buildSectionHeader(
                    "Reviews",
                    showViewAll: true,
                    onTap: () {},
                  ),
                  _buildReviewsList(),
                  const SizedBox(height: 50),
                ],
              ),
            );
          },
        ),

      ),
    );
  }

  // ================= PROFILE HEADER =================
  Widget _buildProfileHeader(BusinessModel business) {
    final colorScheme = context.colorScheme;

    final owner = business.owner;
    final address = business.address;

    return Column(
      children: [
        const SizedBox(height: 10),

        // ================= PROFILE IMAGE =================
        Stack(
          children: [
            Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: colorScheme.primary),
              ),
              child: CustomCachedImage(
                imageFile: _profileImage,
                imageUrl: owner.avatar,
                height: 110,
                width: 110,
                isCircle: true,
              ),
            ),

            Positioned(
              right: 0,
              top: 0,
              child: _editCircleButton(onTap: () {}),
            ),
          ],
        ),

        const SizedBox(height: 15),

        // ================= BUSINESS INFO CARD =================
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Padding(

                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // NAME
                    Text(
                      business.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: AppTextStyle.textXl(
                        color: colorScheme.primary,
                        weight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),

                    // ADDRESS
                    Text(
                      "${address.street}, ${address.city}, ${address.state}, ${address.country}",
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: AppTextStyle.textXs(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 6),

                    Text(
                      business.phone,
                      style: AppTextStyle.textXs(
                        color: colorScheme.primary,
                        weight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 6),

                    Text(
                      business.category,
                      style: AppTextStyle.textXs(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),

              // EDIT BUTTON ================
              Positioned(
                top: 0,
                right: 0,
                child: _editCircleButton(onTap:()=>_showEditBusinessBottomSheet(business)),
              ),
            ],
          ),
        ),

        const SizedBox(height: 10),

        // ================= REVIEW SECTION (FIXED) =================
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "${business.reviewCount} reviews",
              style: AppTextStyle.textXs(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: 6),

           //review count
            Row(
              children: List.generate(
                5,
                    (index) => const Icon(
                  Icons.star,
                  color: AppColors.starColor,
                  size: 16,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 15),

        // ================= CHIPS =================
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            customChip(
              label: "Community",
              onTap: () {},
              backgroundColor: colorScheme.primary,
            ),
            const SizedBox(width: 12),
            customChip(
              label: "QR",
              icon: Icons.qr_code,
              onTap: () {},
              backgroundColor: colorScheme.primary,
            ),
          ],
        ),

        const SizedBox(height: 12),

        // ================= BUTTON =================
        OutlinedButton(
          onPressed: () {},
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: colorScheme.outline),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 40),
          ),
          child: Text(
            "Change Subscription",
            style: AppTextStyle.textSm(
              color: colorScheme.primary,
              weight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  // ================= DESCRIPTION CARD =================
  Widget _buildDescriptionCard(BuildContext context, BusinessModel business) {
    final colorScheme = context.colorScheme;

    return SizedBox(
      width: double.infinity,
      child: Card(
        color: colorScheme.surfaceContainerHigh,
        elevation: 2,
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // TEXT CONTENT
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  business.description ,
                  textAlign: TextAlign.center,
                  style: AppTextStyle.textXs(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),

              // EDIT BUTTON
              Positioned(
                right: 0,
                top: 0,
                child: _editCircleButton(onTap: ()=>_showEditDescriptionBottomSheet(business),size: 20),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= PHOTO GRID =================
  Widget _buildPhotoGrid(BusinessModel business) {
    final _apiPhotos=business.photos ;
    final int totalImages = _apiPhotos.length + _photos.length;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.3,
      ),
      itemCount: totalImages + 1,
      itemBuilder: (context, index) {
        if (index == totalImages) return _buildAddPhotoButton();

        if (index < _apiPhotos.length) {
          return Stack(
            children: [
              CustomCachedImage(
                imageUrl: _apiPhotos[index],
                width: double.infinity,
                height: double.infinity,
              ),
              Positioned(
                right: 5,
                top: 5,
                child: _editCircleButton(
                  onTap: () {
                    setState(() => _apiPhotos.removeAt(index));
                  },
                  size: 20,
                  icon: Icons.cancel,
                  iconColor: AppColors.danger,
                ),
              ),
            ],
          );
        }

        final localIndex = index - _apiPhotos.length;
        return Stack(
          children: [
            CustomCachedImage(
              imageFile: _photos[localIndex],
              width: double.infinity,
              height: double.infinity,
            ),
            Positioned(
              right: 5,
              top: 5,
              child: _editCircleButton(
                onTap: () {
                  setState(() => _photos.removeAt(localIndex));
                },
                size: 20,
                icon: Icons.cancel,
                iconColor: AppColors.danger,
              ),
            ),
          ],
        );
      },
    );
  }

  // ================= HERO AD =================
  Widget _buildHeroAd() {
    final colorScheme = context.colorScheme;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
      child: Column(
        children: [
          Stack(
            children: [
              // Background Image
              CustomCachedImage(
                width: double.infinity,
                height: 200,
                imageUrl: "https://picsum.photos/seed/1/400/300",
              ),

              // Text Content
              Positioned(
                left: 16,
                bottom: 16,
                right: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Barclay Prime",
                      style: AppTextStyle.textMd(
                        color: AppColors.base50,
                        weight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          color: colorScheme.primary,
                          size: 18,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            "237 S 18th St, Philadelphia, PA 19103",
                            style: AppTextStyle.textXs(
                              color: AppColors.base50,
                              weight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Ads Info
          Padding(
            padding: const EdgeInsets.only(top: 8.0, left: 4.0, right: 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Ads will run February 2, 2026",
                  style: AppTextStyle.textXs(
                    color: colorScheme.onSurfaceVariant,
                    weight: FontWeight.w400,
                  ),
                ),
                Text(
                  "Credit remain: 10",
                  style: AppTextStyle.textXs(
                    color: colorScheme.onSurfaceVariant,
                    weight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ================= POLL CREATOR =================
  Widget _buildPollCreator() {
    final colorScheme = context.colorScheme;

    return Card(
      color: colorScheme.surfaceContainerHigh,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Create a poll",
              style: AppTextStyle.textMd(
                color: colorScheme.onSurface,
                weight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            PostInputField(
              categories: ['Foodie', 'Drinks', 'Restu'],
              initialCategory: 'Foodie',
              hintText: 'Ask anything',
              onSubmit: (text, category) {
                print("Posting: $text in $category");
              },
            ),
          ],
        ),
      ),
    );
  }

  // ================= REVIEWS LIST =================
  Widget _buildReviewsList() {
    return Column(
      children: List.generate(
        2,
        (index) => ReviewCard(
          name: "Alexandra ssssBroke",
          businessName: "Barclay Pizza",
          rating: 5,
          reviewText: "This was one of the most epic experience...",
          imageUrl: "https://i.pravatar.cc/150?u=1",
          onMenuTap: () {},
        ),
      ),
    );
  }

  Widget _buildUploadButton() {
    return CustomButton(
      width: 120,
      height: 50,
      child: Text("Upload"),
      onPressed: (){},
    );
  }

  // ================= PHOTO PICKER =================
  Widget _buildAddPhotoButton() {
    return GestureDetector(
      onTap: () =>
          _showSimplePicker((file) => setState(() => _photos.add(file))),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade400,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.image_outlined, color: Colors.white, size: 28),
            SizedBox(height: 4),
            Text(
              "Add image",
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= CUSTOM CHIP =================
  Widget customChip({
    required String label,
    IconData? icon,
    VoidCallback? onTap,
    Color? backgroundColor,
  }) {
    return ActionChip(
      onPressed: onTap,
      backgroundColor: backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: const BorderSide(color: Colors.transparent),
      ),
      avatar: icon != null ? Icon(icon, size: 18, color: Colors.white) : null,
      label: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  // ================= SECTION HEADER =================
  Widget _buildSectionHeader(
    String title, {
    bool showViewAll = false,
    VoidCallback? onTap,
  }) {
    final colorScheme = context.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: AppTextStyle.textXl(
              color: colorScheme.primary,
              weight: FontWeight.w600,
            ),
          ),
          if (showViewAll)
            TextButton(
              onPressed: onTap,
              child: Text(
                "View all",
                style: AppTextStyle.textXs(color: colorScheme.primary),
              ),
            ),
        ],
      ),
    );
  }

  // ================= EDIT CIRCLE BUTTON =================
  Widget _editCircleButton({
    required VoidCallback onTap,
    double size = 26,
    IconData icon = Icons.edit_outlined,
    Color iconColor = AppColors.primaryG700,
  }) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Icon(icon, size: size * 0.7, color: iconColor),
        ),
      ),
    );
  }

  // ================= IMAGE PICKER =================
  void _showSimplePicker(Function(File) onSelected) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
      ),
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () async {
                final picked = await ImagePicker().pickImage(
                  source: ImageSource.gallery,
                );
                if (picked != null) onSelected(File(picked.path));
                if (context.mounted) Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () async {
                final picked = await ImagePicker().pickImage(
                  source: ImageSource.camera,
                );
                if (picked != null) onSelected(File(picked.path));
                if (context.mounted) Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }


  void _showEditBusinessBottomSheet(BusinessModel business) {
    final nameController = TextEditingController(text: business.name);
    final streetController =
    TextEditingController(text: business.address.street);
    final cityController =
    TextEditingController(text: business.address.city);
    final stateController =
    TextEditingController(text: business.address.state);
    final countryController =
    TextEditingController(text: business.address.country);

    BusinessCategory selectedCategory =
    BusinessCategory.fromString(business.category);

    String phoneNumber = business.phone;

    final colorScheme = context.colorScheme;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 16,
                right: 16,
                top: 20,
              ),
              child: SingleChildScrollView(
                child: Form(
                  key: _businessFormKey ,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ================= TITLE =================
                      Center(
                        child: Text(
                          "Edit Business Info",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.primary,
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // ================= NAME =================
                      TextFormField(
                        controller: nameController,
                        decoration: InputDecoration(
                          labelText: "Business Name",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return "Name is required";
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 12),

                      // ================= PHONE =================
                      IntlPhoneField(
                        initialValue: business.phone,
                        initialCountryCode: 'US',
                        decoration: InputDecoration(
                          labelText: "Phone Number",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onChanged: (phone) {
                          phoneNumber = phone.completeNumber;
                        },
                        validator: (phone) {
                          if (phone == null || phone.number.isEmpty) {
                            return "Phone is required";
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 12),

                      // ================= STREET =================
                      TextFormField(
                        controller: streetController,
                        decoration: InputDecoration(
                          labelText: "Street",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      // ================= CITY =================
                      TextFormField(
                        controller: cityController,
                        decoration: InputDecoration(
                          labelText: "City",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      // ================= STATE =================
                      TextFormField(
                        controller: stateController,
                        decoration: InputDecoration(
                          labelText: "State",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      // ================= COUNTRY =================
                      TextFormField(
                        controller: countryController,
                        decoration: InputDecoration(
                          labelText: "Country",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // ================= CATEGORY =================
                      DropdownButtonFormField<BusinessCategory>(
                        value: selectedCategory,
                        decoration: InputDecoration(
                          labelText: "Category",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        items: BusinessCategory.values.map((category) {
                          return DropdownMenuItem(
                            value: category,
                            child: Text(category.label),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedCategory = value!;
                          });
                        },
                        validator: (value) {
                          if (value == null) {
                            return "Category required";
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 20),

                      // ================= BUTTON =================
                      SizedBox(
                        width: double.infinity,
                        child: CustomButton(
                          text: "Update",
                          onPressed: () {
                            if (_businessFormKey .currentState!.validate()) {
                              final updatedData = {
                                "name": nameController.text,
                                "phone": phoneNumber,
                                "category": selectedCategory.toJson,
                                "address": {
                                  "street": streetController.text,
                                  "city": cityController.text,
                                  "state": stateController.text,
                                  "country": countryController.text,
                                }
                              };

                              Navigator.pop(context);
                            }
                          },
                        ),
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }


  void _showEditDescriptionBottomSheet(BusinessModel business) {
    final descriptionController =
    TextEditingController(text: business.description);

    final colorScheme = context.colorScheme;


    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 16,
                right: 16,
                top: 20,
              ),
              child: SingleChildScrollView(
                child: Form(
                  key: _descriptionFormKey ,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ================= TITLE =================
                      Center(
                        child: Text(
                          "Edit Description",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.primary,
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // ================= DESCRIPTION FIELD =================
                      CustomTextField(
                        controller: descriptionController,
                        hintText: "Description",
                        maxLine: 3,
                        borderRadius: 10,
                        borderColor: colorScheme.outline,
                        validator: (value){
                          if( value==null||value.isEmpty){
                            return "Description is required";
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 20),

                      // ================= UPDATE BUTTON =================
                      SizedBox(
                        width: double.infinity,
                        child: CustomButton(
                          text: "Update Description",
                          onPressed: () {
                            if (_descriptionFormKey .currentState!.validate()) {
                              final updatedData = {
                                "description": descriptionController.text.trim(),
                              };

                              profileController.updateBusinessData(businessId: businessId, body: updatedData);


                            }
                          },
                        ),
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }



}
