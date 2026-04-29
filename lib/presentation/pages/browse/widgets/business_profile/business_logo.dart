import 'package:flutter/cupertino.dart';

import '../../../../../core/theme/theme_extention.dart';
import '../../../../widgets/custom_image_container.dart';

class BusinessLogo extends StatelessWidget {
  final String? logo;
  const BusinessLogo(this.logo, {super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        height: 140,
        width: 140,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: context.colorScheme.primary,
            width: 1.5,
          ),
        ),
        child: CustomCachedImage(
          imageUrl: logo,
          isCircle: true,
        ),
      ),
    );
  }
}