

import '../../../../core/enums/category_enum.dart';
import '../../../../gen/assets.gen.dart';

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
        return 'Party Like raffles Loci';
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