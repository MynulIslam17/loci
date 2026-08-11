import 'package:flutter/material.dart';
import 'package:loci/core/enums/activity_type.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/features/explore_activity/presentation/widgets/explore_activity_field_icon.dart';
import 'package:loci/shared/widgets/custom_dropdown.dart';
import 'package:loci/shared/widgets/custom_text_field.dart';

/// Title + description; optional activity type (create only).
class ExploreActivityBasicFields extends StatelessWidget {
  const ExploreActivityBasicFields({
    super.key,
    required this.titleController,
    required this.detailsController,
    this.selectedCategory,
    this.onCategoryChanged,
    this.titleHint = 'Give your activity a clear name',
    this.descriptionHint = 'What should people know about this activity?',
    this.descriptionMaxLength,
  });

  final TextEditingController titleController;
  final TextEditingController detailsController;
  final ActivityType? selectedCategory;
  final ValueChanged<ActivityType>? onCategoryChanged;

  final String titleHint;
  final String descriptionHint;
  final int? descriptionMaxLength;

  bool get _showTypePicker =>
      selectedCategory != null && onCategoryChanged != null;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return Column(
      children: [
        if (_showTypePicker) ...[
          CustomDropdown<ActivityType>(
            title: 'Activity type',
            isRequired: true,
            value: selectedCategory,
            hintText: 'Select type',
            dropdownColor: colorScheme.surfaceContainerHigh,
            borderColor: colorScheme.outline,
            hintColor: colorScheme.onSurfaceVariant,
            textColor: colorScheme.onSurface,
            textFontSize: 13,
            hintFontSize: 13,
            prefixIcon: exploreActivityFieldIcon(
              context,
              Icons.category_outlined,
            ),
            items: ActivityType.values.map((type) {
              return DropdownMenuItem<ActivityType>(
                value: type,
                child: Text(
                  type.label,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) onCategoryChanged!(value);
            },
          ),
          const SizedBox(height: 16),
        ],
        CustomTextField(
          controller: titleController,
          title: 'Title',
          isRequired: true,
          hintText: titleHint,
          textInputAction: TextInputAction.next,
          prefixIcon: exploreActivityFieldIcon(context, Icons.title_outlined),
          borderColor: colorScheme.outline,
          textColor: colorScheme.onSurface,
          validator: (value) {
            final text = value?.trim() ?? '';
            if (text.isEmpty) return 'Title is required';
            if (text.length < 3) {
              return 'Title should be at least 3 characters';
            }
            if (text.length > 100) {
              return 'Title must be under 100 characters';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: detailsController,
          title: 'Description',
          isRequired: true,
          hintText: descriptionHint,
          maxLine: 4,
          textInputAction: TextInputAction.done,
          prefixIcon: exploreActivityFieldIcon(
            context,
            Icons.notes_outlined,
          ),
          borderColor: colorScheme.outline,
          textColor: colorScheme.onSurface,
          validator: (value) {
            final text = value?.trim() ?? '';
            if (text.isEmpty) return 'Description is required';
            final maxLength =
                descriptionMaxLength ?? (_showTypePicker ? 200 : 1000);
            if (text.length > maxLength) {
              return 'Description must be under $maxLength characters';
            }
            return null;
          },
        ),
      ],
    );
  }
}
