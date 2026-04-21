import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loci/data/models/raffles/raffles_details_model.dart';
import '../../../core/constants/app_url.dart';
import '../../../core/network/network_caller.dart';
import '../../../core/utils/date_parser.dart';
import '../../../data/models/explore_activity/raffle_update_request_model.dart';
import '../../../data/models/raffles/raffles_model.dart';

class RaffleEditController extends GetxController {
  // ── Text Controllers ────────────────────────────────────────────────────────
  final titleController             = TextEditingController();
  final detailsController           = TextEditingController();
  final maxSupplyController         = TextEditingController();
  final dateController              = TextEditingController();
  final raffleBundleNameTEController = TextEditingController();

  // ── State ───────────────────────────────────────────────────────────────────
  DateTime? startDate;
  DateTime? endDate;
  File? bannerImage;
  File? couponFile;
  String? existingCouponUrl;
  bool removeCoupon = false;
  bool isPublic     = true;
  List<RaffleTaskModel> tasks = [];

  // ── Initial snapshot  ───────────────────────────────────
  RaffleModel? _initialRaffle;
  int  _initialTaskCount = 0;
  bool _initialIsPublic  = true;

  RaffleModel? get initialRaffle => _initialRaffle;

  // ── Loading / Error ─────────────────────────────────────────────────────────
  bool    _isLoading    = false;
  String? _errorMessage;

  bool    get isLoading     => _isLoading;
  String? get errorMessage  => _errorMessage;

  // ── Lifecycle ───────────────────────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    _bindListeners();
  }

  @override
  void onClose() {
    titleController.dispose();
    detailsController.dispose();
    maxSupplyController.dispose();
    dateController.dispose();
    raffleBundleNameTEController.dispose();
    super.onClose();
  }

  // ── Seeding ─────────────────────────────────────────────────────────────────
  void setData(RaffleDetailsModel details) {
    final raffle       = details.raffleModel;
    _initialRaffle     = raffle;
    _initialIsPublic   = details.isPublic;
    _initialTaskCount  = details.tasks.length;

    titleController.text              = raffle.title;
    detailsController.text            = raffle.description;
    maxSupplyController.text          = raffle.maxSupply.toString();
    raffleBundleNameTEController.text = raffle.bundleName;
    isPublic                          = details.isPublic;
    existingCouponUrl                 = raffle.rafflePrizeImage;
    tasks                             = List.from(details.tasks);
    startDate                         = DateTime.parse(raffle.startDate).toLocal();
    endDate                           = DateTime.parse(raffle.endDate).toLocal();

    _updateDateText();
    update();
  }

  // ── Dirty Check ─────────────────────────────────────────────────────────────
  bool hasChanged() {
    if (_initialRaffle == null) return false;

    final dateChanged =
        startDate?.toIso8601String() != _initialRaffle!.startDate ||
            endDate?.toIso8601String()   != _initialRaffle!.endDate;

    return titleController.text                != _initialRaffle!.title        ||
        detailsController.text                 != _initialRaffle!.description  ||
        maxSupplyController.text               != _initialRaffle!.maxSupply.toString() ||
        raffleBundleNameTEController.text      != _initialRaffle!.bundleName   ||
        isPublic                               != _initialIsPublic              ||
        tasks.length                           != _initialTaskCount             ||
        dateChanged                                                              ||
        bannerImage  != null                                                    ||
        couponFile   != null                                                    ||
        removeCoupon;
  }

  // ── Mutations ────────────────────────────────────────────────────────────────
  void updateDateRange(DateTime start, DateTime end) {
    startDate = start;
    endDate   = end;
    _updateDateText();
    update();
  }

  void removeTask(String id) {
    tasks.removeWhere((e) => e.activity?.id == id);
    update();
  }

  void setBanner(File file)  { bannerImage = file; update(); }
  void setCoupon(File file)  { couponFile = file; removeCoupon = false; update(); }
  void togglePublic(bool v)  { isPublic = v; update(); }

  void removeCouponFile() {
    couponFile        = null;
    existingCouponUrl = null;
    removeCoupon      = true;
    update();
  }

  // ── Build Payload ────────────────────────────────────────────────────────────
  RaffleUpdateRequest buildRequest() {
    final r = _initialRaffle!;

    return RaffleUpdateRequest(
      raffleId:             r.id,
      title:                titleController.text           != r.title             ? titleController.text                         : null,
      description:          detailsController.text         != r.description       ? detailsController.text                       : null,
      maxSupply:            int.tryParse(maxSupplyController.text) != r.maxSupply ? int.tryParse(maxSupplyController.text)        : null,
      startDate:            startDate?.toUtc().toIso8601String()   != r.startDate ? startDate?.toUtc().toIso8601String()         : null,
      endDate:              endDate?.toUtc().toIso8601String()     != r.endDate   ? endDate?.toUtc().toIso8601String()           : null,
      isPublic:             isPublic                        != _initialIsPublic    ? isPublic                                     : null,
      raffleBundleName:     raffleBundleNameTEController.text != r.bundleName     ? raffleBundleNameTEController.text            : null,
      bannerFile:           bannerImage,
      rafflePrizeImageFile: couponFile,
      removeCoupon:         removeCoupon ? true : null,
      tasks:                tasks.length != _initialTaskCount ? tasks : null,
    );
  }

  // ── API Call ─────────────────────────────────────────────────────────────────
  Future<bool> updateRaffles(RaffleUpdateRequest request) async {
    try {
      _isLoading    = true;
      _errorMessage = null;
      update();

      final fields   = request.toFields();
      final response = await Get.find<NetworkCaller>().multipartRequest(
        url:    AppUrl.rafflesDetails(request.raffleId),
        method: "PATCH",
        fields: fields.isNotEmpty ? fields : null,
        files:  request.toFiles(),
      );

      _isLoading = false;

      if (response.isSuccess) {
        update();
        return true;
      }

      _errorMessage = response.errorMessage ?? "Update failed";
      update();
      return false;

    } catch (e) {
      _isLoading    = false;
      _errorMessage = "An unexpected error occurred: $e";
      update();
      return false;
    }
  }

  // ── Private Helpers ──────────────────────────────────────────────────────────
  void _updateDateText() {
    if (startDate == null || endDate == null) return;
    dateController.text =
    "${DateParserHelper.shortDate(startDate!)} - ${DateParserHelper.shortDate(endDate!)}";
  }

  void _bindListeners() {
    for (final c in [titleController, detailsController, maxSupplyController, raffleBundleNameTEController]) {
      c.addListener(() => update());
    }
  }
}