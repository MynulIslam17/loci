import 'package:flutter/material.dart';
import 'package:loci/core/enums/routeType.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/shared/widgets/custom_dropdown.dart';
import 'package:loci/shared/widgets/custom_text_field.dart';

class CreateActivityRouteFields extends StatelessWidget {
  const CreateActivityRouteFields({
    super.key,
    required this.timeController,
    required this.selectedRouteCondition,
    required this.onPickTime,
    required this.onRouteTypeChanged,
  });

  final TextEditingController timeController;
  final RouteType? selectedRouteCondition;
  final VoidCallback onPickTime;
  final ValueChanged<RouteType?> onRouteTypeChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Route Details',
          style: AppTextStyle.textSm(weight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: CustomTextField(
                controller: timeController,
                readOnly: true,
                title: 'Opening',
                onTap: onPickTime,
                hintText: 'Opening time',
                fontSize: 12,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Required';
                  }
                  return null;
                },
                suffixIcon: Icon(
                  Icons.access_time,
                  size: 18,
                  color: colorScheme.onSurfaceVariant,
                ),
                borderColor: colorScheme.outline,
                textColor: colorScheme.onSurface,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CustomDropdown<RouteType>(
                dropdownColor: colorScheme.surfaceContainerHigh,
                borderColor: colorScheme.outline,
                hintColor: colorScheme.onSurfaceVariant,
                textColor: colorScheme.onSurface,
                textFontSize: 14,
                hintFontSize: 14,
                title: 'Availability types',
                value: selectedRouteCondition,
                hintText: 'Route type',
                items: RouteType.values.map((type) {
                  return DropdownMenuItem<RouteType>(
                    value: type,
                    child: Text(type.label),
                  );
                }).toList(),
                onChanged: onRouteTypeChanged,
                validator: (value) {
                  if (value == null) {
                    return 'Required';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}
