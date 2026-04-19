import 'package:get/get.dart';
import 'package:loci/presentation/bindings/auth_bindings.dart';
import 'package:loci/presentation/bindings/bottom_nav_binding.dart';
import 'package:loci/presentation/bindings/event_bindings.dart';
import 'package:loci/presentation/bindings/my_business_bindings.dart';
import 'package:loci/presentation/bindings/routes_bindings.dart';
import 'package:loci/presentation/pages/auth/forget_pass_screen.dart';
import 'package:loci/presentation/pages/auth/login_screen.dart';
import 'package:loci/presentation/pages/auth/otp_screen.dart';
import 'package:loci/presentation/pages/auth/reset_pass_sceen.dart';
import 'package:loci/presentation/pages/auth/signup_screen.dart';
import 'package:loci/presentation/pages/browse/business_profile_screen.dart';
import 'package:loci/presentation/pages/checkin/check_in_screen.dart';
import 'package:loci/presentation/pages/clam_business/clam_my_business.dart';
import 'package:loci/presentation/pages/clam_business/create_ad.dart';
import 'package:loci/presentation/pages/clam_business/manual_claim_business.dart';
import 'package:loci/presentation/pages/clam_business/my_buisness_profile.dart';
import 'package:loci/presentation/pages/clam_business/search_my_business.dart';
import 'package:loci/presentation/pages/communites/community_member_screen.dart';
import 'package:loci/presentation/pages/communites/create_anouncement_screen.dart';
import 'package:loci/presentation/pages/event/event_details.dart';
import 'package:loci/presentation/pages/explore_activity/edit_event_screen.dart';
import 'package:loci/presentation/pages/explore_activity/edit_raffles_screen.dart';
import 'package:loci/presentation/pages/explore_activity/edit_routes_screen.dart';
import 'package:loci/presentation/pages/explore_activity/explore_activity_screen.dart';
import 'package:loci/presentation/pages/explore_activity/recent_activity.dart';
import 'package:loci/presentation/pages/explore_activity/total_checkin_screen.dart';
import 'package:loci/presentation/pages/explore_activity/total_rsvp_screen.dart';
import 'package:loci/presentation/pages/explore_activity/view_event_screen.dart';
import 'package:loci/presentation/pages/explore_activity/view_raffles_screen.dart';
import 'package:loci/presentation/pages/explore_activity/view_route_screen.dart';
import 'package:loci/presentation/pages/explore_routes/explore_routes_screen.dart';
import 'package:loci/presentation/pages/explore_routes/route_details_screen.dart';
import 'package:loci/presentation/pages/message/chat_list_screen.dart';
import 'package:loci/presentation/pages/message/message_screen.dart';
import 'package:loci/presentation/pages/network/connection_screen.dart';
import 'package:loci/presentation/pages/network/meeting_invitation_screen.dart';
import 'package:loci/presentation/pages/network/metting_screen.dart';
import 'package:loci/presentation/pages/network/referrals_invitation_screen.dart';
import 'package:loci/presentation/pages/network/referrals_screen.dart';
import 'package:loci/presentation/pages/network/schedule_meeting_screen.dart';
import 'package:loci/presentation/pages/network/send_new_referrals_screen.dart';
import 'package:loci/presentation/pages/onboarding/onboarding_screen.dart';
import 'package:loci/presentation/pages/profile/about_screen.dart';
import 'package:loci/presentation/pages/profile/change_password_screen.dart';
import 'package:loci/presentation/pages/profile/delete_account_screen.dart';
import 'package:loci/presentation/pages/profile/terms_screen.dart';
import 'package:loci/presentation/pages/raffles/active_raffles_screen.dart';
import 'package:loci/presentation/pages/raffles/raffles_details_screen.dart';
import 'package:loci/presentation/pages/splash/splash_screen.dart';
import 'package:loci/presentation/pages/subscription/subscription_screen.dart';
import 'package:loci/presentation/widgets/common/main_bottom_nav.dart';
import 'package:loci/routes/app_routes.dart';

import '../presentation/bindings/explore_activity_bindings.dart';
import '../presentation/pages/browse/browse_businesses.dart';
import '../presentation/pages/explore_activity/creat_activity_screen.dart';
import '../presentation/pages/notification/notification_screen.dart';
import '../presentation/pages/profile/settings_screen.dart';

abstract class AppPages {
  static const String initialRoutes = AppRoutes.splash;

  static final pages = [
    /// ==========================Auth=============================
    GetPage(name: AppRoutes.splash, page: () => SplashScreen()),
    GetPage(name: AppRoutes.onBoarding, page: () => OnboardingScreen()),

    GetPage(
      name: AppRoutes.login,
      page: () => LoginScreen(),
      binding: AuthBinding(),
    ),

    GetPage(
      name: AppRoutes.signup,
      page: () => SignupScreen(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.forgetPass,
      page: () => ForgetPassScreen(),
      binding: AuthBinding(),
    ),
    GetPage(name: AppRoutes.otp, page: () => OtpScreen(),binding: AuthBinding()),
    GetPage(name: AppRoutes.passReset, page: () => ResetPassScreen(),binding: AuthBinding()),

    /// ==========================Bottom Nav=============================
    GetPage(name: AppRoutes.bottomNav, page: () => MainBottomNav(),binding: BottomNavBinding()),

    // ----- event details
    GetPage(name: AppRoutes.eventDetails, page: () => EventDetails(),binding: EventBindings()),

    // ----- browse business
    GetPage(name: AppRoutes.browseBusiness, page: () => BrowseBusinesses()),
    GetPage(
      name: AppRoutes.businessProfile,
      page: () => BusinessProfileScreen(),
    ),

    // ----- Network
    GetPage(name: AppRoutes.referral, page: () => ReferralsScreen()),
    GetPage(name: AppRoutes.meeting, page: () => MeetingScreen()),
    GetPage(name: AppRoutes.connection, page: () => ConnectionScreen()),
    GetPage(name: AppRoutes.sendReferral, page: () => SendNewReferralsScreen()),
    GetPage(
      name: AppRoutes.scheduleMeeting,
      page: () => ScheduleMeetingScreen(),
    ),
    GetPage(
      name: AppRoutes.referralsInvitation,
      page: () => ReferralsInvitationScreen(),
    ),
    GetPage(
      name: AppRoutes.meetingInvitation,
      page: () => MeetingInvitationScreen(),
    ),

    // ----- CheckIn
    GetPage(name: AppRoutes.checkIn, page: () => CheckInScreen()),

    //--explore routes
    GetPage(name: AppRoutes.exploreRoutes, page: () => ExploreRoutesPage(),binding: BottomNavBinding()),
    GetPage(name: AppRoutes.routeDetails, page: () => RouteDetailsScreen(),binding: BottomNavBinding()),
    //--raffles
    GetPage(name: AppRoutes.activeRaffles, page: () => ActiveRafflesPage()),
    GetPage(name: AppRoutes.rafflesDetails, page: () => RafflesDetailsScreen()),

    //---clam my business
    GetPage(name: AppRoutes.searchBusiness, page: () => SearchMyBusiness(),binding: MyBusinessBindings()),
    GetPage(name: AppRoutes.clamBusinessProfile, page: () => ClamMyBusiness()),
    GetPage(name: AppRoutes.myBusinessProfile, page: () => MyBusinessProfile(),binding: MyBusinessBindings()),
    GetPage(
      name: AppRoutes.manualClaimBusiness,
      page: () => ManualClaimBusiness(),
    ),
    GetPage(name: AppRoutes.createAdd, page: () => CreateAd()),

    //---explore activity
    GetPage(
      name: AppRoutes.exploreActivity,
      page: () => ExploreActivityScreen(),
      binding: ExploreActivityBindings(),
    ),
    GetPage(name: AppRoutes.createActivity, page: () => CreateActivityScreen(),binding: ExploreActivityBindings()),
    GetPage(name: AppRoutes.editEvent, page: () => EditEventScreen()),
    GetPage(name: AppRoutes.editRaffles, page: () => EditRafflesScreen()),
    GetPage(name: AppRoutes.editRoutes, page: () => EditRoutesScreen(),binding: ExploreActivityBindings()),

    GetPage(name: AppRoutes.viewEvent, page: () => ViewEventScreen(),binding: ExploreActivityBindings()),
    GetPage(name: AppRoutes.viewRoutes, page: () => ViewRouteScreen(),binding: ExploreActivityBindings()),
    GetPage(name: AppRoutes.viewRaffles, page: () => ViewRafflesScreen(),binding: ExploreActivityBindings()),

    GetPage(name: AppRoutes.viewTotalCheckIn, page: () => TotalCheckInScreen()),
    GetPage(name: AppRoutes.viewTotalRSVP, page: () => TotalRsvpScreen()),

    //---create activity
    GetPage(name: AppRoutes.recentActivity, page: () => RecentActivity()),

    //---community
    GetPage(
      name: AppRoutes.communityMemberScreen,
      page: () => CommunityMemberScreen(),
    ),
    GetPage(
      name: AppRoutes.createAnnouncement,
      page: () => CreateAnnouncementScreen(),
    ),

    //----profile
    GetPage(name: AppRoutes.changePassword, page: () => ChangePasswordScreen()),
    GetPage(name: AppRoutes.about, page: () => AboutScreen()),
    GetPage(name: AppRoutes.settings, page: () => SettingsScreen()),
    GetPage(name: AppRoutes.terms, page: () => TermsScreen()),
    GetPage(name: AppRoutes.deleteAccount, page: () => DeleteAccountScreen()),

    //appbar screen
    GetPage(name: AppRoutes.chatList, page: () => ChatListScreen()),
    GetPage(name: AppRoutes.message, page: () => MessageScreen()),
    GetPage(name: AppRoutes.notification, page: () => NotificationScreen()),

    GetPage(name: AppRoutes.subscription, page: () => SubscriptionScreen()),
  ];
}
