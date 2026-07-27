import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/features/my_business/data/models/my_ad_model.dart';
import 'package:loci/features/my_business/presentation/widgets/my_business_ad_banner_card.dart';

class MyBusinessAdsCarousel extends StatefulWidget {
  const MyBusinessAdsCarousel({
    super.key,
    required this.ads,
    this.creditsRemaining,
  });

  final List<MyAdModel> ads;
  final int? creditsRemaining;

  @override
  State<MyBusinessAdsCarousel> createState() => _MyBusinessAdsCarouselState();
}

class _MyBusinessAdsCarouselState extends State<MyBusinessAdsCarousel> {
  final RxInt _currentIndex = 0.obs;

  double _maxSlideHeight(BuildContext context) {
    var maxHeight = 0.0;
    for (var i = 0; i < widget.ads.length; i++) {
      final height = MyBusinessAdBannerCard.estimatedHeight(
        context,
        widget.ads[i],
        showCredits: i == 0 && widget.creditsRemaining != null,
      );
      if (height > maxHeight) maxHeight = height;
    }
    return maxHeight;
  }

  @override
  Widget build(BuildContext context) {
    final ads = widget.ads;
    if (ads.isEmpty) return const SizedBox.shrink();

    if (ads.length == 1) {
      return MyBusinessAdBannerCard(
        ad: ads.first,
        creditsRemaining: widget.creditsRemaining,
      );
    }

    final colorScheme = context.colorScheme;
    final usePeekLayout = ads.length >= 3;
    // Extra room so [enlargeCenterPage] scale does not clip the card.
    final slideHeight = _maxSlideHeight(context) + 28;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CarouselSlider.builder(
          itemCount: ads.length,
          options: CarouselOptions(
            height: slideHeight,
            viewportFraction: usePeekLayout ? 0.92 : 0.94,
            enlargeCenterPage: true,
            enlargeFactor: 0.18,
            enableInfiniteScroll: usePeekLayout,
            padEnds: usePeekLayout,
            scrollPhysics: const BouncingScrollPhysics(),
            clipBehavior: Clip.none,
            onPageChanged: (index, _) => _currentIndex.value = index,
          ),
          itemBuilder: (context, index, _) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Align(
                alignment: Alignment.topCenter,
                child: MyBusinessAdBannerCard(
                  ad: ads[index],
                  creditsRemaining:
                      index == 0 ? widget.creditsRemaining : null,
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 8),
        Obx(
          () => Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              ads.length,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 280),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                height: 6,
                width: _currentIndex.value == index ? 18 : 6,
                decoration: BoxDecoration(
                  color: _currentIndex.value == index
                      ? colorScheme.primary
                      : colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
