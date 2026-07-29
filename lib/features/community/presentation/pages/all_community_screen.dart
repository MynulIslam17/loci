import 'package:flutter/material.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/features/community/presentation/widgets/all_communities/all_communities_body.dart';
import 'package:loci/shared/widgets/custom_appbar.dart';

/// Communities hub: joined list + discover/join business communities.
///
/// Data flow: UI → [AllCommunityController] / [JoinCommunityController]
/// → [CommunityService] → [CommunityRepository] → API.
class AllCommunityScreen extends StatelessWidget {
  const AllCommunityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colorScheme.surface,
      appBar: const CustomAppbar(title: 'Communities'),
      body: const AllCommunitiesBody(),
    );
  }
}
