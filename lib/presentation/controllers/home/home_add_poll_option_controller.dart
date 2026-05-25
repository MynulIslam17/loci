import 'package:get/get.dart';
import 'package:loci/core/constants/app_url.dart';
import 'package:loci/core/network/network_caller.dart';
import 'package:loci/data/models/home/question_model.dart';

class HomeAddPollOptionController extends GetxController {
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<QuestionModel?> addPollOption({
    required String questionId,
    required String text,
    String? imageUrl,
  }) async {
    if (text.trim().isEmpty) return null;

    _isLoading = true;
    _errorMessage = null;
    update();

    try {
      final response = await Get.find<NetworkCaller>().postRequest(
        url: AppUrl.addHomePollQuestionAdd(questionId),
        body: {
          'text': text.trim(),
          if (imageUrl != null && imageUrl.isNotEmpty) 'image': imageUrl,
        },
      );

      if (!response.isSuccess) {
        _errorMessage = response.errorMessage ?? 'Failed to add poll option';
        return null;
      }

      return QuestionModel.fromJson(response.body!['data']);
    } catch (e) {
      _errorMessage = e.toString();
      return null;
    } finally {
      _isLoading = false;
      update();
    }
  }
}
