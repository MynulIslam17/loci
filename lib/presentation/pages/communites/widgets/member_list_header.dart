import 'package:flutter/material.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';

class MemberListHeader extends StatelessWidget {
  final int count;
  final bool isLoading;

  const MemberListHeader({
    super.key,
    required this.count,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Total member list',
                style: AppTextStyle.textMd(
                  color: colors.onSurface,
                  weight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                isLoading ? '—' : '$count Members',
                style: AppTextStyle.textSm(
                  color: colors.onSurfaceVariant,
                  weight: FontWeight.w600,
                ),
              ),
            ],
          ),
          OutlinedButton.icon(
            onPressed: () {},
            icon: Text('Save', style: TextStyle(color: colors.onSurface)),
            label: Icon(
              Icons.file_download_outlined,
              color: colors.onSurface,
              size: 20,
            ),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: Colors.grey.shade300),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
