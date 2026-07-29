import 'package:flutter/material.dart';
import 'package:loci/features/explore_activity/presentation/widgets/explore_activity_section.dart';
import 'package:loci/shared/widgets/common/company_info_card.dart';

class ExploreActivityOrganizerSection extends StatelessWidget {
  const ExploreActivityOrganizerSection({
    super.key,
    this.title = 'Organizer',
    required this.name,
    required this.description,
    required this.logo,
  });

  final String title;
  final String name;
  final String description;
  final String logo;

  @override
  Widget build(BuildContext context) {
    return ExploreActivitySection(
      title: title,
      child: CompanyInfoCard(
        title: name,
        description: description,
        imagePath: logo,
      ),
    );
  }
}
