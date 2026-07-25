import 'package:loci/core/constants/app_url.dart';
import 'package:loci/core/network/network_caller.dart';

/// Raffles data layer: remote HTTP via [NetworkCaller].
class RafflesRepository {
  final NetworkCaller _network;

  RafflesRepository(this._network);

  Future<Map<String, dynamic>> getRaffles({
    required int page,
    required int limit,
    String? search,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'limit': limit,
      if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
    };

    final res = await _network.getRequest(
      url: AppUrl.raffles,
      queryParams: queryParams,
    );
    if (!res.isSuccess || res.body == null) {
      throw Exception(res.errorMessage ?? 'Failed to load raffles');
    }
    return res.body!;
  }

  Future<Map<String, dynamic>> getRaffleDetails(String raffleId) async {
    final res = await _network.getRequest(url: AppUrl.rafflesDetails(raffleId));
    if (!res.isSuccess || res.body == null) {
      throw Exception(res.errorMessage ?? 'Failed to load raffle details');
    }
    return res.body!;
  }
}
