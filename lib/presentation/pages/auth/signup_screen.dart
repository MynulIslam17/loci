import 'package:flutter/material.dart';
import 'package:loci/core/utils/date_parser.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import '../../../core/constants/app_text_style.dart';
import '../../../core/theme/theme_extention.dart';
import '../../../gen/assets.gen.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_rich_text.dart';
import '../../widgets/custom_text_field.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {

  final dateTEController=TextEditingController();


  void _showCalender() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(), // User cannot be born in the future
    );

    if (pickedDate != null) {
      setState(() {
        // Formats to YYYY-MM-DD
        dateTEController.text =DateParserHelper.toFriendlyDate(pickedDate);
      });
    }
  }






  bool isAgreed = false;

  @override
  Widget build(BuildContext context) {
    double panelHeight = MediaQuery.of(context).size.height * 0.75;
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SlidingUpPanel(
        maxHeight: panelHeight,
        minHeight: panelHeight,
        parallaxEnabled: true,
        color: context.colorScheme.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(40.0),
          topRight: Radius.circular(40.0),
        ),
        parallaxOffset: .5,
        body: _buildBackgroundImageSection(context),
        panelBuilder: (sc) => _buildSignupForm(sc),
      ),
    );
  }

  Widget _buildBackgroundImageSection(BuildContext context) {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        Positioned(
          top: MediaQuery.of(context).padding.top + 20,
          child: SizedBox(
            height: 300,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()..translate(-10.0, -10.0)..rotateZ(-0.20),
                  child: Container(
                    width: 300, height: 260,
                    decoration: BoxDecoration(
                      color: context.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(40),
                    ),
                  ),
                ),
                Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()..translate(-45.0, 15.0)..rotateZ(-0.15),
                  child: _buildImageCard(Assets.images.onimg5),
                ),
                Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()..translate(50.0, -10.0)..rotateZ(0.12),
                  child: _buildImageCard(Assets.images.onimg6),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// form filed section
  Widget _buildSignupForm(ScrollController sc) {
    return ListView(
      controller: sc,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      children: [
        Center(
          child: CustomRichText(parts: [
            TextPart(
              text: "Let’s",
              style: AppTextStyle.displayXs(
                color: context.colorScheme.onSurface,
                weight: FontWeight.w400,
              ),
            ),
            TextPart(
              text: " Sign UP",
              style: AppTextStyle.displayXs(
                color: context.colorScheme.onSurface,
                weight: FontWeight.w600,
              ),
            ),
          ]),
        ),
        const SizedBox(height: 12),
        Text(
          "Create your loci account by providing necessary info",
          style: AppTextStyle.textXs(color: context.colorScheme.onSurfaceVariant),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        CustomTextField(
          borderColor: context.colorScheme.outline,
          title: "Full name",
          hintText: "Alex Carry",
          textColor: context.colorScheme.onSurface,
          titleStyle: AppTextStyle.textXs(
            color: context.colorScheme.onSurface,
            weight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        CustomTextField(
          controller: dateTEController,
          readOnly: true,
          onTap: _showCalender,
          borderColor: context.colorScheme.outline,
          title: "DOB",
          hintText: "Select Date of Birth",
          suffixIcon: Icon(
            Icons.calendar_today_outlined,
            size: 20,
            color: context.colorScheme.onSurfaceVariant,
          ),
          textColor: context.colorScheme.onSurface,
          titleStyle: AppTextStyle.textXs(
            color: context.colorScheme.onSurface,
            weight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        CustomTextField(
          borderColor: context.colorScheme.outline,
          title: "Zip code",
          hintText: "07085",
          textColor: context.colorScheme.onSurface,
          titleStyle: AppTextStyle.textXs(
            color: context.colorScheme.onSurface,
            weight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        CustomTextField(
          borderColor: context.colorScheme.outline,
          title: "Email",
          hintText: "Loisbecket@gmail.com",
          textColor: context.colorScheme.onSurface,
          titleStyle: AppTextStyle.textXs(
            color: context.colorScheme.onSurface,
            weight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            SizedBox(
              height: 20,
              width: 20,
              child: Checkbox(
                value: isAgreed,
                onChanged: (v) => setState(() => isAgreed = v!),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: CustomRichText(parts: [
                TextPart(
                  text: "Are you agree To ",
                  style: AppTextStyle.textXs(color: context.colorScheme.onSurface),
                ),
                TextPart(
                  text: "Our Terms ",
                  style: AppTextStyle.textXs(
                    color: context.colorScheme.primary,
                    weight: FontWeight.w600,
                  ),
                ),
                TextPart(
                  text: "of service?",
                  style: AppTextStyle.textXs(color: context.colorScheme.onSurface),
                ),
              ]),
            ),
          ],
        ),
        const SizedBox(height: 20),
        CustomButton(
          backgroundColor: context.colorScheme.primary,
          textColor: context.colorScheme.onPrimary,
          text: "Sign Up",
          onPressed: () {},
        ),
        const SizedBox(height: 20),
        Center(
          child: CustomRichText(parts: [
            TextPart(
              text: "Already have an account? ",
              style: AppTextStyle.textSm(color: context.colorScheme.onSurface),
            ),
            TextPart(
              text: "Sign In",
              style: AppTextStyle.textSm(
                color: context.colorScheme.primary,
                weight: FontWeight.w700,
              ),
              onTap: () => Navigator.pop(context),
            ),
          ]),
        ),
        const SizedBox(height: 40),
      ],
    );
  }


  /// below image section
  Widget _buildImageCard(AssetGenImage asset) {
    return Container(
      width: 180, height: 230,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: asset.image(fit: BoxFit.cover),
      ),
    );
  }
}