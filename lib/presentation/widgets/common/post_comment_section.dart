import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../core/constants/app_text_style.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/theme_extention.dart';
import '../../../data/poll.dart';
import '../../../gen/assets.gen.dart';
import '../../pages/home/home_screen.dart';
import '../custom_text_field.dart';
import '../user_comment_card.dart';

class PostCommentSection extends StatelessWidget {
  final String currentUserImage;
  final List<CommentData> comments;

  const PostCommentSection({super.key, required this.currentUserImage, required this.comments});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Reply Input
        Row(
          children: [
            CircleAvatar(radius: 20, backgroundImage: AssetImage(currentUserImage)),
            const SizedBox(width: 10),
            Expanded(
              child: CustomTextField(
                borderColor: context.colorScheme.onSurface,
                hintText: "Reply your feedback...",
                suffixIcon: IconButton(onPressed: () {}, icon: SvgPicture.asset(Assets.icons.send)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Dynamic Comment List
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: comments.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final comment = comments[index];
            return UserCommentCard(
              userName: comment.userName,
              commentText: comment.commentText,
              userImage: comment.userImage,
              likeCount: comment.likes,
              replyCount: comment.replies,
            );
          },
        ),
      ],
    );
  }
}


