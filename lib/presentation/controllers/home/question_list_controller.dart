import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:loci/core/constants/app_url.dart';
import 'package:loci/core/network/network_caller.dart';
import 'package:loci/data/models/common/paginatation_model.dart';
import 'package:loci/data/models/home/question_model.dart';
import 'package:loci/data/models/home/question_list_response.dart';

class QuestionListController extends GetxController {
  final Map<String, QuestionModel> _questionMap = {};
  final List<String> _questionIds = [];

  bool _isLoading = false;
  bool _isPaginationLoading = false;
  String? _errorMessage;
  PaginationMeta? _meta;
  int _currentPage = 1;

  bool get isLoading => _isLoading;
  bool get isPaginationLoading => _isPaginationLoading;
  String? get errorMessage => _errorMessage;
  bool get hasMore => _meta?.hasNextPage ?? false;

  List<QuestionModel> get questions => _questionIds
      .map((id) => _questionMap[id])
      .whereType<QuestionModel>()
      .toList();

  Future<void> fetchQuestions({bool isRefresh = false}) async {
    if (_isLoading) return;

    try {
      _isLoading = true;
      _errorMessage = null;

      if (isRefresh) {
        _currentPage = 1;
        _questionIds.clear();
        _questionMap.clear();
      }

      update();

      final response = await Get.find<NetworkCaller>().getRequest(
        url: AppUrl.questionList,
        queryParams: {'page': _currentPage, 'limit': 10},
      );

      if (response.isSuccess && response.body != null) {
        final result = QuestionListResponse.fromJson(response.body!);
        _append(result.data);
        _meta = result.meta;
      } else {
        _errorMessage = response.body?['message'] ?? 'Failed to load questions';
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      update();
    }
  }

  Future<void> fetchMore() async {
    if (!hasMore || _isPaginationLoading || _isLoading) return;

    try {
      _isPaginationLoading = true;
      _currentPage++;
      update();

      final response = await Get.find<NetworkCaller>().getRequest(
        url: AppUrl.questionList,
        queryParams: {'page': _currentPage, 'limit': 10},
      );

      if (response.isSuccess && response.body != null) {
        final result = QuestionListResponse.fromJson(response.body!);
        _append(result.data);
        _meta = result.meta;
      } else {
        _currentPage--;
        _errorMessage = response.body?['message'] ?? 'Failed to load more';
      }
    } catch (e) {
      _currentPage--;
      _errorMessage = e.toString();
    } finally {
      _isPaginationLoading = false;
      update();
    }
  }

  void prepend(QuestionModel question) {
    _questionMap[question.id] = question;
    _questionIds.insert(0, question.id);
    update();
  }

  void _append(List<QuestionModel> items) {
    for (final item in items) {
      _questionMap[item.id] = item;
      if (!_questionIds.contains(item.id)) _questionIds.add(item.id);
    }
  }
}