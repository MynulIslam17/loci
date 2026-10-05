import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:loci/core/network/network_caller.dart';
import 'package:loci/core/services/socket/chat_socket_service.dart';
import 'package:loci/features/auth/data/models/user_model.dart';
import 'package:loci/features/auth/data/repositories/auth_repository.dart';
import 'package:loci/features/auth/domain/services/auth_service.dart';
import 'package:loci/features/auth/presentation/controllers/auth_controller.dart';

class _SignupRepository implements AuthRepository {
  String? savedRefreshToken;

  @override
  Future<Map<String, dynamic>> verifySignupOtp({
    required String email,
    required String otp,
  }) async => {
    'message': 'Verified',
    'data': {
      'user': {'id': 'user-1', 'name': 'Test User', 'email': email},
      'accessToken': 'access-1',
      'refreshToken': 'refresh-1',
    },
  };

  @override
  Future<void> saveUserData({
    required UserModel model,
    required String token,
    String? refreshToken,
  }) async {
    savedRefreshToken = refreshToken;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _UnusedAuthService implements AuthService {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _TestAuthController extends AuthController {
  _TestAuthController() : super(_UnusedAuthService());

  @override
  Future<void> loadUserData() async {}
}

class _TrackingSocketService extends ChatSocketService {
  int connectCalls = 0;

  @override
  void connect({bool force = false}) {
    connectCalls++;
  }
}

void main() {
  test('signup verification saves and returns the refresh token', () async {
    final repository = _SignupRepository();
    final result = await AuthService(
      repository,
    ).verifySignupOtp(email: 'test@example.com', otp: '123456');

    expect(result.token, 'access-1');
    expect(result.refreshToken, 'refresh-1');
    expect(repository.savedRefreshToken, 'refresh-1');
  });

  test('a late 401 retries with the token already refreshed', () async {
    final oldRequestReceived = Completer<void>();
    final releaseOldRequest = Completer<void>();
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    addTearDown(() async => server.close(force: true));

    server.listen((request) async {
      final token = request.headers.value(HttpHeaders.authorizationHeader);
      if (request.uri.path == '/slow' && token == 'Bearer old-token') {
        oldRequestReceived.complete();
        await releaseOldRequest.future;
      }
      request.response.statusCode = token == 'Bearer new-token' ? 200 : 401;
      request.response.headers.contentType = ContentType.json;
      request.response.write(jsonEncode({'ok': token == 'Bearer new-token'}));
      await request.response.close();
    });

    var activeToken = 'old-token';
    var refreshCalls = 0;
    var unauthorizedCalls = 0;
    final caller = NetworkCaller(
      accessToken: () => activeToken,
      onRefreshToken: () async {
        refreshCalls++;
        activeToken = 'new-token';
        return true;
      },
      onUnAuthorize: () => unauthorizedCalls++,
    );
    final baseUrl = 'http://${server.address.host}:${server.port}';

    final slowRequest = caller.getRequest(url: '$baseUrl/slow');
    await oldRequestReceived.future;
    final firstResult = await caller.getRequest(url: '$baseUrl/fast');
    releaseOldRequest.complete();
    final slowResult = await slowRequest;

    expect(firstResult.isSuccess, isTrue);
    expect(slowResult.isSuccess, isTrue);
    expect(refreshCalls, 1);
    expect(unauthorizedCalls, 0);
  });

  test('an explicit session token is replaced on retry', () async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    addTearDown(() async => server.close(force: true));
    server.listen((request) async {
      final token = request.headers.value(HttpHeaders.authorizationHeader);
      request.response.statusCode = token == 'Bearer new-token' ? 200 : 401;
      request.response.headers.contentType = ContentType.json;
      request.response.write('{}');
      await request.response.close();
    });

    var activeToken = 'old-token';
    var refreshCalls = 0;
    final caller = NetworkCaller(
      accessToken: () => activeToken,
      onRefreshToken: () async {
        refreshCalls++;
        activeToken = 'new-token';
        return true;
      },
      onUnAuthorize: () {},
    );
    final url = 'http://${server.address.host}:${server.port}/post';

    final result = await caller.postRequest(
      url: url,
      body: {'value': 1},
      overrideToken: 'old-token',
    );

    expect(result.isSuccess, isTrue);
    expect(refreshCalls, 1);
  });

  test('a temporary token 401 does not refresh the session', () async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    addTearDown(() async => server.close(force: true));
    server.listen((request) async {
      request.response.statusCode = 401;
      request.response.headers.contentType = ContentType.json;
      request.response.write('{}');
      await request.response.close();
    });

    var refreshCalls = 0;
    var unauthorizedCalls = 0;
    final caller = NetworkCaller(
      accessToken: () => 'session-token',
      onRefreshToken: () async {
        refreshCalls++;
        return true;
      },
      onUnAuthorize: () => unauthorizedCalls++,
    );
    final url = 'http://${server.address.host}:${server.port}/post';

    final result = await caller.postRequest(
      url: url,
      overrideToken: 'temporary-token',
    );

    expect(result.statusCode, 401);
    expect(refreshCalls, 0);
    expect(unauthorizedCalls, 0);
  });

  test('chat socket reconnects when the access token changes', () async {
    final auth = Get.put<AuthController>(_TestAuthController());
    final socket =
        Get.put<ChatSocketService>(_TrackingSocketService())
            as _TrackingSocketService;
    addTearDown(Get.reset);

    auth.accessTokenRx.value = 'access-1';
    await Future<void>.delayed(Duration.zero);
    expect(socket.connectCalls, 1);

    auth.accessTokenRx.value = 'access-1';
    await Future<void>.delayed(Duration.zero);
    expect(socket.connectCalls, 1);

    auth.accessTokenRx.value = 'access-2';
    await Future<void>.delayed(Duration.zero);
    expect(socket.connectCalls, 2);

    Get.delete<ChatSocketService>(force: true);
    auth.accessTokenRx.value = 'access-3';
    await Future<void>.delayed(Duration.zero);
    expect(socket.connectCalls, 2);
  });
}
