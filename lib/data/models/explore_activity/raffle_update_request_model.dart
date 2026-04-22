import 'dart:convert';
import 'dart:io';

import '../raffles/raffles_details_model.dart';

class RaffleUpdateRequest {
  final String raffleId;

  final String? title;
  final String? description;
  final String? startDate;
  final String? endDate;
  final int? maxSupply;
  final bool? isPublic;
  final String? status;
  final bool? removeCoupon;
  final String? raffleBundleName;

  final File? bannerFile;
  final File? rafflePrizeImageFile;

  final List<RaffleTaskModel>? tasks;

  RaffleUpdateRequest({
    required this.raffleId,
    this.title,
    this.description,
    this.startDate,
    this.endDate,
    this.maxSupply,
    this.isPublic,
    this.status,
    this.removeCoupon,
    this.bannerFile,
    this.rafflePrizeImageFile,
    this.tasks,
    this.raffleBundleName,
  });

  Map<String, String> toFields() {
    final map = <String, String>{};

    if (title != null) map['title'] = title!;
    if (description != null) map['details'] = description!;
    if (startDate != null) map['startDate'] = startDate!;
    if (endDate != null) map['endDate'] = endDate!;
    if (maxSupply != null) map['maxSupply'] = maxSupply.toString();
    if (status != null) map['status'] = status!;
    if (isPublic != null) map['isPublic'] = isPublic.toString();
    if (raffleBundleName != null) map['raffleBundleName'] = raffleBundleName!;



    if (tasks != null && tasks!.isNotEmpty) {
      map['tasks'] = jsonEncode(
        tasks!
            .where((e) => e.activity != null)
            .map((e) => {
          if (e.isRouteTask) "routeActivity": e.activity!.id,
          if (e.isEventTask) "eventActivity": e.activity!.id,
          "order": e.order,
        })
            .toList(),
      );
    }

    return map;
  }

  Map<String, File> toFiles() {
    final map = <String, File>{};

    if (bannerFile != null) {
      map['banner'] = bannerFile!;
    }

    if (rafflePrizeImageFile != null) {
      map['rafflePrizeImage'] = rafflePrizeImageFile!;
    }

    return map;
  }
}