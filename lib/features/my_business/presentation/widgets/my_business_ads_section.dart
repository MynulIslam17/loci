import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loci/features/my_business/data/models/my_ad_model.dart';
import 'package:loci/features/my_business/presentation/widgets/my_business_ads_carousel.dart';
import 'package:loci/shared/widgets/empty_state.dart';

class MyBusinessAdsSection extends StatelessWidget {
  const MyBusinessAdsSection({
    super.key,
    required this.ads,
    required this.isLoading,
    this.creditsRemaining,
  });

  final List<MyAdModel> ads;
  final bool isLoading;
  final int? creditsRemaining;

  @override
  Widget build(BuildContext context) {
    if (isLoading && ads.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (ads.isEmpty) {
      return const EmptyState(
        icon: Icons.campaign_outlined,
        title: 'No advertisements yet',
        subtitle: 'Create an ad to promote your business here.',
        iconSize: 44,
      );
    }

    return MyBusinessAdsCarousel(
      ads: ads,
      creditsRemaining: creditsRemaining,
    );
  }
}

class MyBusinessAdsSectionObx extends StatelessWidget {
  const MyBusinessAdsSectionObx({
    super.key,
    required this.ads,
    required this.isLoading,
    this.creditsRemaining,
  });

  final RxList<MyAdModel> ads;
  final RxBool isLoading;
  final RxnInt? creditsRemaining;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => MyBusinessAdsSection(
        ads: ads.toList(),
        isLoading: isLoading.value,
        creditsRemaining: creditsRemaining?.value,
      ),
    );
  }
}
