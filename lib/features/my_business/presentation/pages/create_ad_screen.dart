import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/core/utils/show_snackbar.dart';
import 'package:loci/features/my_business/presentation/controllers/create_ad_controller.dart';
import 'package:loci/features/my_business/presentation/widgets/create_ad_form.dart';
import 'package:loci/shared/widgets/adaptive_pickers.dart';
import 'package:loci/shared/widgets/custom_appbar.dart';
import 'package:loci/shared/widgets/custom_button.dart';

class CreateAd extends StatefulWidget {
  const CreateAd({super.key});

  @override
  State<CreateAd> createState() => _CreateAdState();
}

class _CreateAdState extends State<CreateAd> {
  final CreateAdController _controller = Get.find<CreateAdController>();

  Future<void> _pickDate({required bool isStart}) async {
    final picked = await showAdaptiveDatePicker(
      context: context,
      initialDate: _controller.initialDateForPicker(isStart: isStart),
      firstDate: _controller.firstDateForPicker(isStart: isStart),
      lastDate: DateTime(2050),
    );
    if (picked == null) return;
    _controller.applyPickedDate(picked, isStart: isStart);
  }

  Future<void> _pickTime({required bool isStart}) async {
    final picked = await showAdaptiveTimePicker(
      context: context,
      initialTime: _controller.initialTimeForPicker(isStart: isStart),
    );
    if (picked == null || !mounted) return;
    _controller.applyPickedTime(picked, context, isStart: isStart);
  }

  Future<void> _submit() async {
    final success = await _controller.submit();
    if (!mounted) return;

    if (!success) {
      final error = _controller.errorMessage.value;
      if (error != null) SnackbarService.error(error);
      return;
    }

    Get.back(result: true);
    SnackbarService.success(
      _controller.successMessage.value ??
          'Ad submitted for review — status is pending until approved',
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: const CustomAppbar(title: 'Create Ads'),
      body: Form(
        key: _controller.formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            Text(
              'Ad details',
              style: AppTextStyle.textXl(
                weight: FontWeight.w700,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Promo, schedule, banner — then review.',
              style: AppTextStyle.textXs(color: colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 20),
            CreateAdForm(
              controller: _controller,
              onPickDate: _pickDate,
              onPickTime: _pickTime,
            ),
            const SizedBox(height: 28),
            Obx(
              () => CustomButton(
                isLoading: _controller.isLoading.value,
                onPressed: _controller.isLoading.value ? null : _submit,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Continue',
                      style: AppTextStyle.textMd(
                        weight: FontWeight.w600,
                        color: colorScheme.onPrimary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.arrow_forward,
                      color: colorScheme.onPrimary,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
