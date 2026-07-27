import 'package:flutter/material.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/enums/activity_type.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/features/my_business/presentation/widgets/my_business.dart';
import 'package:loci/shared/widgets/custom_button.dart';
import 'package:loci/shared/widgets/custom_text_field.dart';

class CreateActivityBottomSection extends StatelessWidget {
  const CreateActivityBottomSection({
    super.key,
    required this.category,
    required this.isPublic,
    required this.onPublicChanged,
    required this.businessName,
    required this.locationController,
    required this.urlController,
    required this.onPublish,
    required this.isPublishLoading,
  });

  final ActivityType category;
  final bool isPublic;
  final ValueChanged<bool> onPublicChanged;
  final String businessName;
  final TextEditingController locationController;
  final TextEditingController urlController;
  final VoidCallback onPublish;
  final bool isPublishLoading;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (category != ActivityType.raffles) ...[
          CustomTextField(
            controller: locationController,
            title: 'Location',
            hintText: 'Enter location',
            prefixIcon: const Icon(Icons.location_on),
            borderColor: colorScheme.outline,
            textColor: colorScheme.onSurface,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Location is required';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: urlController,
            title: 'Map Url',
            hintText: 'Map link',
            prefixIcon: const Icon(Icons.link),
            borderColor: colorScheme.outline,
            textColor: colorScheme.onSurface,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Map url is required';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
        ],
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Text(
                'Organizer',
                style: AppTextStyle.textMd(
                  weight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
              ),
              const Spacer(),
              Text(
                isPublic ? 'Public' : 'Private',
                style: AppTextStyle.textSm(
                  weight: FontWeight.w700,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 8),
              Switch(
                value: isPublic,
                activeColor: colorScheme.primary,
                onChanged: onPublicChanged,
              ),
            ],
          ),
        ),
        MyOwnBusiness(businessName: businessName),
        const SizedBox(height: 10),
        CustomButton(
          isLoading: isPublishLoading,
          text: 'Publish',
          backgroundColor: colorScheme.primary,
          textColor: colorScheme.onPrimary,
          onPressed: onPublish,
        ),
      ],
    );
  }
}
