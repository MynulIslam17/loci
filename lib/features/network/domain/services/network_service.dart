import 'package:loci/core/enums/network_type.dart';
import 'package:loci/features/network/data/models/dashboard_response.dart';
import 'package:loci/features/network/data/models/meeting/meeting_models.dart';
import 'package:loci/features/network/data/models/referral/referral_response_model.dart';
import 'package:loci/features/network/data/repositories/network_repository.dart';

/// Domain orchestration for network dash. Controllers call this — never NetworkCaller.
class NetworkService {
  final NetworkRepository _repository;

  NetworkService(this._repository);

  Future<DashboardResponse> getDashboard(NetworkType type) async {
    final typeParam = switch (type) {
      NetworkType.checkins => 'checkins',
      NetworkType.connections => 'connections',
      NetworkType.meetings => 'meetings',
      NetworkType.referrals => 'referrals',
      NetworkType.unknown => '',
    };
    final body = await _repository.getDashboard(type: typeParam);
    return DashboardResponse.fromJson(body);
  }

  Future<SentMeetingsResponse> getSentMeetings({
    required int page,
    required int limit,
    String? date,
  }) async {
    final body = await _repository.getSentMeetings(
      queryParams: {'page': page, 'limit': limit, 'date': ?date},
    );
    return SentMeetingsResponse.fromJson(body);
  }

  Future<IncomingMeetingsResponse> getIncomingMeetings({
    required int page,
    required int limit,
    String? date,
  }) async {
    final body = await _repository.getIncomingMeetings(
      queryParams: {'page': page, 'limit': limit, 'date': ?date},
    );
    return IncomingMeetingsResponse.fromJson(body);
  }

  Future<void> scheduleMeeting({
    required String recipientName,
    required String recipientEmail,
    required String meetingDate,
    required String meetingTime,
    required String location,
    String? message,
  }) async {
    await _repository.scheduleMeeting(
      body: {
        'recipient': {'name': recipientName, 'email': recipientEmail},
        'meetingDate': meetingDate,
        'meetingTime': meetingTime,
        'location': location,
        if (message != null && message.isNotEmpty) 'message': message,
      },
    );
  }

  Future<IncomingMeetingModel?> respondMeeting({
    required String meetingId,
    required String action,
  }) async {
    final body = await _repository.respondMeeting(
      meetingId: meetingId,
      action: action,
    );
    final data = body['data'];
    if (data is Map<String, dynamic>) {
      return IncomingMeetingModel.fromJson(data);
    }
    return null;
  }

  Future<ReferralResponse> getSentReferrals({
    required int page,
    required int limit,
    String? searchTerm,
  }) async {
    final body = await _repository.getSentReferrals(
      queryParams: {
        'page': page,
        'limit': limit,
        if (searchTerm != null && searchTerm.isNotEmpty)
          'searchTerm': searchTerm,
      },
    );
    return ReferralResponse.fromJson(body);
  }

  Future<ReferralResponse> getReceivedReferrals({
    required int page,
    required int limit,
    String? searchTerm,
  }) async {
    final body = await _repository.getReceivedReferrals(
      queryParams: {
        'page': page,
        'limit': limit,
        if (searchTerm != null && searchTerm.isNotEmpty)
          'searchTerm': searchTerm,
      },
    );
    return ReferralResponse.fromJson(body);
  }

  Future<void> sendReferral({
    required String recipientEmail,
    required String recipientName,
    required String recipientCompany,
    required String businessOwnerEmail,
    required String businessOwnerName,
    required String ownerCompanyName,
    String? message,
  }) async {
    await _repository.sendReferral(
      body: {
        'recipientEmail': recipientEmail,
        'recipientName': recipientName,
        'recipientCompany': recipientCompany,
        'businessOwnerEmail': businessOwnerEmail,
        'businessOwnerName': businessOwnerName,
        'businessOwnerCompany': ownerCompanyName,
        if (message != null && message.isNotEmpty) 'message': message,
      },
    );
  }

  Future<ReferralModel?> respondReferral({
    required String referralId,
    required String action,
  }) async {
    final body = await _repository.respondReferral(
      referralId: referralId,
      action: action,
    );
    final data = body['data'];
    if (data is Map<String, dynamic>) {
      return ReferralModel.fromJson(data);
    }
    return null;
  }
}
