import 'package:flutter/material.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/features/community/presentation/controllers/all_community_controller.dart';
import 'package:loci/features/community/presentation/widgets/all_communities/all_communities_constants.dart';
import 'package:loci/shared/widgets/custom_text_field.dart';

class AllCommunitiesSearchBar extends StatelessWidget {
  const AllCommunitiesSearchBar({
    super.key,
    required this.controller,
    required this.textController,
  });

  final AllCommunityController controller;
  final TextEditingController textController;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(top: AllCommunitiesUi.searchTop),
      child: CustomTextField(
        controller: textController,
        hintText: 'Search communities',
        borderColor: colorScheme.outline,
        fontSize: 14,
        textColor: colorScheme.onSurface,
        hintTextColor: colorScheme.onSurfaceVariant,
        showClearButton: true,
        onChanged: controller.onSearchChanged,
        onClear: () {
          textController.clear();
          controller.clearSearch();
        },
        suffixIcon: Icon(
          Icons.search,
          size: 22,
          color: colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
