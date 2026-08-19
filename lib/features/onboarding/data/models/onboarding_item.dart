import 'package:loci/gen/assets.gen.dart';

/// Represents a single onboarding step.
///
/// To update the text, descriptions, or images, simply edit the list in [defaultItems].
class OnboardingItem {
  final String title;
  final String description;
  final String backImagePath;
  final String frontImagePath;

  const OnboardingItem({
    required this.title,
    required this.description,
    required this.backImagePath,
    required this.frontImagePath,
  });

  /// Default onboarding slides shown during first-time launch.
  static final List<OnboardingItem> defaultItems = [
    OnboardingItem(
      title: 'Discover Together',
      description:
          'Connect with locals by asking questions, sharing answers, and discovering great businesses.',
      backImagePath: Assets.images.onimg1.path,
      frontImagePath: Assets.images.onimg2.path,
    ),
    OnboardingItem(
      title: 'Discover your Place',
      description:
          'Find local events, meet friendly faces, and discover your place together.',
      backImagePath: Assets.images.onimg3.path,
      frontImagePath: Assets.images.onimg4.path,
    ),
    OnboardingItem(
      title: 'Where locals Lead',
      description: 'Simplify networking and elevate your events.',
      backImagePath: Assets.images.onimg5.path,
      frontImagePath: Assets.images.onimg6.path,
    ),
  ];
}
