import 'package:flutter/material.dart';
import 'package:loci/features/community/presentation/widgets/community_card_skeleton.dart';

/// Post cards only (pair with [CommunityPostInputSkeleton] while loading in [TabBodyWrapper]).
class CommunityFeedListShimmer extends StatelessWidget {
  const CommunityFeedListShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CommunityFeedPostSkeleton(),
        CommunityFeedPostSkeleton(),
        CommunityFeedPostSkeleton(),
      ],
    );
  }
}

class CommunityOffersListShimmer extends StatelessWidget {
  const CommunityOffersListShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CommunityOfferCardSkeleton(),
        CommunityOfferCardSkeleton(),
      ],
    );
  }
}

class CommunityNoticesListShimmer extends StatelessWidget {
  const CommunityNoticesListShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CommunityNoticeCardSkeleton(),
        CommunityNoticeCardSkeleton(),
      ],
    );
  }
}

class CommunityActivityListShimmer extends StatelessWidget {
  const CommunityActivityListShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CommunityActivityCardSkeleton(),
        CommunityActivityCardSkeleton(),
      ],
    );
  }
}

/// @deprecated Use [CommunityFeedListShimmer] with sticky post composer.
class CommunityFeedTabShimmer extends CommunityFeedListShimmer {
  const CommunityFeedTabShimmer({super.key});
}

class CommunityOffersTabShimmer extends CommunityOffersListShimmer {
  const CommunityOffersTabShimmer({super.key});
}

class CommunityNoticesTabShimmer extends CommunityNoticesListShimmer {
  const CommunityNoticesTabShimmer({super.key});
}

class CommunityActivityTabShimmer extends CommunityActivityListShimmer {
  const CommunityActivityTabShimmer({super.key});
}
