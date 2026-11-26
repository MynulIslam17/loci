import 'dart:async';

/// Emits a session key (`"<userId>|<role>"`) whenever the signed-in user or
/// their role changes — login, account switch, logout, or a member being
/// promoted to business owner.
///
/// [userId] and [role] are read *after* the triggering change settles (a
/// microtask later): `AuthController` updates `userModelRx` before `roleRx`,
/// so reading synchronously would see the new user with the old (null) role
/// and wrongly skip the subscription reload.
Stream<String> sessionChanges({
  required List<Stream<Object?>> triggers,
  required String? Function() userId,
  required String? Function() role,
}) {
  final List<StreamSubscription<Object?>> subs =
      <StreamSubscription<Object?>>[];
  late final StreamController<String> controller;
  bool scheduled = false;

  void emitSoon() {
    if (scheduled) return;
    scheduled = true;
    scheduleMicrotask(() {
      scheduled = false;
      if (!controller.isClosed) {
        controller.add('${userId() ?? ''}|${role() ?? ''}');
      }
    });
  }

  controller = StreamController<String>(
    onListen: () {
      for (final Stream<Object?> s in triggers) {
        subs.add(s.listen((_) => emitSoon()));
      }
    },
    onCancel: () async {
      for (final StreamSubscription<Object?> s in subs) {
        await s.cancel();
      }
    },
  );
  return controller.stream.distinct();
}
