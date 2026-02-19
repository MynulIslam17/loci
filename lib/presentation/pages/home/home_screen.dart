import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:loci/core/theme/app_colors.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/data/carousel_data.dart';
import 'package:loci/presentation/widgets/custom_carousel.dart'; // Ensure this path is correct for your project

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {


 final List<CarouselData> bannerData=[
   CarouselData(placeName: "Barclay Prime", placeLocation: "237 S ssssssssssss18th St, Philadelphia, PA 19103", placeWeather: "30", placeImage: "assets/images/finedine.png"),
   CarouselData(placeName: "Pizzaburge", placeLocation: "Dhanmondi, PA 19103", placeWeather: "44", placeImage: "assets/images/restu.png"),
   CarouselData(placeName: "Burbger King", placeLocation: "Khilgaon", placeWeather: "20", placeImage: "assets/images/finedine.png"),
 ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colorScheme.surface,
      body: SingleChildScrollView(

        child: Column(
          children: [
            const SizedBox(height: 16),
            // --- CAROUSEL SLIDER ---
          CustomCarousel(carouselData: bannerData,),


            Card(
              color: context.colorScheme.surfaceContainerHigh,
              child:Padding(
                padding: const EdgeInsets.all(80.0),
                child: Text("afafaf"),
              ),
            )
            
            
          ],
        ),
      ),
    );
  }
}
