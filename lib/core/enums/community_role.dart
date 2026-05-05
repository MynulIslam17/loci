enum CommunityRole {
  member,
  owner;

  static CommunityRole fromString(String? value) {
    switch (value?.toLowerCase()) {
      case "member":
        return CommunityRole.member;
      case "owner":
        return CommunityRole.owner;
      default:
        return CommunityRole.member;
    }
  }


  String get label{
    switch(this){
      case CommunityRole.member :
        return "member";
        case CommunityRole.owner :
        return "owner";
    }
  }


  //  To sending api
  String get toJson {
    switch (this) {
      case CommunityRole.member:
        return 'member';
      case CommunityRole.owner:
        return 'owner';
    }
  }







}
