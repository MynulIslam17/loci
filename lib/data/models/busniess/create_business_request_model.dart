import 'dart:io';

class CreateBusinessRequestModel {
  final String name;
  final String location;
  final String phone;
  final String category;
  final String? website;
  final String description;

  CreateBusinessRequestModel({
    required this.name,
    required this.location,
    required this.phone,
    required this.category,
    this.website,
    required this.description,
  });

  factory CreateBusinessRequestModel.fromManualData(
    Map<String, dynamic> data, {
    required String category,
  }) {
    return CreateBusinessRequestModel(
      name: data['name'] as String,
      location: data['location'] as String,
      phone: data['phone'] as String,
      category: category,
      website: data['website'] as String?,
      description: data['description'] as String,
    );
  }

  Map<String, String> toFields() => {
        'name': name,
        'location': location,
        'phone': phone,
        'category': category,
        'description': description,
        if (website != null && website!.isNotEmpty) 'website': website!,
      };
}

extension CreateBusinessRequestFiles on CreateBusinessRequestModel {
  Map<String, List<File>> attachmentsMultiFileMap(List<File> files) =>
      files.isEmpty ? {} : {'attachments': files};
}
