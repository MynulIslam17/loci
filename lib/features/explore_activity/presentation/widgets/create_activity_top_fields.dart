import 'package:flutter/material.dart';
import 'package:loci/core/enums/activity_type.dart';
import 'package:loci/features/explore_activity/presentation/widgets/explore_activity_basic_fields.dart';

/// Create flow: activity type + title + description.
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
    return ExploreActivityBasicFields(
      titleController: titleController,
      detailsController: detailsController,
      selectedCategory: selectedCategory,
      onCategoryChanged: onCategoryChanged,
    );
  }
}
