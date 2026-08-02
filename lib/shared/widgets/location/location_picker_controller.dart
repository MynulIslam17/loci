import 'dart:async';

import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

import 'package:loci/features/places/domain/services/places_service.dart';
import 'package:loci/shared/widgets/location/location_models.dart';

/// Drives one location-picker session. Follows the documented rules:
///  • debounce keystrokes (~300ms),
///  • one [sessionToken] per session (minted here, reused for every
///    autocomplete + the details call, then discarded with this instance),
///  • a request-sequence guard so out-of-order responses can't rewind the list.
///
/// Screen-scoped: create one per picker open, and call [close] on dispose.
class LocationPickerController {
  LocationPickerController(this._service);

  final PlacesService _service;

  /// One token for the whole session — never regenerated per keystroke.
  final String sessionToken = const Uuid().v4();

  static const int minChars = 3;
  static const Duration _debounceDelay = Duration(milliseconds: 300);

  Timer? _debounce;
  int _requestSeq = 0;

  // Optional GPS bias (both or neither).
  double? biasLat;
  double? biasLng;

  final RxString query = ''.obs;
  final RxList<PlacePrediction> results = <PlacePrediction>[].obs;
  final RxBool isSearching = false.obs;
  final RxBool isResolving = false.obs;
  final Rxn<String> errorMessage = Rxn<String>();

  /// Debounced entry point for the search field's `onChanged`.
  void onQueryChanged(String value) {
    query.value = value;
    _debounce?.cancel();

    final trimmed = value.trim();
    if (trimmed.length < minChars) {
      results.clear();
      isSearching.value = false;
      errorMessage.value = null;
      return;
    }

    _debounce = Timer(_debounceDelay, () => _search(trimmed));
  }

  Future<void> _search(String q) async {
    final seq = ++_requestSeq;
    isSearching.value = true;
    errorMessage.value = null;

    try {
      final res = await _service.autocomplete(
        query: q,
        sessionToken: sessionToken,
        lat: biasLat,
        lng: biasLng,
      );
      if (seq != _requestSeq) return; // a newer search superseded this one
      results.assignAll(res);
    } catch (e) {
      if (seq != _requestSeq) return;
      results.clear();
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
    } finally {
      if (seq == _requestSeq) isSearching.value = false;
    }
  }

  /// Resolves a tapped prediction to coordinates (same session token).
  /// Returns null on failure — the caller stays on the list.
  Future<PlaceDetails?> resolve(PlacePrediction prediction) async {
    isResolving.value = true;
    errorMessage.value = null;
    try {
      return await _service.details(
        placeId: prediction.placeId,
        sessionToken: sessionToken,
      );
    } catch (e) {
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
      return null;
    } finally {
      isResolving.value = false;
    }
  }

  /// True once the user has typed enough to trigger a lookup.
  bool get hasQuery => query.value.trim().length >= minChars;

  void close() {
    _debounce?.cancel();
  }
}
