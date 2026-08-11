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
    // Headroom for the [enlargeCenterPage] scale on the centre card.
    final slideHeight = _maxSlideHeight(context) + 14;

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
        const SizedBox(height: 6),
        // Page dots below the carousel, inside a theme-aware pill so they stay
        // visible on both light and dark surfaces.
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: colorScheme.outlineVariant.withValues(alpha: 0.5),
            ),
          ),
          child: Obx(
            () => Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(ads.length, (index) {
                final bool selected = _currentIndex.value == index;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 280),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  height: 6,
                  width: selected ? 18 : 6,
                  decoration: BoxDecoration(
                    color: selected
                        ? colorScheme.primary
                        : colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
          ),
        ),
      ],
    );
  }
}
