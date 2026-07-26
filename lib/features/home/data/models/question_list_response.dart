import 'package:loci/shared/models/pagination_model.dart';

import 'question_model.dart';

class QuestionListResponse {
  final List<QuestionModel> data;
  final PaginationMeta meta;

  const QuestionListResponse({required this.data, required this.meta});

  factory QuestionListResponse.fromJson(Map<String, dynamic> json) =>
      QuestionListResponse(
        data: (json['data'] as List<dynamic>)
            .map((e) => QuestionModel.fromJson(e as Map<String, dynamic>))
            .toList(),
        meta: PaginationMeta.fromJson(json['meta'] as Map<String, dynamic>),
      );
}
