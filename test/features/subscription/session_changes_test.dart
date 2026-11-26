import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:loci/features/subscription/presentation/session_changes.dart';

void main() {
  test('reads role after user AND role settle (AuthController sets user first)', () async {
    final Rxn<String> user = Rxn<String>();
    final Rxn<String> role = Rxn<String>();
    final List<String> seen = <String>[];
    final sub = sessionChanges(
      triggers: <Stream<Object?>>[user.stream, role.stream],
      userId: () => user.value,
      role: () => role.value,
    ).listen(seen.add);

    // Same order as AuthController.saveUserData / loadUserData.
    user.value = 'u1';
    role.value = 'business_owner';
    await pumpEventQueue();
    expect(seen, <String>['u1|business_owner']);

    // Member promoted to owner (claim business) → new event.
    role.value = 'admin';
    await pumpEventQueue();
    // Logout.
    user.value = null;
    role.value = null;
    await pumpEventQueue();
    expect(seen, <String>['u1|business_owner', 'u1|admin', '|']);
    await sub.cancel();
  });
}
