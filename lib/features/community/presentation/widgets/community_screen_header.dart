import 'package:flutter/material.dart';
import 'package:loci/core/enums/community_role.dart';
import 'package:loci/features/community/presentation/widgets/community_member_header.dart';
import 'package:loci/features/community/presentation/widgets/community_owner_header.dart';
import 'package:loci/features/community/presentation/widgets/community_ui_constants.dart';

class CommunityScreenHeader extends StatelessWidget {
  const CommunityScreenHeader({
    super.key,
    required this.role,
    this.communityName,
  });

  final CommunityRole? role;
  final String? communityName;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: CommunityUi.headerPadding,
        child: role == CommunityRole.owner
            ? const CommunityOwnerHeader()
            : CommunityMemberHeader(fallbackName: communityName),
      ),
    );
  }
}
