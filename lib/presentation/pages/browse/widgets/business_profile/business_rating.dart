import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../../core/constants/app_text_style.dart';

class BusinessRating extends StatelessWidget {
  final double rating;
  final int reviewCount;

  const BusinessRating({
    super.key,
    required this.rating,
    required this.reviewCount,
  });

  Widget _buildStars(double rating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        if (rating >= index + 1) {
          return const Icon(Icons.star, size: 16, color: Colors.orangeAccent);
        } else if (rating > index && rating < index + 1) {
          return const Icon(Icons.star_half, size: 16, color: Colors.orangeAccent);
        } else {
          return const Icon(Icons.star_border, size: 16, color: Colors.orangeAccent);
        }
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "$reviewCount Reviews ",
          style: AppTextStyle.textXs(),
        ),
        const SizedBox(width: 6),
        _buildStars(rating),
        const SizedBox(width: 6),
        Text(
          rating.toStringAsFixed(1),
          style: AppTextStyle.textXs(weight: FontWeight.w600),
        ),
      ],
    );
  }
}