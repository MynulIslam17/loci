import 'package:flutter/material.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/features/network/presentation/widgets/network_detail_row.dart';

/// Person block used on meeting and referral cards.
class NetworkPersonBlock extends StatelessWidget {
  const NetworkPersonBlock({
    super.key,
    required this.role,
    required this.name,
    required this.accent,
    this.email,
    this.company,
  });

  final String role;
  final String name;
  final Color accent;
  final String? email;
  final String? company;

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
            Text(
              role.toUpperCase(),
              style: AppTextStyle.textXs(
                color: accent,
                weight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          name,
          softWrap: true,
          style: AppTextStyle.textSm(
            color: colors.onSurface,
            weight: FontWeight.w600,
          ),
        ),
        if (email != null && email!.isNotEmpty) ...[
          const SizedBox(height: 4),
          NetworkDetailRow(icon: Icons.mail_outline, text: email!),
        ],
        if (company != null && company!.isNotEmpty) ...[
          const SizedBox(height: 3),
          NetworkDetailRow(icon: Icons.business_outlined, text: company!),
        ],
      ],
    );
  }
}
