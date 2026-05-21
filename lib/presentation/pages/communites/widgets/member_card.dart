import 'package:flutter/material.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/core/utils/dialog_helper.dart';
import 'package:loci/data/models/community/community_member_model.dart';
import 'package:loci/presentation/widgets/custom_image_container.dart';

class MemberCard extends StatelessWidget {
  final CommunityMemberModel member;
  final VoidCallback onDelete;

  const MemberCard({
    super.key,
    required this.member,
    required this.onDelete,
  });

  String get _joinedVia {
    switch (member.addedVia.toLowerCase()) {
      case 'qr':
        return 'QR Code';
      case 'email':
        return 'Email Invite';
      default:
        return member.addedVia;
    }
  }

  String get _joinedDate {
    final d = member.joinedAt;
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[d.month - 1]} ${d.day}, ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;

    return Card(
      color: colors.surfaceContainerHigh,
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomCachedImage(
              imageUrl: member.user.avatar,
              isCircle: true,
              width: 44,
              height: 44,
            ),
            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    member.user.name,
                    style: AppTextStyle.textMd(
                      color: colors.onSurface,
                      weight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  _Row(Icons.email_outlined, member.user.email, colors),
                  _Row(Icons.qr_code_scanner_outlined, _joinedVia, colors),
                  _Row(Icons.calendar_today_outlined, _joinedDate, colors),
                ],
              ),
            ),

            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'delete') {
                  showDeleteDialog(
                    context: context,
                    title: 'Remove Member',
                    message:
                        'Are you sure you want to remove ${member.user.name}?',
                    onDelete: onDelete,
                  );
                }
              },
              itemBuilder: (_) => [
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: const [
                      Icon(Icons.delete_outline, color: Colors.red, size: 20),
                      SizedBox(width: 8),
                      Text('Remove'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final IconData icon;
  final String text;
  final ColorScheme colors;

  const _Row(this.icon, this.text, this.colors);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 3),
      child: Row(
        children: [
          Icon(icon, size: 13, color: colors.onSurfaceVariant),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              text,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyle.textXs(color: colors.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }
}
