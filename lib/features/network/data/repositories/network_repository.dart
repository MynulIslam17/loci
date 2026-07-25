import 'package:loci/core/constants/app_url.dart';
import 'package:loci/core/network/network_caller.dart';

/// Network-dash data layer: remote HTTP via [NetworkCaller].
class NetworkRepository {
  final NetworkCaller _network;

  NetworkRepository(this._network);

  Future<Map<String, dynamic>> getDashboard({required String type}) async {
    final res = await _network.getRequest(
      url: AppUrl.networkDashboard,
      queryParams: {'type': type},
    );
    if (!res.isSuccess || res.body == null) {
      throw Exception(res.errorMessage ?? 'Failed to load dashboard');
    }
    return res.body!;
  }

  Future<Map<String, dynamic>> getSentMeetings({
    required Map<String, dynamic> queryParams,
  }) async {
    final res = await _network.getRequest(
      url: AppUrl.sentMeetings,
      queryParams: queryParams,
    );
    if (!res.isSuccess || res.body == null) {
      throw Exception(
        res.body?['message'] ?? res.errorMessage ?? 'Failed to load meetings',
      );
    }
    return res.body!;
  }

  Future<Map<String, dynamic>> getIncomingMeetings({
    required Map<String, dynamic> queryParams,
  }) async {
    final res = await _network.getRequest(
      url: AppUrl.incomingMeetings,
      queryParams: queryParams,
    );
    if (!res.isSuccess || res.body == null) {
      throw Exception(
        res.body?['message'] ??
            res.errorMessage ??
            'Failed to load incoming meetings',
      );
    }
    return res.body!;
  }

  Future<Map<String, dynamic>> scheduleMeeting({
    required Map<String, dynamic> body,
  }) async {
    final res = await _network.postRequest(
      url: AppUrl.scheduleMeeting,
      body: body,
    );
    if (!res.isSuccess || res.body == null) {
      throw Exception(
        res.body?['message'] ??
            res.errorMessage ??
            'Failed to schedule meeting',
      );
    }
    return res.body!;
  }

  Future<Map<String, dynamic>> respondMeeting({
    required String meetingId,
    required String action,
  }) async {
    final res = await _network.patchRequest(
      url: AppUrl.respondMeeting(meetingId),
      body: {'action': action},
    );
    if (!res.isSuccess || res.body == null) {
      throw Exception(res.errorMessage ?? 'Something went wrong.');
    }
    return res.body!;
  }

  Future<Map<String, dynamic>> getSentReferrals({
    required Map<String, dynamic> queryParams,
  }) async {
    final res = await _network.getRequest(
      url: AppUrl.sentReferral,
      queryParams: queryParams,
    );
    if (!res.isSuccess || res.body == null) {
      throw Exception(
        res.body?['message'] ?? res.errorMessage ?? 'Failed to load referrals',
      );
    }
    return res.body!;
  }

  Future<Map<String, dynamic>> getReceivedReferrals({
    required Map<String, dynamic> queryParams,
  }) async {
    final res = await _network.getRequest(
      url: AppUrl.receiveReferral,
      queryParams: queryParams,
    );
    if (!res.isSuccess || res.body == null) {
      throw Exception(
        res.body?['message'] ?? res.errorMessage ?? 'Failed to load referrals',
      );
    }
    return res.body!;
  }

  Future<Map<String, dynamic>> sendReferral({
    required Map<String, dynamic> body,
  }) async {
    final res = await _network.postRequest(
      url: AppUrl.sendReferral,
      body: body,
    );
    if (!res.isSuccess || res.body == null) {
      throw Exception(
        res.body?['message'] ?? res.errorMessage ?? 'Failed to send referral',
      );
    }
    return res.body!;
  }

  Future<Map<String, dynamic>> respondReferral({
    required String referralId,
    required String action,
  }) async {
    final res = await _network.patchRequest(
      url: AppUrl.acceptReferral(referralId),
      body: {'action': action},
    );
    if (!res.isSuccess || res.body == null) {
      throw Exception(res.errorMessage ?? 'Something went wrong.');
    }
    return res.body!;
  }
}
