import 'package:flutter/material.dart';
import 'package:loci/core/enums/routeType.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/features/explore_activity/presentation/widgets/create_activity_picker_field.dart';
import 'package:loci/features/explore_activity/presentation/widgets/explore_activity_field_icon.dart';
import 'package:loci/shared/widgets/custom_dropdown.dart';

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
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CreateActivityPickerField(
          controller: timeController,
          title: 'Opening time',
          hintText: 'Select time',
          icon: Icons.access_time,
          onTap: onPickTime,
          validator: (value) {
            if (value == null || value.isEmpty) return 'Required';
            return null;
          },
        ),
        const SizedBox(height: 16),
        CustomDropdown<RouteType>(
          dropdownColor: colorScheme.surfaceContainerHigh,
          borderColor: colorScheme.outline,
          hintColor: colorScheme.onSurfaceVariant,
          textColor: colorScheme.onSurface,
          textFontSize: 13,
          hintFontSize: 13,
          title: 'Availability',
          isRequired: true,
          value: selectedRouteCondition,
          hintText: 'Select availability',
          prefixIcon: exploreActivityFieldIcon(
            context,
            Icons.alt_route_outlined,
          ),
          items: RouteType.values.map((type) {
            return DropdownMenuItem<RouteType>(
              value: type,
              child: Text(
                type.label,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            );
          }).toList(),
          onChanged: onRouteTypeChanged,
          validator: (value) {
            if (value == null) return 'Required';
            return null;
          },
        ),
      ],
    );
  }
}
