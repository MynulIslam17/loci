import 'package:loci/features/places/data/models/place_models.dart';
import 'package:loci/features/places/data/repositories/places_repository.dart';

/// Domain orchestration for Places. Controllers call this — never NetworkCaller.
class PlacesService {
  final PlacesRepository _repository;

  PlacesService(this._repository);

  Future<List<PlacePrediction>> autocomplete({
    required String query,
    required String sessionToken,
    double? lat,
    double? lng,
  }) {
    return _repository.autocomplete(
      query: query,
      sessionToken: sessionToken,
      lat: lat,
      lng: lng,
    );
  }

  Future<PlaceDetails> details({
    required String placeId,
    required String sessionToken,
  }) {
    return _repository.details(placeId: placeId, sessionToken: sessionToken);
  }
}
