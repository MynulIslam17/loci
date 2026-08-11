import 'package:loci/core/constants/app_url.dart';
import 'package:loci/core/network/network_caller.dart';
import 'package:loci/features/places/data/models/place_models.dart';

/// Data layer for the backend-proxied Places API. All calls are authenticated
/// by [NetworkCaller] (Bearer token) — the Google key lives on the server.
class PlacesRepository {
  final NetworkCaller _network;

  PlacesRepository(this._network);

  /// `GET /places/autocomplete?query=&sessionToken=` (+ optional GPS bias).
  Future<List<PlacePrediction>> autocomplete({
    required String query,
    required String sessionToken,
    double? lat,
    double? lng,
  }) async {
    final res = await _network.getRequest(
      url: AppUrl.placesAutocomplete,
      queryParams: {
        'query': query,
        'sessionToken': sessionToken,
        // Bias to the user's position — send both or neither.
        if (lat != null && lng != null) ...{
          'lat': lat.toString(),
          'lng': lng.toString(),
        },
      },
    );

    if (!res.isSuccess || res.body == null) {
      throw Exception(res.errorMessage ?? 'Failed to load places');
    }

    final data = res.body!['data'] as List? ?? const [];
    return data
        .whereType<Map<String, dynamic>>()
        .map(PlacePrediction.fromJson)
        .where((p) => p.placeId.isNotEmpty)
        .toList();
  }

  /// `GET /places/{placeId}/details?sessionToken=` — resolves coordinates.
  Future<PlaceDetails> details({
    required String placeId,
    required String sessionToken,
  }) async {
    final res = await _network.getRequest(
      url: AppUrl.placeDetails(placeId),
      queryParams: {'sessionToken': sessionToken},
    );

    if (!res.isSuccess || res.body == null) {
      throw Exception(res.errorMessage ?? 'Failed to load place details');
    }

    final data = res.body!['data'] as Map<String, dynamic>?;
    if (data == null) {
      throw Exception('Place details not found');
    }
    return PlaceDetails.fromJson(data);
  }
}
