abstract class AppUrl {

  /// base url=================================
  //static const String baseUrl="https://jakuan5000.syedbipul.me/api/v1";//local
  static const String baseUrl="https://api.lociapp.io/api/v1"; //live

  /// Socket.io connects to the server root (no /api/v1 prefix).
  static const String socketUrl="https://api.lociapp.io/";


  /// ========================auth===================================

  static const String signUp="$baseUrl/auth/register";
  static const String login="$baseUrl/auth/login";
  static const String logout="$baseUrl/auth/logout";
  static const String forgetPassword="$baseUrl/auth/forgot-password";
  static const String verifySignupOtp="$baseUrl/auth/verify-email";
  static const String verifyForgotOtp="$baseUrl/auth/verify-reset-otp";
  static const String resendOtp="$baseUrl/auth/resend-verification";
  static const String resetPassword="$baseUrl/auth/reset-password";
  static const String pushToken="$baseUrl/users/me/push-token"; // PATCH





  ///=============================================== event ===============================================

  static const String eventList="$baseUrl/events";
  static  String rsvpEvent(String eventId)=>"$baseUrl/events/$eventId/rsvp";
  static String eventDetails(String id)=>"$baseUrl/events/$id";
  static const String eventManualCheckIn="$baseUrl/events/check-in";
  static const String createEvent="$baseUrl/events";



  ///===========================  routes ===================================================
  static const String routeList="$baseUrl/routes";
  static  String routeDetails(String routeId)=>"$baseUrl/routes/$routeId";
  static  String routeManualCheckIn="$baseUrl/routes/check-in";
  static const String createRoute="$baseUrl/routes";

  ///-------------raffle--------------------------------
  static const String raffles="$baseUrl/raffles";
  static  String rafflesDetails(String raffleId)=>"$baseUrl/raffles/$raffleId";
  static const String searchTask="$baseUrl/raffles/search";


  ///-----check_in----------------
  static const String checkIn="$baseUrl/checkins/scan";

  ///-----places (backend-proxied autocomplete + details)----------------
  static const String placesAutocomplete="$baseUrl/places/autocomplete";
  static String placeDetails(String placeId)=>"$baseUrl/places/$placeId/details";


///-------business
  static const String myBusiness="$baseUrl/businesses/me";
  static const String createBusiness="$baseUrl/businesses";
  static const String claimBusiness="$baseUrl/businesses/claim";
  static  String businessProfile(String businessId)=>"$baseUrl/businesses/$businessId";
  static  String updateBusinessProfile(String businessId)=>"$baseUrl/businesses/$businessId";
  static const String browseBusinesses = "$baseUrl/businesses";
  static const String addBusinessToSaveList = "$baseUrl/users/me/saved-businesses";
  static  String removeSavedBusiness(String businessId) => "$baseUrl/users/me/saved-businesses/${businessId}";

  ///-------ads
  static const String submitAd = "$baseUrl/admin/ads/submit";
  static const String adsList = "$baseUrl/ads";
  static const String myAds = "$baseUrl/ads/my";




  ///--------------- profile

  static const String getMyProfile="$baseUrl/auth/me";
  static const String updateMyProfile="$baseUrl/users/me";
  static const String changePassword="$baseUrl/users/me/password"; // PATCH
  static const String deleteAccount="$baseUrl/users/me/delete"; // DELETE

  ///-----------my qr code
  static const String myQrCode = "$baseUrl/connections/my-qr";
  static const String connectViaQr = "$baseUrl/connections/scan";
  static String deleteConnection(String otherUserId) => "$baseUrl/connections/$otherUserId";




  //--------------network------------------------
  static const String networkDashboard="$baseUrl/users/me/dashboard";
  //--referrals
  static const String sendReferral="$baseUrl/referrals";
  static const String sentReferral="$baseUrl/referrals/sent";
  static const String receiveReferral="$baseUrl/referrals/received";
  static  String acceptReferral(String referralId)=>"$baseUrl/referrals/${referralId}/respond";


  //--meeting
  static const String scheduleMeeting="$baseUrl/meetings";
  static const String incomingMeetings="$baseUrl/meetings/incoming";
  static const String sentMeetings="$baseUrl/meetings/my";
  static String respondMeeting(String meetingId)=>"$baseUrl/meetings/$meetingId/respond";



  //----recent activity

  static const String recentActivity="$baseUrl/users/me/recent-activity";

  //------subscription
  static const String subscriptionPlans="$baseUrl/subscriptions/plans";
  static const String subscriptionConfig="$baseUrl/subscriptions/config";
  static const String subscriptionCheckout="$baseUrl/subscriptions/checkout";
  static const String mySubscription="$baseUrl/subscriptions/my"; // GET current + DELETE to cancel; both require ?businessId=

  //------chat / messaging
  static const String conversations="$baseUrl/conversations"; // GET my list, POST create
  static String conversationById(String id)=>"$baseUrl/conversations/$id"; // GET, DELETE
  static String conversationRead(String id)=>"$baseUrl/conversations/$id/read"; // POST
  static String conversationMessages(String conversationId)=>"$baseUrl/conversations/$conversationId/messages"; // GET, POST
  static String conversationMessagesRead(String conversationId)=>"$baseUrl/conversations/$conversationId/messages/read"; // POST
  static const String messagesDelivered="$baseUrl/messages/delivered"; // POST — delivery receipt on app launch/push
  static String editMessage(String id)=>"$baseUrl/messages/$id"; // PATCH, DELETE (for everyone)
  static String deleteMessageForMe(String id)=>"$baseUrl/messages/$id/me"; // DELETE
  static String messageReactions(String id)=>"$baseUrl/messages/$id/reactions"; // POST, DELETE

  //----reviews
static String  otherBusinessReviews(String businessId)=>"$baseUrl/reviews/business/$businessId";
static String   myBusinessReviews(String businessId)=>"$baseUrl/businesses/${businessId}/reviews";
static String   addReviews(String businessId)=>"$baseUrl/reviews/$businessId";

//---community

  static const String  community="$baseUrl/communities/me";
  static String  singleCommunity(String communityId)=>"$baseUrl/communities/$communityId";
  static String  communityQr(String communityId)=>"$baseUrl/communities/$communityId/qr";
  static const String  joinCommunity="$baseUrl/communities/join";
  static const String  announcementList="$baseUrl/community-announcements";

  static String  announcementsComments(String announcementId)=>"$baseUrl/community-announcements/$announcementId/comments";
  static String  voteOnAnnouncementPoll(String announcementId)=>"$baseUrl/community-announcements/$announcementId/vote";
  static String  announcementComment(String announcementId)=>"$baseUrl/community-announcements/$announcementId/comments";
  static String  announcementLike(String announcementId)=>"$baseUrl/community-announcements/$announcementId/like";
  static String communityMember(String communityId) =>
      "$baseUrl/community-members/$communityId";
  static String removeCommunityMember(String communityId, String memberId) =>
      "$baseUrl/community-members/$communityId/$memberId";
  static String exportCommunityMembers(String communityId) =>
      "$baseUrl/community-members/$communityId/export";
  static const String  crateAnnouncement="$baseUrl/community-announcements";
  // communityId, type, search, page, limit are supplied via queryParams.
  static const String searchActivity = "$baseUrl/community-announcements/all-activity";
  static String searchBusinesses(String search) => "$baseUrl/businesses?search=$search";
  static String addPollOption(String announcementId) => "$baseUrl/community-announcements/$announcementId/poll-options";
  static String findGoogleBusiness= "$baseUrl/businesses/discover";




  ///--------home

  static const String  postQuestionHome="$baseUrl/questions";
  static const String  questionList="$baseUrl/questions";
  static  String   addHomePollQuestionAdd(String questionId)=>"$baseUrl/questions/${questionId}/poll-options";
  static  String   homeVoteOnPollOption(String questionId)=>"$baseUrl/questions/${questionId}/vote";
  static  String   homeFeedPostLike(String questionId)=>"$baseUrl/questions/${questionId}/upvote";
  static  String   questionDetails(String questionId)=>"$baseUrl/questions/$questionId";
  static  String   questionAnswers(String questionId)=>"$baseUrl/questions/$questionId/answer";
  // Paginated answers/comments list: GET /questions/{id}/answers?page=&limit=
  static  String   questionAnswersList(String questionId)=>"$baseUrl/questions/$questionId/answers";

  ///-----------------notification

  static const String   notifications="$baseUrl/notifications";
  static String notificationAction(String notificationId) =>
      "$baseUrl/notifications/$notificationId/action";














}