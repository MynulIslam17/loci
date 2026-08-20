import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/core/utils/validators.dart';
import 'package:loci/features/auth/presentation/controllers/auth_controller.dart';
import 'package:loci/routes/app_routes.dart';
import 'package:loci/shared/widgets/adaptive_refresh.dart';
import 'package:loci/shared/widgets/app_skeleton.dart';
import 'package:loci/shared/widgets/custom_button.dart';
import 'package:loci/shared/widgets/custom_text_field.dart';
import 'package:loci/shared/widgets/custom_image_container.dart';
import 'package:loci/shared/widgets/app_image_picker.dart';
import 'package:loci/shared/widgets/image_viewer.dart';

import 'package:loci/features/profile/presentation/controllers/profile_controller.dart';

class ProfileScreen extends StatelessWidget {
  ProfileScreen({super.key});

  final ProfileController _controller = Get.find<ProfileController>();

  String _getInitials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return 'U';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  void _onAvatarTap(BuildContext context, ProfileController c) {
    HapticFeedback.lightImpact();
    final hasImage = c.profileImage != null ||
        (c.profileImageUrl != null && c.profileImageUrl!.trim().isNotEmpty);

    if (hasImage) {
      // Fullscreen interactive preview with pinch & zoom
      showImageViewer(
        context,
        imageFile: c.profileImage,
        imageUrl: c.profileImageUrl,
        heroTag: 'user-profile-avatar',
      );
    } else {
      // Friendly platform-adaptive sheet to add a photo when none exists
      _showAddPhotoSheet(context, c);
    }
  }

  void _showAddPhotoSheet(BuildContext context, ProfileController c) {
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;

    if (isIOS) {
      showCupertinoModalPopup<void>(
        context: context,
        builder: (ctx) => CupertinoActionSheet(
          title: const Text('Profile Photo'),
          message: const Text(
            'You haven\'t uploaded a profile picture yet. Choose a photo to personalize your profile.',
          ),
          actions: [
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.pop(ctx);
                AppImagePicker.pickOne(
                  context: context,
                  kind: ImageUploadKind.profile,
                  onSelected: c.updateImage,
                );
              },
              child: const Text('Choose Photo'),
            ),
          ],
          cancelButton: CupertinoActionSheetAction(
            isDefaultAction: true,
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
        ),
      );
    } else {
      final colors = context.colorScheme;
      showModalBottomSheet(
        context: context,
        backgroundColor: colors.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (ctx) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colors.onSurfaceVariant.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Profile Photo',
                  style: AppTextStyle.textLg(
                    weight: FontWeight.w700,
                    color: colors.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'You haven\'t uploaded a profile picture yet. Choose a photo to personalize your profile.',
                  textAlign: TextAlign.center,
                  style: AppTextStyle.textSm(
                    color: colors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 20),
                CustomButton(
                  text: 'Upload Profile Photo',
                  onPressed: () {
                    Navigator.pop(ctx);
                    AppImagePicker.pickOne(
                      context: context,
                      kind: ImageUploadKind.profile,
                      onSelected: c.updateImage,
                    );
                  },
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final authController = Get.find<AuthController>();
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Stack(
        children: [
          Obx(() {
            final c = _controller;
            final user = authController.userModel;
            final hasImage = c.profileImage != null ||
                (c.profileImageUrl != null &&
                    c.profileImageUrl!.trim().isNotEmpty);

            return AdaptiveRefresh(
              onRefresh: _controller.silentFetchProfile,
              child: SingleChildScrollView(
                physics: isIOS
                    ? const BouncingScrollPhysics(
                        parent: AlwaysScrollableScrollPhysics(),
                      )
                    : const ClampingScrollPhysics(
                        parent: AlwaysScrollableScrollPhysics(),
                      ),
                padding: EdgeInsets.fromLTRB(
                  16,
                  16,
                  16,
                  MediaQuery.paddingOf(context).bottom + 110,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 10),

                    // ── 1. Modern Profile Hero Card ────────────────────────
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            colorScheme.primary.withValues(alpha: 0.12),
                            colorScheme.surfaceContainerHigh,
                          ],
                        ),
                        border: Border.all(
                          color: colorScheme.primary.withValues(alpha: 0.2),
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // ── Avatar with Photo Preview & Fallback ──
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              GestureDetector(
                                onTap: () => _onAvatarTap(context, c),
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(
                                      colors: [
                                        colorScheme.primary,
                                        colorScheme.primary.withValues(alpha: 0.5),
                                      ],
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: colorScheme.primary
                                            .withValues(alpha: 0.25),
                                        blurRadius: 16,
                                        offset: const Offset(0, 6),
                                      ),
                                    ],
                                  ),
                                  child: Hero(
                                    tag: 'user-profile-avatar',
                                    child: hasImage
                                        ? CustomCachedImage(
                                            imageFile: c.profileImage,
                                            imageUrl: c.profileImageUrl,
                                            cacheKey: c.profileImageUrl == null
                                                ? null
                                                : '${c.profileImageUrl}-${c.avatarRevision}',
                                            height: 110,
                                            width: 110,
                                            isCircle: true,
                                          )
                                        : Container(
                                            height: 110,
                                            width: 110,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              gradient: LinearGradient(
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                                colors: [
                                                  colorScheme.primary,
                                                  colorScheme.primaryContainer,
                                                ],
                                              ),
                                            ),
                                            alignment: Alignment.center,
                                            child: Text(
                                              _getInitials(c.userName),
                                              style: TextStyle(
                                                fontSize: 32,
                                                fontWeight: FontWeight.w800,
                                                color: colorScheme.onPrimary,
                                              ),
                                            ),
                                          ),
                                  ),
                                ),
                              ),

                              // ── Camera Edit Button ──
                              Positioned(
                                right: 0,
                                bottom: 2,
                                child: Material(
                                  color: colorScheme.primary,
                                  shape: const CircleBorder(),
                                  elevation: 3,
                                  child: InkWell(
                                    onTap: () => AppImagePicker.pickOne(
                                      context: context,
                                      kind: ImageUploadKind.profile,
                                      onSelected: c.updateImage,
                                    ),
                                    customBorder: const CircleBorder(),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8),
                                      child: Icon(
                                        Icons.camera_alt_rounded,
                                        size: 18,
                                        color: colorScheme.onPrimary,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 14),

                          // ── User Name & Quick Edit ──
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Flexible(
                                child: Text(
                                  c.userName.isNotEmpty ? c.userName : 'Loci User',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                  style: AppTextStyle.textXl(
                                    color: colorScheme.onSurface,
                                    weight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              _editButton(
                                onTap: () => _showEditBottomSheet(
                                  context: context,
                                  title: "Edit Name",
                                  hintText: "Enter your full name",
                                  initialValue: c.userName,
                                  onSave: c.updateName,
                                  validator: validateFullName,
                                  isNameField: true,
                                ),
                              ),
                            ],
                          ),

                          // ── Email ──
                          if ((user?.email ?? '').isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              user?.email ?? '',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyle.textSm(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],

                          const SizedBox(height: 10),

                          // ── Role & Member Since Badges ──
                          Wrap(
                            alignment: WrapAlignment.center,
                            spacing: 8,
                            runSpacing: 6,
                            children: [
                              if (user?.role != null)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 3.5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: colorScheme.primary
                                        .withValues(alpha: 0.14),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: colorScheme.primary
                                          .withValues(alpha: 0.3),
                                      width: 0.8,
                                    ),
                                  ),
                                  child: Text(
                                    user!.role == 'business_owner'
                                        ? 'Business Owner'
                                        : (user.role == 'admin'
                                            ? 'Admin'
                                            : 'Member'),
                                    style: AppTextStyle.textXs(
                                      color: colorScheme.primary,
                                      weight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              if (c.memberSince.isNotEmpty)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 3.5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: colorScheme.surfaceContainerHighest,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    "Joined ${c.memberSince}",
                                    style: AppTextStyle.textXs(
                                      color: colorScheme.onSurfaceVariant,
                                      weight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ── 2. Achievements & Activity Section ────────────────
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Progress & Achievements",
                        style: AppTextStyle.textMd(
                          weight: FontWeight.w700,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        _buildStatCard(
                          title: "Events",
                          icon: "assets/icons/calander.svg",
                          value: c.stats?.eventsCheckedIn,
                          accentColor: const Color(0xFFFF8C42),
                          colorScheme: colorScheme,
                        ),
                        const SizedBox(width: 8),
                        _buildStatCard(
                          title: "Routes",
                          icon: "assets/icons/map.svg",
                          value: c.stats?.routesCheckedIn,
                          accentColor: const Color(0xFF2EC4B6),
                          colorScheme: colorScheme,
                        ),
                        const SizedBox(width: 8),
                        _buildStatCard(
                          title: "Raffles",
                          icon: "assets/icons/rafel.svg",
                          value: c.stats?.rafflesWon,
                          accentColor: const Color(0xFF7F77DD),
                          colorScheme: colorScheme,
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // ── 3. About Section (Soft Readable Bio Color) ─────────
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: colorScheme.outlineVariant.withValues(alpha: 0.4),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "About Me",
                                style: AppTextStyle.textMd(
                                  weight: FontWeight.w700,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                              _editButton(
                                onTap: () => _showEditBottomSheet(
                                  context: context,
                                  title: "Edit About Me",
                                  hintText: "Tell others a little about yourself...",
                                  initialValue: c.about,
                                  maxLines: 4,
                                  onSave: c.updateAbout,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            c.about.isNotEmpty
                                ? c.about
                                : "No bio added yet. Tap the edit button to add a short bio about yourself.",
                            style: AppTextStyle.textSm(
                              color: c.about.isNotEmpty
                                  ? colorScheme.onSurfaceVariant.withValues(alpha: 0.88)
                                  : colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                              height: 1.55,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ── 4. Quick Account Shortcuts ─────────────────────────
                    Container(
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: colorScheme.outlineVariant.withValues(alpha: 0.4),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          _buildAccountTile(
                            context: context,
                            title: 'My QR-Code',
                            icon: Icons.qr_code_rounded,
                            onTap: () => Get.toNamed(AppRoutes.myQrCode),
                          ),
                          const Divider(height: 1, indent: 56),
                          _buildAccountTile(
                            context: context,
                            title: 'Settings & Security',
                            icon: Icons.settings_outlined,
                            onTap: () => Get.toNamed(AppRoutes.settings),
                          ),
                          const Divider(height: 1, indent: 56),
                          _buildAccountTile(
                            context: context,
                            title: 'Terms & Conditions',
                            icon: Icons.description_outlined,
                            onTap: () => Get.toNamed(AppRoutes.terms),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),

          // ── Center Loading Overlay ──
          Obx(() {
            if (!_controller.isLoading) return const SizedBox.shrink();
            return SizedBox.expand(
              child: AbsorbPointer(
                child: ColoredBox(
                  color: Colors.black.withValues(alpha: 0.35),
                  child: const Center(child: CircularProgressIndicator()),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  // ── Stat Card Component ──
  Widget _buildStatCard({
    required String title,
    required String icon,
    required int? value,
    required Color accentColor,
    required ColorScheme colorScheme,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: accentColor.withValues(alpha: 0.25),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: SvgPicture.asset(
                icon,
                width: 20,
                height: 20,
                colorFilter: ColorFilter.mode(accentColor, BlendMode.srcIn),
              ),
            ),
            const SizedBox(height: 8),
            value == null
                ? AppSkeleton.box(width: 24, height: 16)
                : Text(
                    '$value',
                    style: AppTextStyle.textLg(
                      weight: FontWeight.w800,
                      color: colorScheme.onSurface,
                    ),
                  ),
            const SizedBox(height: 2),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyle.textXs(
                color: colorScheme.onSurfaceVariant,
                weight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Account Shortcut Tile ──
  Widget _buildAccountTile({
    required BuildContext context,
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final colors = context.colorScheme;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 20, color: colors.primary),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyle.textSm(
                    weight: FontWeight.w600,
                    color: colors.onSurface,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: colors.onSurfaceVariant.withValues(alpha: 0.4),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Edit Button Component ──
  Widget _editButton({
    required VoidCallback onTap,
    IconData icon = Icons.edit_outlined,
  }) {
    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(icon, size: 18),
        ),
      ),
    );
  }

  // ── Platform-Adaptive Bottom Sheet for Editing Name / About ──
  void _showEditBottomSheet({
    required BuildContext context,
    required String title,
    required String initialValue,
    required Function(String) onSave,
    String? hintText,
    int maxLines = 1,
    String? Function(String?)? validator,
    bool isNameField = false,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _EditFieldSheet(
        title: title,
        hintText: hintText,
        initialValue: initialValue,
        maxLines: maxLines,
        onSave: onSave,
        validator: validator,
        isNameField: isNameField,
      ),
    );
  }
}

class _EditFieldSheet extends StatefulWidget {
  final String title;
  final String? hintText;
  final String initialValue;
  final int maxLines;
  final Function(String) onSave;
  final String? Function(String?)? validator;
  final bool isNameField;

  const _EditFieldSheet({
    required this.title,
    required this.hintText,
    required this.initialValue,
    required this.maxLines,
    required this.onSave,
    this.validator,
    this.isNameField = false,
  });

  @override
  State<_EditFieldSheet> createState() => _EditFieldSheetState();
}

class _EditFieldSheetState extends State<_EditFieldSheet> {
  late final TextEditingController _textController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _onSave() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final value = _textController.text.trim();
    if (value != widget.initialValue) {
      widget.onSave(value);
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        left: 20,
        right: 20,
        top: 16,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colors.onSurfaceVariant.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              widget.title,
              style: AppTextStyle.textLg(
                weight: FontWeight.w700,
                color: colors.onSurface,
              ),
            ),
            const SizedBox(height: 14),
            CustomTextField(
              controller: _textController,
              maxLine: widget.maxLines,
              hintText: widget.hintText,
              keyboardType: widget.isNameField
                  ? TextInputType.name
                  : TextInputType.text,
              textCapitalization: widget.isNameField
                  ? TextCapitalization.words
                  : TextCapitalization.sentences,
              inputFormatters: widget.isNameField ? nameInputFormatters : null,
              validator: widget.validator,
            ),
            const SizedBox(height: 20),
            CustomButton(text: "Save Changes", onPressed: _onSave),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
