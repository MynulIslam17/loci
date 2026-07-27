import 'package:flutter/material.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/features/my_business/presentation/widgets/edit_circle_button.dart';

class MyBusinessDescriptionCard extends StatelessWidget {
  const MyBusinessDescriptionCard({
    super.key,
    required this.description,
    required this.onEditTap,
  });

  final String description;
  final VoidCallback onEditTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return SizedBox(
      width: double.infinity,
      child: Card(
        color: colorScheme.surfaceContainerHigh,
        elevation: 2,
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: EditCircleButton(onTap: onEditTap, size: 20),
              ),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  description,
                  textAlign: TextAlign.center,
                  style: AppTextStyle.textXs(
                    color: colorScheme.onSurfaceVariant,
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
