import 'package:get/get.dart';
import 'package:loci/features/home/data/models/poll_option_model.dart';
import 'package:loci/features/home/domain/services/home_service.dart';

class HomeAddPollOptionController extends GetxController {
  HomeAddPollOptionController(this._service);

  final HomeService _service;

  final isLoading = false.obs;
  final errorMessage = RxnString();

  /// Returns the newly created option on success. On success with an
  /// unparseable response shape, returns null with [errorMessage] still
  /// null — callers should refresh instead of showing an error.
  Future<PollOptionModel?> addPollOption({
    required String questionId,
    required String text,
    String? imageUrl,
  }) async {
    if (text.trim().isEmpty) return null;

    isLoading.value = true;
    errorMessage.value = null;

    try {
      return await _service.addPollOption(
        questionId: questionId,
        text: text.trim(),
        imageUrl: imageUrl,
      );
    } catch (e) {
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
      return null;
    } finally {
      isLoading.value = false;
    }
  }
}
