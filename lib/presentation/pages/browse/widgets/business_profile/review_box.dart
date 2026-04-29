import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import '../../../../../core/theme/theme_extention.dart';
import '../../../../widgets/custom_text_field.dart';

class ReviewBox extends StatelessWidget {
  const ReviewBox({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: context.colorScheme.surfaceContainerHigh,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Write your review"),
                RatingBar.builder(
                  initialRating: 0,
                  itemSize: 18,
                  itemBuilder: (_, __) =>
                  const Icon(Icons.star, color: Colors.amber),
                  onRatingUpdate: (_) {},
                ),
              ],
            ),
            const SizedBox(height: 12),
            CustomTextField(
              hintText: "Write your reviews within 100 words....",
              maxLine: 4,
              suffixIcon: IconButton(
                onPressed: () {},
                icon: const Icon(Icons.send),
              ),
            ),
          ],
        ),
      ),
    );
  }
}