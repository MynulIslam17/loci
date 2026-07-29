import 'package:flutter/material.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/features/community/data/models/single_community_response.dart';

/// Community title + address row (owner & member headers).
class CommunityHeaderIdentity extends StatelessWidget {
  const CommunityHeaderIdentity({
    super.key,
    required this.community,
    this.fallbackName,
  });

  final CommunityModel? community;
  final String? fallbackName;

  String get _title {
    final name = community?.name.trim();
    if (name != null && name.isNotEmpty) return name;

    final fallback = fallbackName?.trim();
    if (fallback != null && fallback.isNotEmpty) return fallback;

    final business = community?.business.name.trim();
    if (business != null && business.isNotEmpty) {
      return "$business's Community";
    }
    return 'Community';
  }

  String? get _location {
    final loc = community?.business.location?.trim();
    if (loc != null && loc.isNotEmpty) return loc;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;
    final location = _location;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _title,
          style: AppTextStyle.textLg(
            weight: FontWeight.w700,
            color: colors.onSurface,
          ),
        ),
        if (location != null) ...[
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Icon(
                  Icons.location_on_outlined,
                  size: 18,
                  color: colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  location,
                  style: AppTextStyle.textSm(color: colors.onSurfaceVariant),
                ),
              ),
            ],
          ),
        ],
        const SizedBox(height: 16),
      ],
    );
  }
}
