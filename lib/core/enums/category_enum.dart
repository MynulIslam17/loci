enum BusinessCategory {
  boutiquesAndBeauty,
  foodie,
  adventure,
  partyLikeALoci,
  wellness,
  homeAndRepair,
  nonProfits,
  localServices;

  /// =========================
  /// FROM STRING (API → APP)
  /// =========================
  static BusinessCategory fromString(String? value) {
    switch (value) {
      case 'Boutiques & Beauty':
        return BusinessCategory.boutiquesAndBeauty;
      case 'Foodie':
        return BusinessCategory.foodie;
      case 'Adventure':
        return BusinessCategory.adventure;
      case 'Party Like a Loci':
        return BusinessCategory.partyLikeALoci;
      case 'Wellness':
        return BusinessCategory.wellness;
      case 'Home and Repair':
        return BusinessCategory.homeAndRepair;
      case 'Non Profits':
        return BusinessCategory.nonProfits;
      case 'Local Services':
        return BusinessCategory.localServices;
      default:
        return BusinessCategory.foodie; // default fallback
    }
  }

  /// =========================
  /// LABEL (FOR UI)
  /// =========================
  String get label {
    switch (this) {
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

  /// =========================
  /// TO JSON (APP → API)
  /// =========================
  String get toJson {
    switch (this) {
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