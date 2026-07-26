import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loci/core/utils/show_snackbar.dart';
import 'package:loci/features/network/presentation/controllers/send_new_referrals_controller.dart';
import 'package:loci/shared/widgets/custom_text_field.dart';
import 'package:loci/shared/widgets/custom_button.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/core/utils/validators.dart';
import 'package:loci/features/network/presentation/controllers/sent_referrals_controller.dart';

class SendNewReferralsScreen extends StatefulWidget {
  const SendNewReferralsScreen({super.key});

  @override
  State<SendNewReferralsScreen> createState() => _SendNewReferralsScreenState();
}

class _SendNewReferralsScreenState extends State<SendNewReferralsScreen> {
  final _formKey = GlobalKey<FormState>();
  late final SendNewReferralsController _controller;

  final _recipientNameController = TextEditingController();
  final _recipientEmailController = TextEditingController();
  final _recipientCompanyController = TextEditingController();
  final _ownerNameController = TextEditingController();
  final _ownerEmailController = TextEditingController();
  final _messageController = TextEditingController();
  final _ownerCompanyName = TextEditingController();

  static const int _messageMaxLength = 300;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<SendNewReferralsController>();
  }

  @override
  void dispose() {
    _recipientNameController.dispose();
    _recipientEmailController.dispose();
    _recipientCompanyController.dispose();
    _ownerNameController.dispose();
    _ownerEmailController.dispose();
    _messageController.dispose();
    _ownerCompanyName.dispose();
    Get.delete<SendNewReferralsController>();
    super.dispose();
  }

  Future<void> _onSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await _controller.sendReferral(
      recipientEmail: _recipientEmailController.text.trim(),
      recipientName: _recipientNameController.text.trim(),
      recipientCompany: _recipientCompanyController.text.trim(),
      businessOwnerEmail: _ownerEmailController.text.trim(),
      businessOwnerName: _ownerNameController.text.trim(),
      ownerCompanyName: _ownerCompanyName.text.trim(),
      message: _messageController.text.trim(),
    );

    if (success) {
      Get.find<SentReferralsController>().fetchSentReferrals();
    } else {
      SnackbarService.error(
        _controller.errorMessage ?? "Failed to send referral",
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        leading: const BackButton(),
        title: Text(
          "Send New Referral",
          style: AppTextStyle.textMd(weight: FontWeight.w600),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 24),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: colorScheme.outline.withOpacity(0.2),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // --- Recipient details ---
                      _buildSectionLabel("Recipient details"),
                      const SizedBox(height: 12),
                      _buildField(
                        hint: "Enter recipient's full name",
                        controller: _recipientNameController,
                        validator: validateFirstName,
                      ),
                      const SizedBox(height: 12),
                      _buildField(
                        hint: "Enter recipient's email",
                        controller: _recipientEmailController,
                        keyboardType: TextInputType.emailAddress,
                        validator: validateEmail,
                      ),
                      const SizedBox(height: 12),
                      _buildField(
                        hint: "Enter recipient's company",
                        controller: _recipientCompanyController,
                        validator: (v) =>
                            validateRequired(v, fieldName: "Company"),
                      ),
                      const SizedBox(height: 20),

                      // --- Business owner ---
                      _buildSectionLabel("Business owner"),
                      const SizedBox(height: 12),
                      _buildField(
                        hint: "Enter owner's name",
                        controller: _ownerNameController,
                        validator: validateFirstName,
                      ),
                      const SizedBox(height: 12),
                      _buildField(
                        hint: "Enter owner's email",
                        controller: _ownerEmailController,
                        keyboardType: TextInputType.emailAddress,
                        validator: validateEmail,
                      ),
                      const SizedBox(height: 12),

                      _buildField(
                        hint: "Enter owner's Company",
                        controller: _ownerCompanyName,
                        validator: (v) =>
                            validateRequired(v, fieldName: "Company"),
                      ),

                      const SizedBox(height: 20),

                      // --- Message ---
                      _buildSectionLabel("Message", optional: true),
                      const SizedBox(height: 12),
                      _buildField(
                        hint: "You should connect with James!",
                        controller: _messageController,
                        maxLines: 4,
                        maxLength: _messageMaxLength,
                        validator: (v) => validateMaxLength(
                          v,
                          _messageMaxLength,
                          fieldName: "Message",
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                Obx(() {
                  final ctrl = Get.find<SendNewReferralsController>();
                  return CustomButton(
                    backgroundColor: colorScheme.primary,
                    onPressed: ctrl.isLoading ? null : _onSubmit,
                    child: ctrl.isLoading
                        ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: colorScheme.onPrimary,
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Send Referral",
                                style: AppTextStyle.textMd(
                                  color: colorScheme.onPrimary,
                                  weight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                Icons.send_outlined,
                                color: colorScheme.onPrimary,
                                size: 18,
                              ),
                            ],
                          ),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Referrals", style: AppTextStyle.textXl(weight: FontWeight.w700)),
        const SizedBox(height: 4),
        Text(
          "Recommend people to business owner",
          style: AppTextStyle.textSm(
            color: context.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionLabel(String label, {bool optional = false}) {
    return RichText(
      text: TextSpan(
        text: label,
        style: AppTextStyle.textSm(
          color: context.colorScheme.onSurface,
          weight: FontWeight.w600,
        ),
        children: [
          if (optional)
            TextSpan(
              text: " (optional)",
              style: AppTextStyle.textSm(
                color: context.colorScheme.onSurfaceVariant,
                weight: FontWeight.w400,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildField({
    required String hint,
    required TextEditingController controller,
    int maxLines = 1,
    int? maxLength,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return CustomTextField(
      controller: controller,
      hintText: hint,
      maxLine: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      hintTextColor: context.colorScheme.onSurfaceVariant,
      borderColor: context.colorScheme.outline,
      textColor: context.colorScheme.onSurface,
    );
  }
}
