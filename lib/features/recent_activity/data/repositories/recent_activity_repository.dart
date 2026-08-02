import 'package:loci/core/constants/app_url.dart';
import 'package:loci/core/enums/recent_activity.dart';
import 'package:loci/core/network/network_caller.dart';

/// Recent activity data layer: remote HTTP via [NetworkCaller].
class RecentActivityRepository {
  final NetworkCaller _network;

  RecentActivityRepository(this._network);

  Future<Map<String, dynamic>> getActivities({
    required RecentActivityType type,
    required int page,
    int limit = 20,
  }) async {
    final url =
        '${AppUrl.recentActivity}?type=${type.toJson}&page=$page&limit=$limit';
    final res = await _network.getRequest(url: url);
    if (!res.isSuccess || res.body == null) {
      throw Exception(res.errorMessage ?? 'Something went wrong');
    }
    return res.body!;
  }
}
