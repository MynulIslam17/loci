import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/app_colors.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/data/models/carousel_data.dart';

class CustomCarousel extends StatefulWidget {
  final List<CarouselData> carouselData;
  final double height;
  final bool autoPlay;
  final double viewportFraction;
  final double borderRadius;
  final Color? activeIndicatorColor;
  final Color? inactiveIndicatorColor;
  final Duration autoPlayInterval;

  const CustomCarousel({
    super.key,
    required this.carouselData,
    this.height = 208,
    this.autoPlay = true,
    this.viewportFraction = 0.85,
    this.borderRadius = 15,
    this.activeIndicatorColor,
    this.inactiveIndicatorColor,
    this.autoPlayInterval = const Duration(seconds: 3),
  });

  @override
  State<CustomCarousel> createState() => _CustomCarouselState();
}

class _CustomCarouselState extends State<CustomCarousel> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CarouselSlider(
          options: CarouselOptions(
            height: widget.height,
            autoPlay: widget.autoPlay,
            autoPlayInterval: widget.autoPlayInterval,
            enlargeCenterPage: true,
            viewportFraction: widget.viewportFraction,
            autoPlayCurve: Curves.fastOutSlowIn,
            autoPlayAnimationDuration: const Duration(milliseconds: 800),
            onPageChanged: (index, reason) {
              setState(() {
                _currentIndex = index;
              });
            },
          ),
          items: widget.carouselData.map((item) {
            return Stack(
              children: [
                // 1. The Image Background
                Container(
                  width: MediaQuery.sizeOf(context).width,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(widget.borderRadius),
                    image: DecorationImage(
                      image: AssetImage(item.placeImage),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Align(
                    alignment: Alignment.topRight,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.cloud,
                          size: 24,
                          color: AppColors.base500,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          "${item.placeWeather}\u00B0C",
                          style: AppTextStyle.textMd(color: AppColors.base500),
                        ),
                      ],
                    ),
                  ),
                ),

                ///place Name & location
                Positioned(
                  bottom: 30,
                  left: 20,
                  right: 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.placeName,
                        style: AppTextStyle.textMd(color: AppColors.base500),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            color: AppColors.base500,
                            size: 14,
                          ),
                          const SizedBox(width: 6,),
                          Expanded(
                            child: Text(
                              item.placeLocation,
                              style: AppTextStyle.textXs(color: AppColors.base500,),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              softWrap: true,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            );
          }).toList(),
        ),

        // Indicators
        Positioned(
          bottom: 15,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              widget.carouselData.length,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                height: 8,
                width: _currentIndex == index ? 27 : 10,
                decoration: BoxDecoration(
                  color: _currentIndex == index
                      ? (widget.activeIndicatorColor ??
                            context.colorScheme.primary)
                      : (widget.inactiveIndicatorColor ?? AppColors.base500),
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
