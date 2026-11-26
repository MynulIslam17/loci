import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:loci/features/auth/data/models/user_model.dart';
import 'package:loci/features/auth/domain/services/auth_service.dart';
import 'package:loci/features/auth/presentation/controllers/auth_controller.dart';
import 'package:loci/features/my_business/data/models/my_business_list_model.dart';
import 'package:loci/features/my_business/domain/services/my_business_service.dart';
import 'package:loci/features/my_business/presentation/controllers/get_my_business_list_controller.dart';
import 'package:loci/features/subscription/presentation/subscription_entry.dart';

String jwt(String role) {
  String part(Object o) =>
      base64Url.encode(utf8.encode(jsonEncode(o))).replaceAll('=', '');
  return '${part(<String, String>{'alg': 'HS256'})}.'
      '${part(<String, String>{'sub': 'u1', 'role': role})}.sig';
}

UserModel user(String role) => UserModel.fromJson(<String, dynamic>{
  '_id': 'u1',
  'name': 'Noyon',
  'email': 'noyon@example.com',
  'role': role,
});

/// Server says [serverRole]; the device still has the session it logged in
/// with ([storedRole], token issued with that role).
class FakeAuthService implements AuthService {
  FakeAuthService({required this.storedRole, required this.serverRole});

  String storedRole;
  String serverRole;
  int getMeCalls = 0;
  Completer<void>? gate;

  @override
  Future<({UserModel? user, String? token, String? role})>
  loadSession() async =>
      (user: user(storedRole), token: jwt(storedRole), role: storedRole);

  @override
  Future<UserModel> getMe() async {
    getMeCalls++;
    await gate?.future;
    return user(serverRole);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeBusinessService implements MyBusinessService {
  List<BusinessModel> owned = <BusinessModel>[];

  @override
  Future<List<BusinessModel>> getMyBusinesses({String? category}) async =>
      owned;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

BusinessModel burgerKing() => BusinessModel.fromJson(<String, dynamic>{
  '_id': 'b1',
  'name': 'Burger King Banani',
  'category': 'Foodie',
});

void main() {
  late FakeAuthService authService;
  late int tokenRefreshes;
  late DateTime now;

  AuthController auth() => AuthController(
    authService,
    refreshAccessToken: () async {
      tokenRefreshes++;
      return true;
    },
    clock: () => now,
    observeLifecycle: false,
  );

  setUp(() {
    Get.testMode = true;
    tokenRefreshes = 0;
    now = DateTime(2026, 11, 26, 15);
    authService = FakeAuthService(
      storedRole: 'user',
      serverRole: 'business_owner',
    );
  });
  tearDown(Get.reset);

  group('AuthController role refresh', () {
    test('launch picks up a claim approved while the app was closed', () async {
      final AuthController c = auth()..onInit();
      await pumpEventQueue();
      expect(c.role, 'business_owner');
      expect(c.isBusinessOwner, isTrue);
      expect(c.canAccessSubscription, isTrue);
    });

    test(
      'a role change replaces the access token (it embeds the role)',
      () async {
        auth().onInit();
        await pumpEventQueue();
        expect(tokenRefreshes, 1);
      },
    );

    test('the new token is in place before the role changes', () async {
      late final AuthController c;
      String? roleWhenTokenRefreshed;
      c = AuthController(
        authService,
        refreshAccessToken: () async {
          roleWhenTokenRefreshed = c.role;
          return true;
        },
        clock: () => now,
        observeLifecycle: false,
      )..onInit();
      await pumpEventQueue();
      expect(roleWhenTokenRefreshed, 'user');
      expect(c.role, 'business_owner');
    });

    test('subscription unlocks when the role changes', () async {
      authService.serverRole = 'user';
      final AuthController c = auth()..onInit();
      await pumpEventQueue();
      expect(subscriptionLocked(c), isTrue);
      authService.serverRole = 'business_owner';
      await c.refreshUser();
      expect(subscriptionLocked(c), isFalse);
    });

    test('no token refresh when the role is unchanged', () async {
      authService.serverRole = 'user';
      final AuthController c = auth()..onInit();
      await pumpEventQueue();
      expect(c.role, 'user');
      expect(tokenRefreshes, 0);
    });

    test('concurrent refreshes share one request', () async {
      final AuthController c = auth()..onInit();
      await pumpEventQueue();
      authService.getMeCalls = 0;
      authService.gate = Completer<void>();
      final List<Future<bool>> calls = <Future<bool>>[
        c.refreshUser(),
        c.refreshUser(),
        c.refreshUser(),
      ];
      authService.gate!.complete();
      await Future.wait(calls);
      expect(authService.getMeCalls, 1);
    });

    test('resume refresh is throttled; forced refresh is not', () async {
      final AuthController c = auth()..onInit();
      await pumpEventQueue();
      authService.getMeCalls = 0;
      await c.refreshUser(force: false);
      expect(authService.getMeCalls, 0, reason: 'just refreshed');
      now = now.add(AuthController.resumeRefreshInterval);
      await c.refreshUser(force: false);
      expect(authService.getMeCalls, 1);
      await c.refreshUser();
      expect(authService.getMeCalls, 2);
    });

    test('an unchanged user is not re-published (no session change)', () async {
      authService.serverRole = 'user';
      final AuthController c = auth()..onInit();
      await pumpEventQueue();
      int emissions = 0;
      c.userModelRx.listen((_) => emissions++);
      c.roleRx.listen((_) => emissions++);
      await c.refreshUser();
      await c.refreshUser();
      await pumpEventQueue();
      expect(emissions, 0);
    });

    test('jwtRole', () {
      expect(AuthController.jwtRole(jwt('user')), 'user');
      expect(AuthController.jwtRole('not-a-jwt'), isNull);
      expect(AuthController.jwtRole(null), isNull);
    });
  });

  group('Business Profiles after a claim is approved', () {
    late FakeBusinessService businesses;

    setUp(() => businesses = FakeBusinessService()..owned = [burgerKing()]);

    test('stale local role still shows the owned business', () async {
      authService.serverRole = 'user'; // server role not updated yet
      final AuthController a = auth();
      a.onInit();
      await pumpEventQueue();
      final GetMyBusinessController c = GetMyBusinessController(
        businesses,
        auth: a,
      )..onInit();
      await pumpEventQueue();
      expect(c.isBusinessOwner.value, isTrue);
      expect(c.businessList.single.name, 'Burger King Banani');
    });

    test('screen updates when the role changes while it is open', () async {
      authService.serverRole = 'user';
      businesses.owned = <BusinessModel>[];
      final AuthController a = auth()..onInit();
      await pumpEventQueue();
      final GetMyBusinessController c = GetMyBusinessController(
        businesses,
        auth: a,
      )..onInit();
      await pumpEventQueue();
      expect(c.isBusinessOwner.value, isFalse);

      // Admin approves the claim; a push / resume refreshes the role.
      authService.serverRole = 'business_owner';
      businesses.owned = <BusinessModel>[burgerKing()];
      await a.refreshUser();
      await pumpEventQueue();
      expect(a.isBusinessOwner, isTrue);
      expect(c.isBusinessOwner.value, isTrue);
      expect(c.businessList.single.name, 'Burger King Banani');
    });

    test('member with no business sees the not-owner state', () async {
      authService.serverRole = 'user';
      businesses.owned = <BusinessModel>[];
      final AuthController a = auth()..onInit();
      await pumpEventQueue();
      final GetMyBusinessController c = GetMyBusinessController(
        businesses,
        auth: a,
      )..onInit();
      await pumpEventQueue();
      expect(c.isBusinessOwner.value, isFalse);
    });
  });
}
