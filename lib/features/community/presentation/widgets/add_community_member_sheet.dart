import 'package:flutter/material.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/core/utils/validators.dart';
import 'package:loci/shared/widgets/custom_button.dart';
import 'package:loci/shared/widgets/custom_text_field.dart';

class AddCommunityMemberPayload {
  const AddCommunityMemberPayload({
    required this.email,
    this.note,
  });

  final String email;
  final String? note;
}

class AddCommunityMemberSheet extends StatefulWidget {
  const AddCommunityMemberSheet({
    super.key,
    required this.onSubmit,
  });

  final Future<bool> Function(AddCommunityMemberPayload payload) onSubmit;

  static Future<void> show(
    BuildContext context, {
    required Future<bool> Function(AddCommunityMemberPayload payload) onSubmit,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(ctx).bottom),
        child: AddCommunityMemberSheet(onSubmit: onSubmit),
      ),
    );
  }

  @override
  State<AddCommunityMemberSheet> createState() =>
      _AddCommunityMemberSheetState();
}

class _AddCommunityMemberSheetState extends State<AddCommunityMemberSheet> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _noteController = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _emailController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_submitting) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final email = _emailController.text.trim();
    final note = _noteController.text.trim();

    setState(() => _submitting = true);
    final ok = await widget.onSubmit(
      AddCommunityMemberPayload(
        email: email,
        note: note.isEmpty ? null : note,
      ),
    );
    if (!mounted) return;
    setState(() => _submitting = false);
    if (ok) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colors.outlineVariant,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Add member',
              style: AppTextStyle.textMd(
                weight: FontWeight.w600,
                color: colors.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Invite by email address',
              style: AppTextStyle.textSm(color: colors.onSurfaceVariant),
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _emailController,
              labelText: 'Email address',
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              validator: validateEmail,
              borderColor: colors.outline,
              fontSize: 14,
              textColor: colors.onSurface,
              hintTextColor: colors.onSurfaceVariant,
            ),
            const SizedBox(height: 12),
            CustomTextField(
              controller: _noteController,
              labelText: 'Note (optional)',
              hintText: 'Add a note for this member',
              maxLine: 3,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _submit(),
              borderColor: colors.outline,
              fontSize: 14,
              textColor: colors.onSurface,
              hintTextColor: colors.onSurfaceVariant,
            ),
            const SizedBox(height: 20),
            CustomButton(
              height: 48,
              onPressed: _submitting ? null : _submit,
              child: _submitting
                  ? SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: colors.onPrimary,
                      ),
                    )
                  : Text(
                      'Add member',
                      style: AppTextStyle.textMd(
                        weight: FontWeight.w600,
                        color: colors.onPrimary,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
