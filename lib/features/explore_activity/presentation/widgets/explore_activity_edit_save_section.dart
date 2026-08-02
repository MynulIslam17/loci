import 'package:flutter/material.dart';
import 'package:loci/features/explore_activity/presentation/widgets/explore_activity_form_actions.dart';
import 'package:loci/features/explore_activity/presentation/widgets/explore_activity_section.dart';
import 'package:loci/features/explore_activity/presentation/widgets/explore_activity_visibility_row.dart';
import 'package:loci/shared/widgets/common/company_info_card.dart';

/// Visibility, organizer, and update/cancel — shared by edit screens.
class ExploreActivityEditSaveSection extends StatelessWidget {
  const ExploreActivityEditSaveSection({
    super.key,
    required this.isPublic,
    required this.onPublicChanged,
    required this.organizerTitle,
    required this.organizerDescription,
    required this.organizerLogo,
    required this.primaryLabel,
    required this.isPrimaryEnabled,
    required this.onPrimary,
    this.isLoading = false,
    this.highlightTitle = false,
  });

  final bool isPublic;
  final ValueChanged<bool> onPublicChanged;
  final String organizerTitle;
  final String organizerDescription;
  final String organizerLogo;
  final String primaryLabel;
  final bool isPrimaryEnabled;
  final VoidCallback onPrimary;
  final bool isLoading;
  final bool highlightTitle;

  @override
  Widget build(BuildContext context) {
    return ExploreActivitySection(
      title: 'Visibility & save',
      highlightTitle: highlightTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ExploreActivityVisibilityRow(
            isPublic: isPublic,
            onChanged: onPublicChanged,
          ),
          const SizedBox(height: 16),
          CompanyInfoCard(
            title: organizerTitle,
            description: organizerDescription,
            imagePath: organizerLogo,
          ),
          const SizedBox(height: 20),
          ExploreActivityFormActions(
            primaryLabel: primaryLabel,
            isPrimaryEnabled: isPrimaryEnabled,
            isLoading: isLoading,
            onPrimary: onPrimary,
          ),
        ],
      ),
    );
  }
}
