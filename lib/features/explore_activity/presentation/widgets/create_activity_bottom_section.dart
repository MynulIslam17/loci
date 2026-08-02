import 'package:flutter/material.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/enums/activity_type.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/features/my_business/presentation/widgets/my_business.dart';
import 'package:loci/shared/widgets/location/location_models.dart';
import 'package:loci/shared/widgets/custom_button.dart';
import 'package:loci/features/explore_activity/presentation/widgets/explore_activity_location_fields.dart';
import 'package:loci/features/explore_activity/presentation/widgets/explore_activity_visibility_row.dart';

class CreateActivityBottomSection extends StatelessWidget {
  const CreateActivityBottomSection({
    super.key,
    required this.category,
    required this.isPublic,
    required this.onPublicChanged,
    required this.businessName,
    required this.locationController,
    required this.urlController,
    required this.onLocationPicked,
    required this.onPublish,
    required this.isPublishLoading,
  });

  final ActivityType category;
  final bool isPublic;
  final ValueChanged<bool> onPublicChanged;
  final String businessName;
  final TextEditingController locationController;
  final TextEditingController urlController;
  final ValueChanged<PickedLocation> onLocationPicked;
  final VoidCallback onPublish;
  final bool isPublishLoading;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (category != ActivityType.raffles) ...[
          ExploreActivityLocationFields(
            locationController: locationController,
            urlController: urlController,
            onLocationPicked: onLocationPicked,
          ),
          const SizedBox(height: 20),
        ],
        ExploreActivityVisibilityRow(
          isPublic: isPublic,
          onChanged: onPublicChanged,
        ),
        const SizedBox(height: 16),
        Text(
          'Organizer',
          style: AppTextStyle.textSm(
            weight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        MyOwnBusiness(businessName: businessName),
        const SizedBox(height: 20),
        CustomButton(
          isLoading: isPublishLoading,
          text: 'Publish activity',
          backgroundColor: colorScheme.primary,
          textColor: colorScheme.onPrimary,
          onPressed: onPublish,
        ),
      ],
    );
  }
}
