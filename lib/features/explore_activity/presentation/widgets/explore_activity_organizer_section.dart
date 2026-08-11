import 'package:flutter/material.dart';
import 'package:loci/features/explore_activity/presentation/widgets/explore_activity_section.dart';
import 'package:loci/shared/widgets/company_info_card.dart';

class ExploreActivityOrganizerSection extends StatelessWidget {
  const ExploreActivityOrganizerSection({
    super.key,
    this.title = 'Organizer',
    required this.name,
    required this.description,
    required this.logo,
    this.highlightTitle = false,
  });

  final String title;
  final String name;
  final String description;
  final String logo;
  final bool highlightTitle;

  @override
  Widget build(BuildContext context) {
    return ExploreActivitySection(
      title: title,
      highlightTitle: highlightTitle,
      child: CompanyInfoCard(
        title: name,
        description: description,
        imagePath: logo,
      ),
    );
  }
}
