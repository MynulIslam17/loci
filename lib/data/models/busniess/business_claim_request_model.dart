import 'dart:io';

class BusinessClaimRequestModel {
  final String? name;
  final String? category;
  final String? description;
  final String? phone;
  final String? website;
  final String? location;

  // Files
  final File? logo;
  final List<File>? attachments;

  BusinessClaimRequestModel({
    this.name,
    this.category,
    this.description,
    this.phone,
    this.website,
    this.location,
    this.logo,
    this.attachments,
  });

  /// Converts text fields to a Map for Multipart requests.
  Map<String, String> toFields() {
    final map = <String, String>{};

    if (name != null) map['name'] = name!;
    if (category != null) map['category'] = category!;
    if (description != null) map['description'] = description!;
    if (phone != null) map['phone'] = phone!;
    if (website != null) map['website'] = website!;
    if (location != null) map['location'] = location!;

    return map;
  }

  /// Returns a map of files.
  /// Handles the 'logo' and multiple 'attachments'.
  Map<String, File> toFileMap() {
    final map = <String, File>{};

    if (logo != null) {
      map['logo'] = logo!;
    }

    return map;
  }

  Map<String, List<File>> toMultiFileMap() {
    final map = <String, List<File>>{};

    if (attachments != null && attachments!.isNotEmpty) {
      map['attachments'] = attachments!;
    }

    return map;
  }



}
