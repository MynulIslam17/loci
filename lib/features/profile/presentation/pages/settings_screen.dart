import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/shared/widgets/custom_appbar.dart';
import 'package:loci/routes/app_routes.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final RxBool _themeEnabled;
  static const _settingsItems = [
    _SettingsItem(icon: Icons.sync, title: "Theme", hasToggle: true),
    _SettingsItem(
      icon: Icons.workspace_premium_outlined,
      title: "My Subscription",
      hasToggle: false,
    ),
    _SettingsItem(
      icon: Icons.lock_outline,
      title: "Change Password",
      hasToggle: false,
    ),
    _SettingsItem(
      icon: Icons.delete_outline,
      title: "Delete Account",
      hasToggle: false,
    ),
  ];

  @override
  void initState() {
    super.initState();
    final box = GetStorage();
    // Type the read as bool — an untyped read returns `dynamic`, which makes
    // the `.obs` extension getter fail at runtime (it can't dispatch on dynamic).
    _themeEnabled = (box.read<bool>('isDarkMode') ?? Get.isDarkMode).obs;
  }

  bool _isToggleEnabled(String title) {
    switch (title) {
      case 'Theme':
        return _themeEnabled.value;
      default:
        return false;
    }
  }

  void _onItemTap(String title) {
    switch (title) {
      case "My Subscription":
        Get.toNamed(AppRoutes.mySubscription);
        break;
      case "Change Password":
        Get.toNamed(AppRoutes.changePassword);
        break;
      case "Delete Account":
        Get.toNamed(AppRoutes.deleteAccount);
        break;
    }
  }

  void _onToggleChanged(String title, bool newValue) {
    switch (title) {
      case 'Theme':
        _themeEnabled.value = newValue;
        Get.changeThemeMode(newValue ? ThemeMode.dark : ThemeMode.light);
        GetStorage().write('isDarkMode', newValue);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return Scaffold(
      appBar: const CustomAppbar(title: "Settings"),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _settingsItems.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final item = _settingsItems[index];

          // Only toggle rows read an observable, so only those are wrapped in
          // Obx. Wrapping a non-toggle row would give Obx nothing to observe
          // and throw "improper use of GetX".
          if (!item.hasToggle) {
            return _buildTile(colorScheme, item, enabled: false);
          }
          return Obx(
            () => _buildTile(
              colorScheme,
              item,
              enabled: _isToggleEnabled(item.title),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTile(
    ColorScheme colorScheme,
    _SettingsItem item, {
    required bool enabled,
  }) {
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
          onTap: item.hasToggle ? null : () => _onItemTap(item.title),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 4,
            ),
            leading: Icon(item.icon, color: colorScheme.onSurface, size: 22),
            title: RichText(
              text: TextSpan(
                text: item.title,
                style: AppTextStyle.textSm(
                  color: colorScheme.onSurface,
                  weight: FontWeight.w500,
                ),
                children: [
                  if (item.hasToggle)
                    TextSpan(
                      text: enabled ? " (On)" : " (Off)",
                      style: AppTextStyle.textXs(
                        color: colorScheme.primary,
                        weight: FontWeight.w500,
                      ),
                    ),
                ],
              ),
            ),
            trailing: item.hasToggle
                ? CupertinoSwitch(
                    value: enabled,
                    activeTrackColor: colorScheme.primary,
                    onChanged: (bool newValue) {
                      _onToggleChanged(item.title, newValue);
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
  }
}

class _SettingsItem {
  final IconData icon;
  final String title;
  final bool hasToggle;

  const _SettingsItem({
    required this.icon,
    required this.title,
    required this.hasToggle,
  });
}
