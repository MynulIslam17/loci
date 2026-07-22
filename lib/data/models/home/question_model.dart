import 'package:loci/core/enums/question_type.dart';

import 'answer_model.dart';
import 'author_model.dart';
import 'poll_option_model.dart';

class QuestionModel {
  final String id;
  final AuthorModel author;
  final QuestionType type;
  final String category;
  final String content;
  final int totalVotes;
  final int likeCount;
  final bool isLiked;
  /// Total answer count. The list endpoint (`GET /questions`) sends
  /// `answerCount` directly and omits [answers] entirely (fetch those,
  /// paginated, via `GET /questions/:id/answers`) — the detail endpoint
  /// still embeds the full array, in which case this falls back to its length.
  final int commentCount;
  final List<PollOptionModel> options;
  final List<AnswerModel> answers;
  final String? communityId;
  final String createdAt;
  final String updatedAt;

  const QuestionModel({
    required this.id,
    required this.author,
    required this.type,
    required this.category,
    required this.content,
    required this.totalVotes,
    required this.likeCount,
    required this.isLiked,
    required this.commentCount,
    required this.options,
    required this.answers,
    this.communityId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json) => QuestionModel(
    id: (json['_id'] ?? json['id'] ?? '').toString(),
    author: AuthorModel.fromJson((json['author'] as Map<String, dynamic>?) ?? const {}),
    type: QuestionType.fromString(json['type'] as String?),
    // category is nullable on the backend (default null) — never hard-cast it.
    category: (json['category'] as String?) ?? '',
    content: (json['content'] ?? json['question'] ?? '').toString(),
    totalVotes: json['totalVotes'] as int? ?? 0,
    likeCount: json['likeCount'] as int? ?? 0,
    isLiked: json['isLiked'] as bool? ?? false,
    // Prefer an explicit server count; fall back to the embedded answers length.
    commentCount: json['answerCount'] as int? ??
        json['commentCount'] as int? ??
        (json['answers'] as List<dynamic>? ?? []).length,
    options: (json['options'] as List<dynamic>? ?? [])
        .map((e) => PollOptionModel.fromJson(e as Map<String, dynamic>))
        .toList(),
    answers: (json['answers'] as List<dynamic>? ?? [])
        .map((e) => AnswerModel.fromJson(e as Map<String, dynamic>))
        .toList(),
    communityId: json['communityId'] as String?,
    createdAt: json['createdAt'] as String? ?? '',
    updatedAt: json['updatedAt'] as String? ?? '',
  );

  Map<String, dynamic> toJson() => {
    '_id': id,
    'author': author.toJson(),
    'type': type.toJson,
    'category': category,
    'content': content,
    'totalVotes': totalVotes,
    'likeCount': likeCount,
    'isLiked': isLiked,
    'commentCount': commentCount,
    'options': options.map((e) => e.toJson()).toList(),
    'answers': answers.map((e) => e.toJson()).toList(),
    'communityId': communityId,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
  };

  bool get isPoll => type == QuestionType.poll;
  bool get isQuestion => type == QuestionType.question;
  bool get hasOptions => options.isNotEmpty;
  bool get hasAnswers => commentCount > 0;

  QuestionModel copyWith({
    List<PollOptionModel>? options,
    int? totalVotes,
    int? likeCount,
    bool? isLiked,
    int? commentCount,
  }) =>
      QuestionModel(
        id: id,
        author: author,
        type: type,
        category: category,
        content: content,
        totalVotes: totalVotes ?? this.totalVotes,
        likeCount: likeCount ?? this.likeCount,
        isLiked: isLiked ?? this.isLiked,
        commentCount: commentCount ?? this.commentCount,
        options: options ?? this.options,
        answers: answers,
        communityId: communityId,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
}