import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:loci/core/network/network_caller.dart';
import 'package:loci/features/my_business/data/repositories/my_business_repository.dart';
import 'package:loci/core/network/network_response.dart';

class AdNetwork extends NetworkCaller {
  AdNetwork() : super(onUnAuthorize: () {}, accessToken: () => '');
  @override
  Future<NetworkResponse> multipartRequest({required String url, String method = 'POST', Map<String, String>? fields, Map<String, File>? files, Map<String, List<File>>? multiFiles, Map<String, String>? headers, bool isFromLogin = false, bool isRetry = false}) async => NetworkResponse(isSuccess: false, statusCode: 403, body: {'code': 'INSUFFICIENT_SPOTLIGHT_CREDITS', 'message': 'Forbidden'}, errorMessage: 'Insufficient Spotlight credits.');
}

void main() {
  test('ad repository preserves structured credit denial', () async {
    final repository = MyBusinessRepository(AdNetwork());
    await expectLater(repository.submitAd(fields: {}, image: File('unused')), throwsA(predicate((e) => e.toString().contains('Spotlight credits'))));
  });
  test('structured denials reach JSON and multipart clients even with generic messages', () async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    final requests = server.listen((request) async {
      await request.drain<void>();
      request.response.statusCode = 403;
      request.response.headers.contentType = ContentType.json;
      request.response.write(jsonEncode({'code': request.uri.path == '/ad' ? 'INSUFFICIENT_SPOTLIGHT_CREDITS' : 'SUBSCRIPTION_REQUIRED', 'message': 'Forbidden'}));
      await request.response.close();
    });
    final network = NetworkCaller(onUnAuthorize: () {}, accessToken: () => '');
    final base = 'http://127.0.0.1:${server.port}';
    final hooked = <String>[];
    NetworkCaller.onErrorCode = (status, code, message) => hooked.add('$status $code');
    addTearDown(() => NetworkCaller.onErrorCode = null);
    final json = await network.postRequest(url: '$base/event');
    final multipart = await network.multipartRequest(url: '$base/ad');
    final get = await network.getRequest(url: '$base/event');
    expect(json.errorMessage, contains('subscription'));
    expect(json.errorCode, 'SUBSCRIPTION_REQUIRED');
    expect(multipart.errorMessage, contains('Spotlight credits'));
    expect(multipart.errorCode, 'INSUFFICIENT_SPOTLIGHT_CREDITS');
    // GET responses carry the code too (they used to drop the body).
    expect(get.errorCode, 'SUBSCRIPTION_REQUIRED');
    // The network layer routes every coded failure through one hook.
    expect(hooked, ['403 SUBSCRIPTION_REQUIRED', '403 INSUFFICIENT_SPOTLIGHT_CREDITS', '403 SUBSCRIPTION_REQUIRED']);
    await requests.cancel();
    await server.close(force: true);
  });
}
