import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/app_text_style.dart';
import '../../../../core/theme/theme_extention.dart';
import '../../../../data/models/raffles/raffles_model.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_image_container.dart';
import 'date_range_helper.dart';

class RaffleCard extends StatelessWidget {
  final RaffleModel raffle;
  final VoidCallback onTap;

  const RaffleCard({
    super.key,
    required this.raffle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    const accentColor = Color(0xFF66B9AD);

    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      color: colorScheme.surfaceContainerHigh,
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomCachedImage(
            imageUrl: raffle.banner,
            height: 180,
            width: double.infinity,
            fit: BoxFit.cover,
            customBorderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  raffle.title,
                  style: AppTextStyle.textMd(weight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Text(
                  raffle.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyle.textXs(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 16),

                // bundle name
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 16,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    raffle.bundleName,
                    style: AppTextStyle.textSm(
                      color: colorScheme.primary,
                      weight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Date Row
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_outlined,
                      size: 14,
                      color: accentColor,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      dateRangeHelper(raffle.startDate, raffle.endDate),
                      style: AppTextStyle.textXs(weight: FontWeight.w500),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: CustomButton(
                    backgroundColor: colorScheme.primary,
                    textColor: colorScheme.onPrimary,
                    text: "Enter Raffle",
                    textStyle: AppTextStyle.textSm(weight: FontWeight.w600),
                    onPressed: onTap,
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: Text(
                    "by ${raffle.organizerName}",
                    style: AppTextStyle.textXs(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}