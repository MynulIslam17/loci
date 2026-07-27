import 'package:flutter/material.dart';
import 'package:loci/core/enums/activity_type.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/shared/widgets/custom_dropdown.dart';
import 'package:loci/shared/widgets/custom_text_field.dart';

class CreateActivityTopFields extends StatelessWidget {
  const CreateActivityTopFields({
    super.key,
    required this.selectedCategory,
    required this.onCategoryChanged,
    required this.titleController,
    required this.detailsController,
  });

  final ActivityType selectedCategory;
  final ValueChanged<ActivityType> onCategoryChanged;
  final TextEditingController titleController;
  final TextEditingController detailsController;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return Column(
      children: [
        CustomDropdown<ActivityType>(
          value: selectedCategory,
          hintText: 'Category',
          dropdownColor: colorScheme.surfaceContainerHigh,
          borderColor: colorScheme.outline,
          hintColor: colorScheme.onSurfaceVariant,
          textColor: colorScheme.onSurface,
          textFontSize: 14,
          hintFontSize: 14,
          items: ActivityType.values.map((type) {
            return DropdownMenuItem<ActivityType>(
              value: type,
              child: Text(type.label),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) onCategoryChanged(value);
          },
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: titleController,
          title: 'Title',
          hintText: 'Enter title',
          borderColor: colorScheme.outline,
          textColor: colorScheme.onSurface,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Title is required';
            }
            if (value.length < 3) {
              return 'Title should be at least 3 characters';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: detailsController,
          title: 'Details',
          hintText: 'Short description',
          maxLine: 5,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Details are required';
            }
            if (value.trim().length > 200) {
              return 'Details must be under 200 characters';
            }
            return null;
          },
          borderColor: colorScheme.outline,
          textColor: colorScheme.onSurface,
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
