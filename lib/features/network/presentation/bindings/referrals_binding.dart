import 'package:get/get.dart';
import 'package:loci/features/network/domain/services/network_service.dart';
import 'package:loci/features/network/presentation/controllers/received_referrals_controller.dart';
import 'package:loci/features/network/presentation/controllers/respond_referral_controller.dart';
import 'package:loci/features/network/presentation/controllers/send_new_referrals_controller.dart';
import 'package:loci/features/network/presentation/controllers/sent_referrals_controller.dart';

class ReferralsBindings extends Bindings {
  @override
  void dependencies() {
    final service = Get.find<NetworkService>();
    Get.lazyPut(() => SendNewReferralsController(service));
    Get.lazyPut(() => SentReferralsController(service), fenix: true);
    Get.lazyPut(() => ReceivedReferralsController(service), fenix: true);
    Get.lazyPut(() => RespondReferralController(service), fenix: true);
  }
}
