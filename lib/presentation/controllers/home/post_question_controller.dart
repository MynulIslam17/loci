import 'package:get/get.dart';
import 'package:loci/core/constants/app_url.dart';
import 'package:loci/core/network/network_caller.dart';


import '../../../data/models/home/question_model.dart';

class PostQuestionController extends GetxController {
  bool _isLoading = false;
  String? _errorMessage;
  QuestionModel? _createdQuestion;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  QuestionModel? get createdQuestion => _createdQuestion;

  Future<bool> postQuestion({
    required String content,
    required String category,
    String type = 'question',
  }) async {
    _isLoading = true;
    _errorMessage = null;
    _createdQuestion = null;
    update();

    try {
      final response = await Get.find<NetworkCaller>().postRequest(
        url: AppUrl.postQuestionHome,
        body: {
          'content': content,
          'type': type,
          'category': category,
        },
      );

      if (!response.isSuccess) {
        _errorMessage = response.errorMessage ?? 'Failed to post question';
        return false;
      }

      final data = response.body?['data'];
      if (data != null) {
        _createdQuestion = QuestionModel.fromJson(data as Map<String, dynamic>);
      }

      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      update();
    }
  }
}
