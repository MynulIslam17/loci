import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loci/presentation/controllers/my_business/my_business_profile_controller.dart';
import 'package:loci/presentation/widgets/custom_button.dart';

class ProfileBottomSheet {
  static void show({
    required String title,
    required GlobalKey<FormState> formKey,
    required Widget child,
    required Future<void> Function() onSubmit,
  }) {
    final colorScheme = Get.context!.theme.colorScheme;

    showModalBottomSheet(
      context: Get.context!,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 20,
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),

                const SizedBox(height: 20),

                child,

                const SizedBox(height: 20),

                GetBuilder<MyBusinessProfileController>(
                  builder: (controller) {
                    return CustomButton(
                      isLoading: controller.isUpdating,
                      text: "Update",
                      onPressed: () async {
                        if (formKey.currentState!.validate()) {
                          Get.back(); // close sheet
                          await onSubmit();

                        }
                      },
                    );
                  },
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }
}