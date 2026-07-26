import 'package:get/get.dart';
import 'package:loci/features/auth/presentation/bindings/auth_binding.dart';
import 'package:loci/features/checkin/presentation/bindings/checkin_binding.dart';
import 'package:loci/features/main_nav/presentation/bindings/bottom_nav_binding.dart';
import 'package:loci/features/browse_business/presentation/bindings/browse_business_binding.dart';
import 'package:loci/features/community/presentation/bindings/community_binding.dart';
import 'package:loci/features/main_nav/presentation/bindings/drawer_binding.dart';
import 'package:loci/features/event/presentation/bindings/event_binding.dart';
import 'package:loci/features/my_business/presentation/bindings/my_business_binding.dart';
import 'package:loci/features/network/presentation/bindings/meetings_binding.dart';
import 'package:loci/features/network/presentation/bindings/referrals_binding.dart';
import 'package:loci/features/auth/presentation/pages/forget_pass_screen.dart';
import 'package:loci/features/auth/presentation/pages/login_screen.dart';
import 'package:loci/features/auth/presentation/pages/otp_screen.dart';
import 'package:loci/features/auth/presentation/pages/reset_pass_screen.dart';
import 'package:loci/features/auth/presentation/pages/signup_screen.dart';
import 'package:loci/features/browse_business/presentation/pages/all_review_screen.dart';
import 'package:loci/features/my_business/presentation/pages/my_business_all_reviews_screen.dart';
import 'package:loci/features/browse_business/presentation/pages/business_profile_screen.dart';
import 'package:loci/features/checkin/presentation/pages/check_in_screen.dart';
import 'package:loci/features/my_business/presentation/pages/claim_my_business_screen.dart';
import 'package:loci/features/my_business/presentation/pages/create_ad_screen.dart';
import 'package:loci/features/my_business/presentation/pages/manual_claim_business_screen.dart';
import 'package:loci/features/my_business/presentation/pages/my_business_profile_screen.dart';
import 'package:loci/features/my_business/presentation/pages/search_my_business_screen.dart';
import 'package:loci/features/community/presentation/pages/all_community_screen.dart';
import 'package:loci/features/community/presentation/pages/community_member_screen.dart';
import 'package:loci/features/community/presentation/pages/community_screen.dart';
import 'package:loci/features/community/presentation/pages/create_announcement_screen.dart';
import 'package:loci/features/event/presentation/pages/event_details_screen.dart';
import 'package:loci/features/explore_activity/presentation/pages/edit_event_screen.dart';
import 'package:loci/features/explore_activity/presentation/pages/edit_raffles_screen.dart';
import 'package:loci/features/explore_activity/presentation/pages/edit_routes_screen.dart';
import 'package:loci/features/explore_activity/presentation/pages/explore_activity_screen.dart';
import 'package:loci/features/recent_activity/presentation/pages/recent_activity_screen.dart';
import 'package:loci/features/explore_activity/presentation/pages/total_checkin_screen.dart';
import 'package:loci/features/explore_activity/presentation/pages/total_rsvp_screen.dart';
import 'package:loci/features/explore_activity/presentation/pages/view_event_screen.dart';
import 'package:loci/features/explore_activity/presentation/pages/view_raffles_screen.dart';
import 'package:loci/features/explore_activity/presentation/pages/view_route_screen.dart';
import 'package:loci/features/routes/presentation/pages/explore_routes_screen.dart';
import 'package:loci/features/routes/presentation/pages/route_details_screen.dart';
import 'package:loci/features/chat/presentation/pages/chat_list_screen.dart';
import 'package:loci/features/chat/presentation/pages/message_screen.dart';
import 'package:loci/features/qr_code/presentation/pages/my_qr_code_screen.dart';
import 'package:loci/features/network/presentation/pages/connection_screen.dart';
import 'package:loci/features/network/presentation/pages/meetings/meeting_invitation_screen.dart';
import 'package:loci/features/network/presentation/pages/meetings/meeting_screen.dart';
import 'package:loci/features/network/presentation/pages/referrals/referrals_screen.dart';
import 'package:loci/features/network/presentation/pages/meetings/schedule_meeting_screen.dart';
import 'package:loci/features/network/presentation/pages/referrals/send_new_referrals_screen.dart';
import 'package:loci/features/onboarding/presentation/pages/onboarding_screen.dart';
import 'package:loci/features/profile/presentation/pages/about_screen.dart';
import 'package:loci/features/profile/presentation/pages/change_password_screen.dart';
import 'package:loci/features/profile/presentation/pages/delete_account_screen.dart';
import 'package:loci/features/profile/presentation/pages/terms_screen.dart';
import 'package:loci/features/raffles/presentation/pages/active_raffles_screen.dart';
import 'package:loci/features/raffles/presentation/pages/raffles_details_screen.dart';
import 'package:loci/features/splash/presentation/pages/splash_screen.dart';
import 'package:loci/features/subscription/presentation/pages/subscription_screen.dart';
import 'package:loci/features/subscription/presentation/pages/my_subscription_screen.dart';
import 'package:loci/features/subscription/presentation/bindings/my_subscription_binding.dart';
import 'package:loci/features/main_nav/presentation/pages/main_bottom_nav_screen.dart';
import 'package:loci/routes/app_routes.dart';

import 'package:loci/features/explore_activity/presentation/bindings/explore_activity_binding.dart';
import 'package:loci/features/browse_business/presentation/pages/browse_businesses_screen.dart';
import 'package:loci/features/explore_activity/presentation/pages/create_activity_screen.dart';
import 'package:loci/features/notification/presentation/pages/notification_screen.dart';
import 'package:loci/features/profile/presentation/pages/settings_screen.dart';
import 'package:loci/features/profile/presentation/bindings/profile_binding.dart';

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
    GetPage(
      name: AppRoutes.otp,
      page: () => OtpScreen(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.passReset,
      page: () => ResetPassScreen(),
      binding: AuthBinding(),
    ),

    /// ==========================Bottom Nav=============================
    GetPage(
      name: AppRoutes.bottomNav,
      page: () => MainBottomNav(),
      binding: BottomNavBinding(),
    ),

    // ----- event details
    GetPage(
      name: AppRoutes.eventDetails,
      page: () => EventDetails(),
      binding: EventBindings(),
    ),

    // ----- browse business
    GetPage(
      name: AppRoutes.browseBusiness,
      page: () => BrowseBusinesses(),
      binding: BrowseBusinessBindings(),
    ),
    GetPage(
      name: AppRoutes.businessProfile,
      page: () => BusinessProfileScreen(),
      binding: BrowseBusinessBindings(),
    ),

    GetPage(
      name: AppRoutes.allReviewScreen,
      page: () => const AllReviewsScreen(),
      binding: BrowseBusinessBindings(),
    ),

    // ----- Network
    GetPage(
      name: AppRoutes.referral,
      page: () => ReferralsScreen(),
      binding: ReferralsBindings(),
    ),
    GetPage(
      name: AppRoutes.meeting,
      page: () => MeetingScreen(),
      binding: MeetingsBindings(),
    ),
    GetPage(
      name: AppRoutes.connection,
      page: () => ConnectionScreen(),
      binding: BottomNavBinding(),
    ),
    GetPage(
      name: AppRoutes.sendReferral,
      page: () => SendNewReferralsScreen(),
      binding: ReferralsBindings(),
    ),
    GetPage(
      name: AppRoutes.scheduleMeeting,
      page: () => ScheduleMeetingScreen(),
      binding: MeetingsBindings(),
    ),

    GetPage(
      name: AppRoutes.meetingInvitation,
      page: () => MeetingInvitationScreen(),
    ),

    // ----- CheckIn
    GetPage(
      name: AppRoutes.checkIn,
      page: () => CheckInScreen(),
      binding: CheckinBinding(),
    ),
    //----myQrcode
    GetPage(
      name: AppRoutes.myQrCode,
      page: () => MyQrcodeScreen(),
      binding: DrawerBindings(),
    ),

    //--explore routes
    GetPage(
      name: AppRoutes.exploreRoutes,
      page: () => ExploreRoutesPage(),
      binding: BottomNavBinding(),
    ),
    GetPage(
      name: AppRoutes.routeDetails,
      page: () => RouteDetailsScreen(),
      binding: BottomNavBinding(),
    ),
    //--raffles
    GetPage(
      name: AppRoutes.activeRaffles,
      page: () => ActiveRafflesPage(),
      binding: BottomNavBinding(),
    ),
    GetPage(
      name: AppRoutes.rafflesDetails,
      page: () => RafflesDetailsScreen(),
      binding: BottomNavBinding(),
    ),

    //---clam my business
    GetPage(
      name: AppRoutes.searchBusiness,
      page: () => SearchMyBusiness(),
      binding: MyBusinessBindings(),
    ),
    GetPage(
      name: AppRoutes.clamBusinessProfile,
      page: () => ClamMyBusiness(),
      binding: MyBusinessBindings(),
    ),
    GetPage(
      name: AppRoutes.myBusinessProfile,
      page: () => MyBusinessProfile(),
      binding: MyBusinessBindings(),
    ),
    GetPage(
      name: AppRoutes.myBusinessAllReviews,
      page: () => const MyBusinessAllReviewsScreen(),
      binding: MyBusinessBindings(),
    ),
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
    GetPage(
      name: AppRoutes.createActivity,
      page: () => CreateActivityScreen(),
      binding: ExploreActivityBindings(),
    ),
    GetPage(
      name: AppRoutes.editEvent,
      page: () => EditEventScreen(),
      binding: ExploreActivityBindings(),
    ),
    GetPage(
      name: AppRoutes.editRaffles,
      page: () => EditRafflesScreen(),
      binding: ExploreActivityBindings(),
    ),
    GetPage(
      name: AppRoutes.editRoutes,
      page: () => EditRoutesScreen(),
      binding: ExploreActivityBindings(),
    ),

    GetPage(
      name: AppRoutes.viewEvent,
      page: () => ViewEventScreen(),
      binding: ExploreActivityBindings(),
    ),
    GetPage(
      name: AppRoutes.viewRoutes,
      page: () => ViewRouteScreen(),
      binding: ExploreActivityBindings(),
    ),
    GetPage(
      name: AppRoutes.viewRaffles,
      page: () => ViewRafflesScreen(),
      binding: ExploreActivityBindings(),
    ),

    GetPage(name: AppRoutes.viewTotalCheckIn, page: () => TotalCheckInScreen()),
    GetPage(name: AppRoutes.viewTotalRSVP, page: () => TotalRsvpScreen()),

    //---create activity
    GetPage(
      name: AppRoutes.recentActivity,
      page: () => RecentActivity(),
      binding: DrawerBindings(),
    ),

    //---community
    GetPage(
      name: AppRoutes.communityMemberScreen,
      page: () => CommunityMemberScreen(),
      binding: CommunityBinding(),
    ),
    GetPage(
      name: AppRoutes.createAnnouncement,
      page: () => CreateAnnouncementScreen(),
      binding: CommunityBinding(),
    ),

    GetPage(
      name: AppRoutes.communityScreen,
      page: () => CommunityScreen(),
      binding: CommunityBinding(),
    ),

    GetPage(
      name: AppRoutes.allCommunity,
      page: () => AllCommunityScreen(),
      binding: CommunityBinding(),
    ),

    //----profile
    GetPage(
      name: AppRoutes.changePassword,
      page: () => ChangePasswordScreen(),
      binding: ProfileBinding(),
    ),
    GetPage(name: AppRoutes.about, page: () => AboutScreen()),
    GetPage(name: AppRoutes.settings, page: () => SettingsScreen()),
    GetPage(name: AppRoutes.terms, page: () => TermsScreen()),
    GetPage(
      name: AppRoutes.deleteAccount,
      page: () => DeleteAccountScreen(),
      binding: ProfileBinding(),
    ),

    //appbar screen
    GetPage(name: AppRoutes.chatList, page: () => ChatListScreen()),
    GetPage(name: AppRoutes.message, page: () => MessageScreen()),
    GetPage(
      name: AppRoutes.notification,
      page: () => NotificationScreen(),
      binding: BottomNavBinding(),
    ),

    GetPage(
      name: AppRoutes.subscription,
      page: () => SubscriptionScreen(),
      binding: DrawerBindings(),
    ),
    GetPage(
      name: AppRoutes.mySubscription,
      page: () => const MySubscriptionScreen(),
      binding: MySubscriptionBinding(),
    ),
  ];
}
