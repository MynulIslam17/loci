import 'package:loci/core/constants/app_url.dart';
import 'package:loci/core/network/network_caller.dart';

/// Routes data layer: remote HTTP via [NetworkCaller].
class RoutesRepository {
  final NetworkCaller _network;

  RoutesRepository(this._network);

  Future<Map<String, dynamic>> getRoutes({
    required int page,
    required int limit,
    String? businessId,
    String? search,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'limit': limit,
      'businessId': ?businessId,
      if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
    };

    final res = await _network.getRequest(
      url: AppUrl.routeList,
      queryParams: queryParams,
    );
    if (!res.isSuccess || res.body == null) {
      throw Exception(res.errorMessage ?? 'Failed to load routes');
    }
    return res.body!;
  }

  Future<Map<String, dynamic>> getRouteDetails(String routeId) async {
    final res = await _network.getRequest(url: AppUrl.routeDetails(routeId));
    if (!res.isSuccess || res.body == null) {
      throw Exception(res.errorMessage ?? 'Failed to fetch route details');
    }
    return res.body!;
  }
}
