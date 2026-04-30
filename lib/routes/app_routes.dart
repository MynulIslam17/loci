
abstract class AppRoutes {


  //--- auth---
  static const String splash = '/splash';
  static const String onBoarding = '/onBoarding';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String forgetPass = '/forgetPass';
  static const String otp = '/otp';
  static const String passReset = '/passReset';


  static const String bottomNav = '/bottomNav';


  // --- event ---

  static const String eventDetails = '/eventDetails';

  //--browse business
  static const String browseBusiness = '/browseBusiness';
  static const String businessProfile = '/businessProfile';
  static const String allReviewScreen = '/allReviewScreen';

  //---network----
static const String connection="/connection";
static const String meeting="/meeting";
static const String referral="/referral";
static const String sendReferral="/sendReferral";
static const String scheduleMeeting="/scheduleMeeting";
static const String referralsInvitation="/referralsInvitation";
static const String meetingInvitation="/meetingInvitation";


//---checkIn(barcode)
  static const String checkIn="/checkIn";
  static const String myQrCode="/myQrcode";

  //---screens on drawer
  static const String exploreRoutes="/exploreRoutes";
  static const String routeDetails="/routeDetails";
  static const String activeRaffles="/activeRaffles";
  static const String  rafflesDetails="/rafflesDetails";

  //--- clam my business

  static const String  searchBusiness="/searchBusiness";
  static const String  clamBusinessProfile="/clamBusinessProfile";
  static const String  myBusinessProfile="/myBusinessProfile";
  static const String  manualClaimBusiness="/manualClaimBusiness";
  static const String  createAdd="/createAdd";

  //----explore activity(claim business)
  static const String  exploreActivity="/exploreActivity";
  static const String  createActivity="/createActivity";
  static const String  editEvent="/editEvent";
  static const String  editRoutes="/editRoutes";
  static const String  editRaffles="/editRaffles";

  static const String  viewEvent="/viewEvent";
  static const String  viewTotalRSVP="/viewTotalRSVP";
  static const String  viewTotalCheckIn="/viewTotalCheckIn";

  static const String  viewRoutes="/viewRoutes";
  static const String  viewRaffles="/viewRaffles";

  //-----recent Activity
  static const String  recentActivity="/recentActivity";


//---community
  static const communityScreen = '/communityScreen';
  static const communityMemberScreen = '/communityMemberScreen';
  static const createAnnouncement = '/createAnnouncement';



  //-----profile

  static const changePassword = '/changePassword';
  static const about = '/about';
  static const settings = '/settings';
  static const terms = '/terms';
  static const deleteAccount = '/deleteAccount';


  // appbar pages

  static const chatList = '/chatList';
  static const message = '/message';
  static const notification = '/notification';

  //----subscription

static const subscription="/subscription";






}