import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/presentation/widgets/custom_image_container.dart';
import 'package:loci/presentation/widgets/custom_text_field.dart';

import '../../../gen/assets.gen.dart';
import '../../widgets/review_card.dart';

class BusinessProfileScreen extends StatefulWidget {
  const BusinessProfileScreen({super.key});

  @override
  State<BusinessProfileScreen> createState() => _BusinessProfileScreenState();
}

class _BusinessProfileScreenState extends State<BusinessProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colorScheme.surface,
      appBar: AppBar(
        title: Text(
          "Business profile",
          style: AppTextStyle.textLg(weight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          children: [
            // --- 1. Circular Business Logo ---
            Center(
              child: Container(
                height: 140,
                width: 140,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,

                  border: Border.all(
                    color: context.colorScheme.primary,
                    width: 1.5,
                  ),
                ),
                child: CustomCachedImage(
                  imageUrl: Assets.images.companyLogo.path,
                  isCircle: true,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // --- 2. Business Name ---
            Text(
              "Marland Clutch",
              style: AppTextStyle.textXl(
                weight: FontWeight.w700,
                color: context.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 12),

            // --- 3. Contact Information ---
            Text(
              "23801 Hoover Rd, Warren, MI 48089",
              style: AppTextStyle.textXs(
                color: context.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              "+1 800-216-3515",
              style: AppTextStyle.textXs(
                color: context.colorScheme.onSurfaceVariant,
                weight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),

            // --- 4. Tags/Categories ---
            Text(
              "Maintenance & Repair  |  Services & More",
              style: AppTextStyle.textXs(
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),

            // --- 5. Ratings ---
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "2 Review ",
                  style: AppTextStyle.textXs(color: Colors.grey[600]),
                ),
                ...List.generate(
                  5,
                  (index) => const Icon(
                    Icons.star,
                    color: Colors.orangeAccent,
                    size: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // --- 6. Add to List Button ---
            SizedBox(
              width: 180,
              height: 45,
              child: ElevatedButton.icon(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.colorScheme.primary,
                  foregroundColor: context.colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
                icon: const Icon(Icons.add, size: 20),
                label: const Text("Add to List"),
              ),
            ),
            const SizedBox(height: 32),

            // --- 7. Business Description Section ---
            Card(
              elevation: 2,
              color: context.colorScheme.surfaceContainerHigh,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                child: Text(
                  "Marland Clutch, founded in 1931, is a prominent global manufacturer specializing in heavy duty industrial backstopping and overrunning clutches. The company is currently a brand of Regal Rexnord Corporation.\n\n"
                  "Marland Clutch, founded in 1931, is a prominent global manufacturer specializing in heavy duty industrial backstopping and overrunning clutches. The company is currently a brand of Regal Rexnord Corporation.",
                  style: AppTextStyle.textXs(
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.start,
                ),
              ),
            ),
            const SizedBox(height: 32),
            Align(
              alignment: Alignment.topLeft,
              child: Text(
                "Photos",
                style: AppTextStyle.textXl(
                  weight: FontWeight.w700,
                  color: context.colorScheme.primary,
                ),
              ),
            ),

            const SizedBox(height: 6),
            // --- 8. Business photos Section ---
            GridView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
              ),
              itemBuilder: (context, index) {
                return Card(
                  color: context.colorScheme.surfaceContainerHigh,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CustomCachedImage(
                      imageUrl: "https://i.pravatar.cc/150?u=$index",


                    ),
                  ),
                );
              },
              itemCount: 7,
            ),

            const SizedBox(height: 32),

            // --- 9. Write Review Section ---
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              color: context.colorScheme.surfaceContainerHigh,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- Header Row with Title and Rating ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Write your review",
                          style: AppTextStyle.textSm(
                            // Adjusted to Sm for better fit on card
                            weight: FontWeight.w700,
                            color: context.colorScheme.onSurface,
                          ),
                        ),
                        // Interactive Rating Bar
                        RatingBar.builder(
                          initialRating: 0,
                          minRating: 1,
                          direction: Axis.horizontal,
                          allowHalfRating: true,
                          itemCount: 5,
                          itemSize:
                              18, // Slightly smaller to fit the row height
                          unratedColor: context.colorScheme.outline.withOpacity(
                            0.5,
                          ),
                          itemPadding: const EdgeInsets.symmetric(
                            horizontal: 1.0,
                          ),
                          itemBuilder: (context, _) =>
                              const Icon(Icons.star, color: Colors.amber),
                          onRatingUpdate: (rating) {
                            debugPrint("New Rating: $rating");
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // --- Review Input Section ---
                    CustomTextField(
                      hintText: "Write your reviews within 100 words....",
                      fontSize: 12,
                      textColor: context.colorScheme.onSurface,

                      hintTextColor: context.colorScheme.onSurfaceVariant,
                      borderColor: context.colorScheme.outline,
                      maxLine: 4,
                      suffixIcon: Padding(
                        padding: const EdgeInsets.all(2),
                        child: IconButton(
                          onPressed: () {},
                          icon: Icon(Icons.send),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [

                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    "Reviews",
                    style: AppTextStyle.textXl(
                      weight: FontWeight.w700,
                      color: context.colorScheme.primary,
                    ),
                  ),
                ),
                
                Expanded(child: Align(
                    alignment: Alignment.topRight,
                    child: TextButton(onPressed: (){}, child: Text("View all",style: AppTextStyle.textXs(),))))



              ],
            ),

            // --- 10. Review List ---
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 2,
              itemBuilder: (context, index) {
                return ReviewCard(
                  name: "Alexandra ssssBroke",
                  businessName: "Barclay Pizza",
                  rating: 5,
                  reviewText: "This was one of the most epic experience...",
                  imageUrl: "https://i.pravatar.cc/150?u=1",
                  onMenuTap: () {

                  },
                );
              },
            ),




          ],
        ),
      ),
    );
  }
}
