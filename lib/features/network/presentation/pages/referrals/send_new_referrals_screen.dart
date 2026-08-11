import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/core/utils/show_snackbar.dart';
import 'package:loci/core/utils/validators.dart';
import 'package:loci/features/network/presentation/controllers/send_new_referrals_controller.dart';
import 'package:loci/shared/widgets/custom_button.dart';
import 'package:loci/shared/widgets/custom_text_field.dart';

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
    super.dispose();
  }

  Future<void> _onSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    // Dismiss the keyboard before the network call.
    FocusScope.of(context).unfocus();

    final success = await _controller.sendReferral(
      recipientEmail: _recipientEmailController.text.trim(),
      recipientName: _recipientNameController.text.trim(),
      recipientCompany: _optionalValue(_recipientCompanyController),
      businessOwnerEmail: _ownerEmailController.text.trim(),
      businessOwnerName: _ownerNameController.text.trim(),
      ownerCompanyName: _optionalValue(_ownerCompanyName),
      message: _optionalValue(_messageController),
    );
    if (!mounted) return;

    if (success) {
      await _controller.onSendSuccess();
      Get.back();
      SnackbarService.success('Referral sent');
    } else {
      // Surfaces backend rejections such as
      // "You cannot send a referral to yourself".
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
                      color: colorScheme.outline.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // --- Recipient details ---
                      _buildSectionLabel("Recipient details"),
                      const SizedBox(height: 12),
                      _buildField(
                        label: "Full name",
                        hint: "Enter recipient's full name",
                        controller: _recipientNameController,
                        validator: validateFullName,
                        isNameField: true,
                      ),
                      const SizedBox(height: 12),
                      _buildField(
                        label: "Email",
                        hint: "Enter recipient's email",
                        controller: _recipientEmailController,
                        keyboardType: TextInputType.emailAddress,
                        validator: validateEmail,
                      ),
                      const SizedBox(height: 12),
                      _buildField(
                        label: "Company",
                        hint: "Enter recipient's company",
                        controller: _recipientCompanyController,
                        isRequired: false,
                      ),
                      const SizedBox(height: 20),

                      // --- Business owner ---
                      _buildSectionLabel("Business owner"),
                      const SizedBox(height: 12),
                      _buildField(
                        label: "Name",
                        hint: "Enter owner's name",
                        controller: _ownerNameController,
                        validator: (v) => validateName(v, fieldName: 'Name'),
                        isNameField: true,
                      ),
                      const SizedBox(height: 12),
                      _buildField(
                        label: "Email",
                        hint: "Enter owner's email",
                        controller: _ownerEmailController,
                        keyboardType: TextInputType.emailAddress,
                        validator: validateEmail,
                      ),
                      const SizedBox(height: 12),
                      _buildField(
                        label: "Company",
                        hint: "Enter owner's business name",
                        controller: _ownerCompanyName,
                        isRequired: false,
                      ),

                      const SizedBox(height: 20),

                      // --- Message (optional) ---
                      _buildField(
                        label: "Message",
                        isRequired: false,
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
                  return CustomButton(
                    backgroundColor: colorScheme.primary,
                    onPressed: _controller.isLoading ? null : _onSubmit,
                    child: _controller.isLoading
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

  String? _optionalValue(TextEditingController controller) {
    final value = controller.text.trim();
    return value.isEmpty ? null : value;
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
        const SizedBox(height: 8),
        RichText(
          text: TextSpan(
            text: "Fields marked ",
            style: AppTextStyle.textXs(
              color: context.colorScheme.onSurfaceVariant,
            ),
            children: [
              TextSpan(
                text: "*",
                style: AppTextStyle.textXs(
                  color: context.colorScheme.error,
                  weight: FontWeight.w700,
                ),
              ),
              const TextSpan(text: " are required"),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionLabel(String label, {bool optional = false}) {
    final colorScheme = context.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 18,
            decoration: BoxDecoration(
              color: colorScheme.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                text: label,
                style: AppTextStyle.textMd(
                  color: colorScheme.primary,
                  weight: FontWeight.w700,
                ),
                children: [
                  if (optional)
                    TextSpan(
                      text: " (optional)",
                      style: AppTextStyle.textSm(
                        color: colorScheme.onSurfaceVariant,
                        weight: FontWeight.w400,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField({
    required String label,
    required String hint,
    required TextEditingController controller,
    bool isRequired = true,
    int maxLines = 1,
    int? maxLength,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    bool isNameField = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel(label, isRequired),
        const SizedBox(height: 6),
        CustomTextField(
          controller: controller,
          hintText: hint,
          maxLine: maxLines,
          maxLength: maxLength,
          keyboardType: isNameField ? TextInputType.name : keyboardType,
          textCapitalization:
              isNameField ? TextCapitalization.words : TextCapitalization.none,
          inputFormatters: isNameField ? nameInputFormatters : null,
          validator: validator,
          hintTextColor: context.colorScheme.onSurfaceVariant,
          borderColor: context.colorScheme.outline,
          textColor: context.colorScheme.onSurface,
        ),
      ],
    );
  }

  /// Field label with a red asterisk for required fields, or "(optional)".
  Widget _buildFieldLabel(String label, bool isRequired) {
    final colorScheme = context.colorScheme;
    return RichText(
      text: TextSpan(
        text: label,
        style: AppTextStyle.textSm(
          color: colorScheme.onSurfaceVariant,
          weight: FontWeight.w500,
        ),
        children: [
          if (isRequired)
            TextSpan(
              text: " *",
              style: AppTextStyle.textSm(
                color: colorScheme.error,
                weight: FontWeight.w700,
              ),
            )
          else
            TextSpan(
              text: " (optional)",
              style: AppTextStyle.textXs(
                color: colorScheme.onSurfaceVariant,
                weight: FontWeight.w400,
              ),
            ),
        ],
      ),
    );
  }
}
