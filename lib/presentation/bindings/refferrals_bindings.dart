import 'package:get/get.dart';
import 'package:loci/presentation/controllers/network_dash/sent_referrals_controller.dart';

import '../controllers/network_dash/received_referrals_controller.dart';
import '../controllers/network_dash/respond_referral_controller.dart';
import '../controllers/network_dash/send_new_referrals_controller.dart';

class ReferralsBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => SendNewReferralsController());
    Get.lazyPut(() => SentReferralsController(), fenix: true);
    Get.lazyPut(() => ReceivedReferralsController(), fenix: true);
    Get.lazyPut(() => RespondReferralController(), fenix: true);
  }
}