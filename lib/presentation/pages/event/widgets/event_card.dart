import 'package:flutter/material.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/presentation/widgets/custom_button.dart';
import 'package:loci/presentation/widgets/custom_image_container.dart';

class EventCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String description;
  final String date;
  final String location;
  final String attendance;
  final String organizer;
  final VoidCallback onRSVP;
  final VoidCallback? onTapCard;

  const EventCard({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.description,
    required this.date,
    required this.location,
    required this.attendance,
    required this.organizer,
    required this.onRSVP,
     this.onTapCard,
  });

  @override
  Widget build(BuildContext context) {

       Color color= context.colorScheme.primary;

    return InkWell(
      onTap: onTapCard,
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: context.colorScheme.surfaceContainerHigh,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Image Header
      
               CustomCachedImage(
                 width: double.infinity,
                 height: 200,
                 imageUrl: imageUrl,
                 borderRadius: 10,
               ),
              const SizedBox(height: 16),
      
              // 2. Title & Description
              Text(
                title,
                style: AppTextStyle.textLg(
                  color: context.colorScheme.onSurface,
                  weight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: AppTextStyle.textXs(
                  color: context.colorScheme.onSurfaceVariant,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 16),
      
              // 3. Info Rows
              IconTextRow(icon: Icons.calendar_today_outlined, text: date, iconColor: color),
              const SizedBox(height: 8),
              IconTextRow(icon: Icons.location_on_outlined, text: location, iconColor: color),
              const SizedBox(height: 8),
              IconTextRow(icon: Icons.people_outline, text: attendance, iconColor: color),
              const SizedBox(height: 20),
      
              // 4. Action Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: CustomButton(
                  text: "RSVP",
                  onPressed: onRSVP,
      
                )
              ),
      
              // 5. Footer
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    "by $organizer",
                    style: AppTextStyle.textXs(color: context.colorScheme.onSurfaceVariant),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}



class IconTextRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color? iconColor;
  final Color? textColor;

  const IconTextRow({
    super.key,
    required this.icon,
    required this.text,
    this.iconColor, this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: iconColor ?? context.colorScheme.primary,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: AppTextStyle.textXs(
              color: textColor ?? context.colorScheme.onSurface,
              weight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}