import 'package:flutter/cupertino.dart';
import 'package:loci/data/models/review/review_model.dart';

import '../../../../../core/utils/time_parser.dart';
import '../../../clam_business/widgets/review_card.dart';

class ReviewList extends StatelessWidget {
  final List<ReviewModel> reviews;
  const ReviewList({super.key,required this.reviews});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: reviews.length,
      itemBuilder: (context, index) {
        final review = reviews[index];

        return ReviewCard(
          name: review.author.name,
          rating: review.rating,
          reviewText: review.content,
          imageUrl: review.author.avatar,
          time: formatUtcToLocalTime(review.createdAt)

        );
      },
    );
  }
}