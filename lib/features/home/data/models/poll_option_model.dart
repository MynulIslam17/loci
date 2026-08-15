import 'voter_model.dart';

class PollOptionModel {
  final String optionId;
  final String text;
  final String? image;
  final int voteCount;
  final int percentage;
  final List<VoterModel> voters;

  const PollOptionModel({
    required this.optionId,
    required this.text,
    this.image,
    required this.voteCount,
    required this.percentage,
    required this.voters,
  });

  factory PollOptionModel.fromJson(Map<String, dynamic> json) =>
      PollOptionModel(
        optionId: (json['optionId'] ?? json['_id'] ?? json['id'] ?? '')
            .toString(),
        text: (json['text'] as String?) ?? '',
        image: json['image'] as String?,
        voteCount: json['voteCount'] as int? ?? 0,
        percentage: json['percentage'] as int? ?? 0,
        voters: (json['voters'] is List ? (json['voters'] as List) : [])
            .whereType<Map>()
            .map((e) => VoterModel.fromJson(Map<String, dynamic>.from(e)))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
    'optionId': optionId,
    'text': text,
    'image': image,
    'voteCount': voteCount,
    'percentage': percentage,
    'voters': voters.map((e) => e.toJson()).toList(),
  };

  PollOptionModel copyWith({
    int? voteCount,
    int? percentage,
    List<VoterModel>? voters,
  }) => PollOptionModel(
    optionId: optionId,
    text: text,
    image: image,
    voteCount: voteCount ?? this.voteCount,
    percentage: percentage ?? this.percentage,
    voters: voters ?? this.voters,
  );
}
