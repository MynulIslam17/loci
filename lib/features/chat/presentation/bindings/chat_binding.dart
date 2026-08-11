import 'package:get/get.dart';
import 'package:loci/features/chat/domain/services/chat_service.dart';
import 'package:loci/features/chat/presentation/controllers/chat_list_controller.dart';

class ChatBinding extends Bindings {
  @override
  void dependencies() {
    final service = Get.find<ChatService>();
    Get.lazyPut(() => ChatListController(service), fenix: true);
  }
}
