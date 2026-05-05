import 'package:loci/data/models/common/paginatation_model.dart';

class CommentModel {
  final String id;
  final String content;
  final String createdAt;
  final CommentAuthor author;

  CommentModel({
    required this.id,
    required this.content,
    required this.createdAt,
    required this.author,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) => CommentModel(
    id: json["_id"],
    content: json["content"],
    createdAt: json["createdAt"],
    author: CommentAuthor.fromJson(json["author"]),
  );
}

class CommentAuthor {
  final String id;
  final String name;
  final String avatar;

  CommentAuthor({
    required this.id,
    required this.name,
    required this.avatar,
  });

  factory CommentAuthor.fromJson(Map<String, dynamic> json) => CommentAuthor(
    id: json["_id"],
    name: json["name"],
    avatar: json["avatar"],
  );
}

class CommentResponse {
  final List<CommentModel> comments;
  final PaginationMeta meta;

  CommentResponse({
    required this.comments,
    required this.meta,
  });

  factory CommentResponse.fromJson(Map<String, dynamic> json) => CommentResponse(
    comments: (json["data"] as List)
        .map((e) => CommentModel.fromJson(e))
        .toList(),
    meta: PaginationMeta.fromJson(json["meta"])
  );
}

