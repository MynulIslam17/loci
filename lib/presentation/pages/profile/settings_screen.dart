import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get_storage/get_storage.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/presentation/widgets/custom_appbar.dart';
import 'package:loci/routes/app_routes.dart';

import '../../../core/utils/dialog_helper.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {


  // Settings data with toggle info
  final List<Map<String, dynamic>> settingsItems = [
    {
      "icon": CupertinoIcons.bell,
      "title": "Notification",
      "hasToggle": true,
      "isEnabled": false,
    },
    {
      "icon": Icons.sync,
      "title": "Theme",
      "hasToggle": true,
      "isEnabled": false,
    },
    {
      "icon": Icons.lock_outline,
      "title": "Change Password",
      "hasToggle": false,
    },
    {
      "icon": Icons.delete_outline,
      "title": "Delete Account",
      "hasToggle": false,
    },
  ];


  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    final box = GetStorage();

    // Read from storage, if null, fallback to the current GetX state
    bool currentThemeMode = box.read('isDarkMode') ?? Get.isDarkMode;

    final themeItem = settingsItems.firstWhere((item) => item["title"] == "Theme");
    themeItem["isEnabled"] = currentThemeMode;


  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return Scaffold(
      appBar: const CustomAppbar(title: "Settings"),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: settingsItems.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final item = settingsItems[index];

          // Determine toggle text (On/Off)
          String toggleText = "";
          if (item["hasToggle"] == true) {
            toggleText = item["isEnabled"] ? " (On)" : " (Off)";
          }

          return Container(
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: item["hasToggle"] == true
                    ? null
                    : () {
                        // TODO: Handle tap for non-toggle item

                        if (item["title"] == "Change Password") {
                          Get.toNamed(AppRoutes.changePassword);
                        } else {
                          Get.toNamed(AppRoutes.deleteAccount);
                        }
                      },
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  leading: Icon(
                    item["icon"],
                    color: colorScheme.onSurface,
                    size: 22,
                  ),
                  title: RichText(
                    text: TextSpan(
                      text: item["title"],
                      style: AppTextStyle.textSm(
                        color: colorScheme.onSurface,
                        weight: FontWeight.w500,
                      ),
                      children: [
                        if (item["hasToggle"] == true)
                          TextSpan(
                            text: item["isEnabled"] ? " (On)" : " (Off)",
                            style: AppTextStyle.textXs(
                              color: colorScheme.primary,
                              weight: FontWeight.w500,
                            ),
                          ),
                      ],
                    ),
                  ),
                  trailing: item["hasToggle"] == true
                      ? CupertinoSwitch(
                          value: item["isEnabled"],
                          activeColor: colorScheme.primary,
                          onChanged: (bool newValue) {
                            setState(() {
                              item["isEnabled"] = newValue;


                              // Switch theme if theme switch is selected
                              if(item["title"] == "Theme"){
                                // 1. Update the UI
                                Get.changeThemeMode(newValue ? ThemeMode.dark : ThemeMode.light);

                                // 2. Persist the choice
                                GetStorage().write('isDarkMode', newValue);
                              }




                            });
                          },
                        )
                      : Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: colorScheme.onSurfaceVariant,
                        ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
