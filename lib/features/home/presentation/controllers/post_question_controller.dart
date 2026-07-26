import 'package:get/get.dart';
import 'package:loci/features/home/data/models/question_model.dart';
import 'package:loci/features/home/domain/services/home_service.dart';

class PostQuestionController extends GetxController {
  PostQuestionController(this._service);

  final HomeService _service;

  final isLoading = false.obs;
  final errorMessage = RxnString();
  final createdQuestion = Rxn<QuestionModel>();

  Future<bool> postQuestion({
    required String content,
    required String category,
    String type = 'question',
  }) async {
    isLoading.value = true;
    errorMessage.value = null;
    createdQuestion.value = null;

    try {
      createdQuestion.value = await _service.postQuestion(
        content: content,
        category: category,
        type: type,
      );
      return true;
    } catch (e) {
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}
