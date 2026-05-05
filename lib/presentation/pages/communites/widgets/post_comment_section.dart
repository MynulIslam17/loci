import 'package:flutter/material.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/presentation/widgets/custom_image_container.dart';
import 'package:loci/presentation/widgets/custom_text_field.dart';
import '../../../../core/utils/time_parser.dart';
import '../../../../data/models/comment/comment_model.dart';

class PostCommentSection extends StatelessWidget {
  final List<CommentModel> comments;
  final TextEditingController controller;
  final String currentUserImage;
  final bool isLoading;
  final bool paginationLoading;
  final bool isSending;
  final Function(String)? onSendTap;
  final ScrollController scrollController;

  const PostCommentSection({
    super.key,
    required this.comments,
    required this.controller,
    required this.currentUserImage,
    this.isLoading = false,
    this.isSending = false,
    this.onSendTap,
    required this.scrollController,
    required this.paginationLoading,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.75,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            /// Drag handle
            Container(
              width: 40,
              height: 5,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: colorScheme.outline,
                borderRadius: BorderRadius.circular(10),
              ),
            ),

            /// Title
            Text(
              "Comments",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),

            const SizedBox(height: 12),

            /// Comment list
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : comments.isEmpty
                  ? Center(
                child: Text(
                  "No comments yet",
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              )
                  : ListView.builder(
                controller: scrollController,
                itemCount: comments.length + (paginationLoading ? 1 : 0),
                itemBuilder: (_, index) {

                  /// ✅ pagination loader at bottom
                  if (index == comments.length) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Center(
                        child: SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    );
                  }

                  final comment = comments[index];

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomCachedImage(
                          width: 30,
                          height: 30,
                          isCircle: true,
                          imageUrl: comment.author.avatar,
                        ),

                        const SizedBox(width: 10),

                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  comment.author.name,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: colorScheme.onSurface,
                                  ),
                                ),

                                const SizedBox(height: 4),

                                Text(
                                  comment.content,
                                  style: TextStyle(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),

                                const SizedBox(height: 6),

                                Text(
                                  formatRelativeTime(comment.createdAt),
                                  style: AppTextStyle.textXs(
                                    color: colorScheme.outline,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              )
            ),

            const SizedBox(height: 8),

            /// Input area
            Row(
              children: [
                CustomCachedImage(
                  width: 30,
                  height: 30,
                  isCircle: true,
                  imageUrl: currentUserImage,
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: CustomTextField(
                    controller: controller,
                    hintText: "Write a comment...",
                    borderColor: colorScheme.outline,
                    fontSize: 14,
                    textColor: colorScheme.onSurface,
                    hintTextColor: colorScheme.onSurfaceVariant,
                  ),
                ),

                const SizedBox(width: 8),

                IconButton(
                  onPressed: isSending
                      ? null
                      : () {
                    final text = controller.text.trim();
                    if (text.isEmpty) return;
                    onSendTap?.call(text);
                    controller.clear();
                  },
                  icon: isSending
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                      : Icon(Icons.send, color: colorScheme.primary),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}