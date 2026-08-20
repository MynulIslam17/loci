import 'package:flutter/material.dart';
import 'package:loci/core/enums/category_enum.dart';
import 'package:loci/gen/assets.gen.dart';

class BusinessCategoryUI {
  static String label(BusinessCategory category) {
    switch (category) {
      case BusinessCategory.boutiquesAndBeauty:
        return 'Boutiques & Beauty';
      case BusinessCategory.foodie:
        return 'Foodie';
      case BusinessCategory.adventure:
        return 'Adventure';
      case BusinessCategory.partyLikeALoci:
        return 'Party Like a Loci';
      case BusinessCategory.wellness:
        return 'Wellness';
      case BusinessCategory.homeAndRepair:
        return 'Home and Repair';
      case BusinessCategory.nonProfits:
        return 'Non Profits';
      case BusinessCategory.localServices:
        return 'Local Services';
    }
  }

  static String icon(BusinessCategory category) {
    switch (category) {
      case BusinessCategory.boutiquesAndBeauty:
        return Assets.icons.care;
      case BusinessCategory.foodie:
        return Assets.icons.foodie;
      case BusinessCategory.adventure:
        return Assets.icons.advanture;
      case BusinessCategory.partyLikeALoci:
        return Assets.icons.party;
      case BusinessCategory.wellness:
        return Assets.icons.helth;
      case BusinessCategory.homeAndRepair:
        return Assets.icons.repair;
      case BusinessCategory.nonProfits:
        return Assets.icons.nonProfit;
      case BusinessCategory.localServices:
        return Assets.icons.local;
    }
  }

  /// Modern, sophisticated and professional accent colors for each category.
  static Color accentColor(BusinessCategory category) {
    switch (category) {
      case BusinessCategory.boutiquesAndBeauty:
        return const Color(0xFFE11D48); // Modern Rose
      case BusinessCategory.foodie:
        return const Color(0xFFEA580C); // Warm Terracotta / Orange
      case BusinessCategory.adventure:
        return const Color(0xFF0D9488); // Professional Teal
      case BusinessCategory.partyLikeALoci:
        return const Color(0xFF7C3AED); // Modern Violet
      case BusinessCategory.wellness:
        return const Color(0xFF059669); // Forest Emerald
      case BusinessCategory.homeAndRepair:
        return const Color(0xFF2563EB); // Royal Blue
      case BusinessCategory.nonProfits:
        return const Color(0xFFDC2626); // Crimson Red
      case BusinessCategory.localServices:
        return const Color(0xFF4F46E5); // Deep Indigo
    }
  }

  static String toApi(BusinessCategory category) {
    switch (category) {
      case BusinessCategory.boutiquesAndBeauty:
        return 'Boutiques & Beauty';
      case BusinessCategory.foodie:
        return 'Foodie';
      case BusinessCategory.adventure:
        return 'Adventure';
      case BusinessCategory.partyLikeALoci:
        return 'Party Like a Loci';
      case BusinessCategory.wellness:
        return 'Wellness';
      case BusinessCategory.homeAndRepair:
        return 'Home and Repair';
      case BusinessCategory.nonProfits:
        return 'Non Profits';
      case BusinessCategory.localServices:
        return 'Local Services';
    }
  }
}
