import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:loci/core/theme/theme_extention.dart'; // Ensure this path is correct for your project

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Track the current active index of the carousel
  int _currentIndex = 0;

  // Your list of image paths
  final List<String> _images = [
    "assets/images/finedine.png",
    "assets/images/restu.png",
    "assets/images/finedine.png",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colorScheme.surface,
      body: SingleChildScrollView(
        // Added scroll view to prevent overflow if you add more content
        child: Column(
          children: [
            const SizedBox(height: 16), // Padding from the AppBar area
            // --- CAROUSEL SLIDER ---

            Stack(
              children: [

            ],
            )
            CarouselSlider(
              options: CarouselOptions(
                height: 208,
                autoPlay: true,
                enlargeCenterPage: true,
                viewportFraction:
                    0.85, // Slightly wider to see more of the side images
                autoPlayCurve: Curves.fastOutSlowIn,
                autoPlayAnimationDuration: const Duration(milliseconds: 800),
                onPageChanged: (index, reason) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
              ),
              items: _images.map((imagePath) {
                return Container(
                  width: MediaQuery.sizeOf(context).width,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    image: DecorationImage(
                      image: AssetImage(imagePath),
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 12),

            // --- ANIMATED DOTS INDICATOR ---
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _images.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 7),
                  height: 8,
                  width: _currentIndex == index ? 27 : 10,
                  decoration: BoxDecoration(
                    color: _currentIndex == index
                        ? context.colorScheme.primary
                        : context.colorScheme.onSurface,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),


          ],
        ),
      ),
    );
  }
}
