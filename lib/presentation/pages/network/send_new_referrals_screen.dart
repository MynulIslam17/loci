import 'package:flutter/material.dart';
import 'package:loci/presentation/widgets/custom_text_field.dart';
import 'package:loci/presentation/widgets/custom_button.dart';
import '../../../core/constants/app_text_style.dart';
import '../../../core/theme/theme_extention.dart';

class SendNewReferralsScreen extends StatefulWidget {
  const SendNewReferralsScreen({super.key});

  @override
  State<SendNewReferralsScreen> createState() => _SendNewReferralsScreenState();
}

class _SendNewReferralsScreenState extends State<SendNewReferralsScreen> {
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //--header
              _buildHeader(),
              const SizedBox(height: 24),


              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: colorScheme.outline.withOpacity(0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //--Referral details
                    _buildSectionLabel("Referral details"),
                    const SizedBox(height: 12),
                    _buildCustomInput("Enter full name"),
                    const SizedBox(height: 12),
                    _buildCustomInput("Enter email"),
                    const SizedBox(height: 20),
                    //---Business owner

                    _buildSectionLabel("Business owner"),
                    const SizedBox(height: 12),
                    _buildCustomInput("Enter owner's name"),
                    const SizedBox(height: 12),
                    _buildCustomInput("Enter owner's email"),
                    const SizedBox(height: 20),

                    //---Message
                    _buildSectionLabel("Message", optional: true),
                    const SizedBox(height: 12),
                    _buildCustomInput(
                      "Michael would be a great fit for your enterprise sales team!",
                      maxLines: 4,
                    ),
                    const SizedBox(height: 4),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        "Limit: 300 char",
                        style: AppTextStyle.textXs(color: colorScheme.onSurfaceVariant),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Submit Button
              CustomButton(
                backgroundColor: colorScheme.primary,
                onPressed: () {

                },
                child: Row(
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
                    Icon(Icons.send_outlined, color: colorScheme.onPrimary, size: 18),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Referrals",
          style: AppTextStyle.textXl(weight: FontWeight.w700),
        ),
        const SizedBox(height: 4),
        Text(
          "Recommend people to business owner",
          style: AppTextStyle.textSm(color: context.colorScheme.onSurfaceVariant),
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

  Widget _buildCustomInput(String hint, {int maxLines = 1}) {
    return CustomTextField(
      hintText: hint,
      hintTextColor: context.colorScheme.onSurfaceVariant,
      maxLine: maxLines,
      borderColor: context.colorScheme.outline,
      textColor: context.colorScheme.onSurface,

    );
  }
}