
import 'package:flutter/material.dart';
import 'package:loci/core/theme/theme_extention.dart';

import '../../../core/constants/app_text_style.dart';
import '../../widgets/custom_appbar.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    return Scaffold(
      // Using  CustomAppbar widget
      appBar: const CustomAppbar(
        title: "About App",
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// --- Section 1 Header ---
            Text(
              "What is Lorem Ipsum?",
              style: AppTextStyle.textLg(
                color: colorScheme.onSurface,
                weight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 10),

            /// --- Section 1 Body ---
            Text(
              "Lorem Ipsum is simply dummy text of the printing and typesetting industry. "
                  "Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, "
                  "when an unknown printer took raffles galley of type and scrambled it to make raffles type specimen book.",
              style: AppTextStyle.textSm(
                color: colorScheme.onSurfaceVariant,
              ),
            ),

            const SizedBox(height: 20),

            /// --- Illustrative Image ---
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.5)),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  "assets/images/finedine.png",
                  fit: BoxFit.contain,
                ),
              ),
            ),

            const SizedBox(height: 20),

            /// --- Section 2 Header ---
            Text(
              "What is Lorem Ipsum?",
              style: AppTextStyle.textLg(
                color: colorScheme.onSurface,
                weight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 10),

            /// --- Section 2 Body ---
            Text(
              "Lorem Ipsum is simply dummy text of the printing and typesetting industry. "
                  "Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, "
                  "when an unknown printer took raffles galley of type and scrambled it to make raffles type specimen book.",
              style: AppTextStyle.textSm(
                color: colorScheme.onSurfaceVariant,
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
