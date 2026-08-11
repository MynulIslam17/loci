import 'package:flutter/material.dart';
import 'package:loci/features/community/presentation/widgets/community_announcement_card_shell.dart';
import 'package:loci/shared/widgets/custom_image_container.dart';
import 'package:loci/shared/widgets/feed/expandable_text.dart';
import 'package:loci/shared/widgets/feed/post_interaction_bar.dart';
import 'package:loci/shared/widgets/feed/user_post_header.dart';

class CommunityOfferCard extends StatelessWidget {
  final String profileImage;
  final String displayName;
  final bool isModerator;
  final String dateTime;
  final String description;
  final String couponImageUrl;
  final String likes;
  final String comments;
  final bool isLiked;

  final VoidCallback? onDownloadTap;
  final VoidCallback? onLikeTap;
  final VoidCallback? onCommentTap;
  final bool isDownloading;

  const CommunityOfferCard({
    super.key,
    required this.profileImage,
    required this.displayName,
    this.isModerator = false,
    required this.dateTime,
    required this.description,
    required this.couponImageUrl,
    required this.likes,
    required this.comments,
    this.isLiked = false,
    this.onDownloadTap,
    this.onLikeTap,
    this.onCommentTap,
    this.isDownloading = false,
  });

  @override
  Widget build(BuildContext context) {
    return CommunityAnnouncementCardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          UserPostHeader(
            fullName: displayName,
            date: dateTime,
            category: '',
            imagePath: profileImage,
            isModerator: isModerator,
          ),
          const SizedBox(height: 12),
          ExpandableText(text: description, trimLines: 2),
          if (couponImageUrl.trim().isNotEmpty) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Stack(
                children: [
                  AspectRatio(
                    aspectRatio: 16 / 9,
                    child: CustomCachedImage(imageUrl: couponImageUrl),
                  ),
                  if (onDownloadTap != null)
                    Positioned(
                      right: 10,
                      bottom: 10,
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: isDownloading ? null : onDownloadTap,
                          borderRadius: BorderRadius.circular(30),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.5),
                              shape: BoxShape.circle,
                            ),
                            child: isDownloading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(
                                    Icons.download_rounded,
                                    size: 20,
                                    color: Colors.white,
                                  ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 14),
          PostInteractionBar(
            likes: likes,
            comments: comments,
            isLiked: isLiked,
            onLikeTap: onLikeTap,
            onCommentTap: onCommentTap,
          ),
        ],
      ),
    );
  }
}
