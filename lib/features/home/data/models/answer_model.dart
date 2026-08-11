import 'author_model.dart';

class AnswerModel {
  final String id;
  final String content;
  final AuthorModel user;
  final int likeCount;
  final bool isLiked;
  final String createdAt;

  const AnswerModel({
    required this.id,
    required this.content,
    required this.user,
    required this.likeCount,
    required this.isLiked,
    required this.createdAt,
  });

  factory AnswerModel.fromJson(Map<String, dynamic> json) => AnswerModel(
    id: (json['_id'] ?? json['id'] ?? '').toString(),
    content: (json['content'] as String?) ?? '',
    user: AuthorModel.fromJson(
      (json['user'] as Map<String, dynamic>?) ?? const {},
    ),
    likeCount: json['likeCount'] as int? ?? 0,
    isLiked: json['isLiked'] as bool? ?? false,
    createdAt: json['createdAt'] as String? ?? '',
  );

  Map<String, dynamic> toJson() => {
    '_id': id,
    'content': content,
    'user': user.toJson(),
    'likeCount': likeCount,
    'isLiked': isLiked,
    'createdAt': createdAt,
  };
}
