import 'package:flutter/material.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/presentation/widgets/custom_appbar.dart';

import '../../../core/utils/dialog_helper.dart';
import '../../../core/utils/validators.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class DeleteAccountScreen extends StatefulWidget {
  const DeleteAccountScreen({super.key});

  @override
  State<DeleteAccountScreen> createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends State<DeleteAccountScreen> {
  final TextEditingController _passwordController = TextEditingController();
  bool _isObscured = true;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return Scaffold(
      appBar: const CustomAppbar(title: "Delete Account"),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// --- Instruction Text ---
            Text(
              "Please enter your password to confirm account removal",
              style: AppTextStyle.textSm(
                color: colorScheme.onSurfaceVariant,
              ),
            ),

            const SizedBox(height: 16),

            /// --- Password Field ---
            CustomTextField(
              controller: _passwordController,
              hintText: "Current password",
              isPassword: true,
              borderColor: colorScheme.outline,
              validator: (value) => validatePassword(value),
            ),

            const Spacer(),

            /// --- Warning Text ---
            Align(
              alignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  "This will permanently delete your account and all personal data from our system. This action cannot be undone.",
                  textAlign: TextAlign.center,
                  style: AppTextStyle.textXs(
                    color: colorScheme.onSurfaceVariant,
                    weight: FontWeight.w500,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            /// --- Delete Button ---
            CustomButton(
              text: "Change Password",
              textColor: colorScheme.onPrimary,
              backgroundColor: colorScheme.error,
              onPressed: (){
                showDeleteDialog(
                  context: context,
                  title: "Delete Account",
                  message:
                  "Are you sure you want to delete your account? This action cannot be undone.",
                  onDelete: () {
                    // Add your delete account logic here
                    print("Account deleted");
                  },
                );

              },

            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}