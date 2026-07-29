import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loci/features/community/presentation/controllers/my_community_controller.dart';
import 'package:loci/features/community/presentation/widgets/community_header_identity.dart';
import 'package:loci/features/community/presentation/widgets/community_header_map_preview.dart';
import 'package:loci/features/community/presentation/widgets/community_owner_header_shimmer.dart';

class CommunityMemberHeader extends StatelessWidget {
  const CommunityMemberHeader({super.key, this.fallbackName});

  final String? fallbackName;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MyCommunityController>();

    return Obx(() {
      if (controller.isLoading.value && controller.community.value == null) {
        return const CommunityOwnerHeaderShimmer(
          showIdentity: true,
          showMapPreview: true,
        );
      }

      final community = controller.community.value;
      final business = community?.business;
      final businessName =
          business?.name.trim().isNotEmpty == true
          ? business!.name
          : (fallbackName?.trim().isNotEmpty == true
                ? fallbackName!.trim()
                : 'Community');

      String? mapImage;
      if (business != null) {
        if (business.photos.isNotEmpty) {
          mapImage = business.photos.first;
        } else {
          final logo = business.logo?.trim();
          if (logo != null && logo.isNotEmpty) mapImage = logo;
        }
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (controller.isRefreshing.value)
            LinearProgressIndicator(
              minHeight: 2,
              color: Theme.of(context).colorScheme.primary,
              backgroundColor:
                  Theme.of(context).colorScheme.surfaceContainerHighest,
            ),
          CommunityHeaderIdentity(
            community: community,
            fallbackName: fallbackName,
          ),
          CommunityHeaderMapPreview(
            businessName: businessName,
            imageUrl: mapImage,
          ),
        ],
      );
    });
  }
}
