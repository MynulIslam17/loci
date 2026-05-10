import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loci/core/utils/time_parser.dart';
import 'package:loci/presentation/controllers/community/announcement_controller.dart';
import 'package:loci/presentation/pages/communites/widgets/community_search_bar.dart';
import 'package:loci/presentation/pages/communites/widgets/offer_card.dart';

class OffersTab extends StatelessWidget {
  final TextEditingController searchController;
  final void Function(String postId) onCommentTap;
  final void Function(String postId) onLikeTap;

  const OffersTab({
    super.key,
    required this.searchController,
    required this.onCommentTap,
    required this.onLikeTap,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AnnouncementController>(
      builder: (ctrl) => Column(
        children: [
          CommunitySearchBar(controller: searchController, hintText: "Search offers"),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: ctrl.announcements.length,
            itemBuilder: (context, index) {
              final offer = ctrl.announcements[index];
              final business = offer.business;
              return CommunityOfferCard(
                profileImage: business?.logo ?? "",
                businessName: business?.name ?? "",
                dateTime: formatDateTime(offer.createdAt),
                description: offer.details,
                couponImageUrl: offer.image ?? "",
                likes: (offer.likeCount ?? 0).toString(),
                comments: (offer.commentCount ?? 0).toString(),
                isLiked: ctrl.isLiked(offer.id),
                onDownloadTap: () {},
                onCommentTap: () => onCommentTap(offer.id),
                onLikeTap: () => onLikeTap(offer.id),
              );
            },
          ),
        ],
      ),
    );
  }
}
