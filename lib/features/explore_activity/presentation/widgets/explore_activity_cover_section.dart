import 'dart:io';

import 'package:flutter/material.dart';
import 'package:loci/features/explore_activity/presentation/widgets/create_activity_banner_section.dart';
import 'package:loci/features/explore_activity/presentation/widgets/explore_activity_section.dart';

/// Cover image block for create/edit flows.
class ExploreActivityCoverSection extends StatelessWidget {
  const ExploreActivityCoverSection({
    super.key,
    this.imageUrl,
    required this.bannerImage,
    required this.onSelected,
  });

  final String? imageUrl;
  final File? bannerImage;
  final ValueChanged<File> onSelected;

  @override
  Widget build(BuildContext context) {
    return ExploreActivitySection(
      title: 'Cover image',
      subtitle: 'Banner shown on the activity card',
      child: CreateActivityBannerSection(
        imageUrl: imageUrl,
        bannerImage: bannerImage,
        onSelected: onSelected,
      ),
    );
  }
}
