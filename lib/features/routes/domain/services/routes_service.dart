import 'package:loci/features/routes/data/models/route_detail_model.dart';
import 'package:loci/features/routes/data/models/route_list_model.dart';
import 'package:loci/features/routes/data/repositories/routes_repository.dart';

/// Domain orchestration for routes. Controllers call this — never NetworkCaller.
class RoutesService {
  final RoutesRepository _repository;

  RoutesService(this._repository);

  Future<RouteResponseModel> getRoutes({
    required int page,
    required int limit,
    String? businessId,
    String? search,
  }) async {
    final body = await _repository.getRoutes(
      page: page,
      limit: limit,
      businessId: businessId,
      search: search,
    );
    return RouteResponseModel.fromJson(body);
  }

  Future<RouteDetails> getRouteDetails(String routeId) async {
    final body = await _repository.getRouteDetails(routeId);
    final data = body['data'];
    if (data is! Map<String, dynamic>) {
      throw Exception('No route data found');
    }
    return RouteDetails.fromJson(data);
  }
}
