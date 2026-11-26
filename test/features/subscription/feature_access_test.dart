import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:loci/core/network/network_caller.dart';
import 'package:loci/core/network/network_response.dart';
import 'package:loci/core/constants/app_url.dart';
import 'package:loci/features/explore_activity/data/repositories/explore_activity_repository.dart';
import 'package:loci/features/community/data/repositories/community_repository.dart';

class AccessNetwork extends NetworkCaller {
  AccessNetwork() : super(onUnAuthorize: () {}, accessToken: () => '');
  bool entitled = false;
  NetworkResponse get response => entitled
      ? NetworkResponse(
          isSuccess: true,
          statusCode: 201,
          body: {'message': 'Created'},
        )
      : NetworkResponse(
          isSuccess: false,
          statusCode: 403,
          body: {'code': 'SUBSCRIPTION_REQUIRED', 'message': 'Forbidden'},
          errorMessage: 'An active subscription is required for this action.',
        );
  @override
  Future<NetworkResponse> multipartRequest({
    required String url,
    String method = 'POST',
    Map<String, String>? fields,
    Map<String, File>? files,
    Map<String, List<File>>? multiFiles,
    Map<String, String>? headers,
    bool isFromLogin = false,
    bool isRetry = false,
  }) async => response;
  @override
  Future<NetworkResponse> postRequest({
    required String url,
    Map<String, dynamic>? body,
    bool isFromLogin = false,
    String? overrideToken,
    bool isRetry = false,
  }) async => response;
}

void main() {
  for (final url in [AppUrl.createEvent, AppUrl.createRoute, AppUrl.raffles]) {
    test(
      '$url propagates a denial and accepts a successful response',
      () async {
        final network = AccessNetwork();
        final repo = ExploreActivityRepository(network);
        await expectLater(
          repo.createActivity(url: url, body: {}),
          throwsA(predicate((e) => e.toString().contains('subscription'))),
        );
        network.entitled = true;
        expect(
          (await repo.createActivity(url: url, body: {}))['message'],
          'Created',
        );
      },
    );
  }
  for (final image in [false, true]) {
    test(
      'announcement ${image ? 'multipart' : 'JSON'} propagates denial and accepts success',
      () async {
        final network = AccessNetwork();
        final repo = CommunityRepository(network);
        Future<Map<String, dynamic>> send() => repo.createAnnouncement(
          fields: {},
          image: image ? File('unused') : null,
        );
        await expectLater(
          send(),
          throwsA(predicate((e) => e.toString().contains('subscription'))),
        );
        network.entitled = true;
        expect((await send())['message'], 'Created');
      },
    );
  }
}
