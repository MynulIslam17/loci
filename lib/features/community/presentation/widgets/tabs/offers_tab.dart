import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loci/core/enums/announcement_type.dart';
import 'package:loci/core/utils/gallery_image_downloader.dart';
import 'package:loci/core/utils/show_snackbar.dart';
import 'package:loci/core/utils/time_parser.dart';
import 'package:loci/features/community/presentation/controllers/announcement_controller.dart';
import 'package:loci/features/community/data/models/announcement_author_display.dart';
import 'package:loci/features/community/presentation/widgets/offer_card.dart';

class OffersTab extends StatefulWidget {
  final void Function(String postId) onCommentTap;
  final void Function(String postId) onLikeTap;

  const OffersTab({
    super.key,
    required this.onCommentTap,
    required this.onLikeTap,
  });

  @override
  State<OffersTab> createState() => _OffersTabState();
}

class _OffersTabState extends State<OffersTab> with AutomaticKeepAliveClientMixin {
  static const _tabType = AnnouncementType.offer;
  String? _downloadingOfferId;

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Obx(() {
      final ctrl = Get.find<AnnouncementController>();
      ctrl.revisionFor(_tabType).value;
      ctrl.announcementMap.length;
      ctrl.communityOwnerUserId.value;
      final announcements = ctrl.announcementsFor(_tabType);

      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: announcements.length,
        itemBuilder: (context, index) {
              final offer = announcements[index];
              final author = AnnouncementAuthorDisplay.from(
                offer,
                communityOwnerUserId: ctrl.communityOwnerUserId.value,
              );
              return CommunityOfferCard(
                profileImage: author.avatarUrl,
                displayName: author.displayName,
                isModerator: author.isModerator,
                dateTime: formatDateTime(offer.createdAt),
                description: offer.details,
                couponImageUrl: offer.image ?? "",
                likes: (offer.likeCount ?? 0).toString(),
                comments: (offer.commentCount ?? 0).toString(),
                isLiked: ctrl.isLiked(offer.id),
                isDownloading: _downloadingOfferId == offer.id,
                onDownloadTap: (offer.image ?? '').trim().isEmpty
                    ? null
                    : () => _downloadOfferImage(offer.id, offer.image!),
                onCommentTap: () => widget.onCommentTap(offer.id),
                onLikeTap: () => widget.onLikeTap(offer.id),
              );
            },
          );
    });
  }

  Future<void> _downloadOfferImage(String offerId, String url) async {
    if (_downloadingOfferId != null) return;

    setState(() => _downloadingOfferId = offerId);
    try {
      await GalleryImageDownloader.saveNetworkImage(url);
      if (!mounted) return;
      SnackbarService.success('Offer saved to gallery');
    } catch (e) {
      if (!mounted) return;
      SnackbarService.error(
        e.toString().replaceFirst('Exception: ', ''),
      );
    } finally {
      if (mounted) {
        setState(() => _downloadingOfferId = null);
      }
    }
  }
}
