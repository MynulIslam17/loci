import 'package:flutter_test/flutter_test.dart';
import 'package:loci/features/auth/domain/services/social_auth_service.dart';

void main() {
  group('SocialAuthService Configuration Tests', () {
    test('iosClientId and webClientId are correctly configured', () {
      expect(
        SocialAuthService.iosClientId,
        '339606588573-nf9lhkj2qo4555mt7j4rmr4hjhllrb34.apps.googleusercontent.com',
      );
      expect(
        SocialAuthService.webClientId,
        '339606588573-ne1qjf5jbgsn90f6q5rjq6m3ouj652dn.apps.googleusercontent.com',
      );
    });

    test('isAppleSignInSupported evaluates boolean without crashing', () {
      final isSupported = SocialAuthService.isAppleSignInSupported;
      expect(isSupported, isA<bool>());
    });

    test('SocialAuthService can be instantiated', () {
      final service = SocialAuthService();
      expect(service, isNotNull);
    });
  });
}

