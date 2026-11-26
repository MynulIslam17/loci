import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:loci/core/network/network_caller.dart';
import 'package:loci/core/network/network_response.dart';
import 'package:loci/features/my_business/data/models/submit_ad_request_model.dart';
import 'package:loci/features/my_business/data/repositories/my_business_repository.dart';
import 'package:loci/features/my_business/domain/services/my_business_service.dart';
import 'package:loci/features/my_business/presentation/controllers/create_ad_controller.dart';

class HeaderNetwork extends NetworkCaller {
  HeaderNetwork() : super(onUnAuthorize: () {}, accessToken: () => '');
  final List<Map<String, String>?> headers = <Map<String, String>?>[];

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
  }) async {
    this.headers.add(headers);
    return NetworkResponse(
      isSuccess: true,
      statusCode: 201,
      body: <String, dynamic>{'message': 'ok', 'creditsCharged': 10},
    );
  }
}

void main() {
  SubmitAdRequestModel request({String title = 'Grand opening'}) =>
      SubmitAdRequestModel(
        title: title,
        businessId: 'biz-1',
        endDate: DateTime.utc(2026, 12, 31),
        image: File('banner.jpg'),
      );

  test('same submission reuses the key; any edit gets a new one', () {
    final CreateAdController c = CreateAdController(
      MyBusinessService(MyBusinessRepository(HeaderNetwork())),
    );
    final String first = c.idempotencyKeyFor(request());
    expect(c.idempotencyKeyFor(request()), first, reason: 'retry');
    final String edited = c.idempotencyKeyFor(request(title: 'Grand opening!'));
    expect(edited, isNot(first));
    expect(RegExp(r'^[0-9a-f-]{36}$').hasMatch(edited), isTrue);
  });

  test('repository sends the Idempotency-Key header and businessId field', () async {
    final HeaderNetwork network = HeaderNetwork();
    final MyBusinessService service = MyBusinessService(
      MyBusinessRepository(network),
    );
    await service.submitAd(request(), idempotencyKey: 'key-1');
    expect(network.headers.single, <String, String>{'Idempotency-Key': 'key-1'});
    expect(request().toFields()['businessId'], 'biz-1');
  });
}
