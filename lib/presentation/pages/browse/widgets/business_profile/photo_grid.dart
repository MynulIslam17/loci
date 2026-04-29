import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../../core/theme/theme_extention.dart';
import '../../../../widgets/custom_image_container.dart';

class PhotosGrid extends StatelessWidget {
  final List<String> photos;
  const PhotosGrid(this.photos, {super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: photos.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
      ),
      itemBuilder: (context, index) {
        return Card(
          color: context.colorScheme.surfaceContainerHigh,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: CustomCachedImage(imageUrl: photos[index]),
          ),
        );
      },
    );
  }
}