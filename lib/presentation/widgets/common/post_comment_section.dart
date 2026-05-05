import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/constants/app_text_style.dart';
import '../../../core/theme/theme_extention.dart';
import '../../../data/models/poll.dart';
import '../../../gen/assets.gen.dart';
import '../custom_text_field.dart';
import '../../pages/home/widgets/user_comment_card.dart';

/// Comment section used inside posts
/// Shows:
/// 1. Reply input field
/// 2. Maximum 2 comments
/// 3. "View all comments" button if more comments exist
class FeedCommentSection extends StatelessWidget {
  final String currentUserImage;
  final List<CommentData> comments;

  const FeedCommentSection({
    super.key,
    required this.currentUserImage,
    required this.comments,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        /// -------------------------------------------------
        /// REPLY INPUT FIELD
        /// -------------------------------------------------
        Row(
          children: [
            /// Current user avatar
            CircleAvatar(
              radius: 20,
              backgroundImage: AssetImage(currentUserImage),
            ),

            const SizedBox(width: 10),

            /// Comment input field
            Expanded(
              child: CustomTextField(
                borderColor: context.colorScheme.outline,
                hintText: "Reply your feedback...",
                suffixIcon: IconButton(
                  onPressed: () {},
                  icon: SvgPicture.asset(Assets.icons.send),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        /// -------------------------------------------------
        /// COMMENT LIST (MAX 2)
        /// -------------------------------------------------
        ListView.separated(
          shrinkWrap: true,

          /// Disable internal scrolling
          /// Parent scroll view will handle it
          physics: const NeverScrollableScrollPhysics(),

          /// Show maximum 2 comments
          itemCount: comments.length > 2 ? 2 : comments.length,

          separatorBuilder: (_, __) => const SizedBox(height: 12),

          itemBuilder: (context, index) {
            final comment = comments[index];

            return UserCommentCard(
              userName: comment.userName,
              commentText: comment.commentText,
              userImage: comment.userImage,
              likeCount: comment.likes.toString(),
              replyCount: comment.replies.toString(),
            );
          },
        ),

        const SizedBox(height: 16),

        /// -------------------------------------------------
        /// VIEW ALL COMMENTS BUTTON
        /// Shows only if comments > 2
        /// -------------------------------------------------
        if (comments.length > 2)
          Center(
            child: InkWell(
              onTap: () {
                // TODO: open bottom sheet
                _commentBottomSheet(context,comments, currentUserImage);

              },

              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "View all ${comments.length} comments",
                    style: AppTextStyle.textXs(
                      color: context.colorScheme.primary,
                      weight: FontWeight.w600
                    ),
                  ),

                  const SizedBox(width: 4),

                  Icon(
                    Icons.keyboard_arrow_down,
                    size: 16,
                    color: context.colorScheme.primary,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }


  //bottom sheet

  void _commentBottomSheet(BuildContext context, List<CommentData> comments, String currentUserImage) {
    final colorScheme=context.colorScheme;
    showModalBottomSheet(
      backgroundColor: colorScheme.surfaceContainer,
      context: context,
      isScrollControlled: true, // allows full height
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom, // avoid keyboard overlap
          ),
          child: DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.6, // 60% of screen height
            minChildSize: 0.4,
            maxChildSize: 0.95,
            builder: (context, scrollController) {
              return Column(
                children: [
                  /// Grab handle
                  Container(
                    width: 50,
                    height: 5,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: context.colorScheme.onSurface,
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),

                  /// Comment list
                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      itemCount: comments.length,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemBuilder: (context, index) {
                        final comment = comments[index];
                        return UserCommentCard(
                          userName: comment.userName,
                          commentText: comment.commentText,
                          userImage: comment.userImage,
                          likeCount: comment.likes.toString(),
                          replyCount: comment.replies.toString(),
                        );
                      },
                    ),
                  ),

                  /// Reply input field at bottom
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundImage: AssetImage(currentUserImage),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: CustomTextField(
                            borderColor: Colors.grey,
                            hintText: "Reply your feedback...",
                            suffixIcon: IconButton(
                              onPressed: () {
                                // TODO: send reply
                              },
                              icon: const Icon(Icons.send),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }



}