import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:loci/features/subscription/data/models/purchase_evidence.dart';

/// Minimal key/value store so the queue can be unit tested without the
/// platform keychain.
abstract class QueueStore {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
  Future<void> delete(String key);
}

/// Keychain / Keystore backed store — a Google purchase token is a credential.
class SecureQueueStore implements QueueStore {
  SecureQueueStore([FlutterSecureStorage? storage])
    : _storage =
          storage ??
          const FlutterSecureStorage(
            aOptions: AndroidOptions(encryptedSharedPreferences: true),
            iOptions: IOSOptions(
              accessibility: KeychainAccessibility.first_unlock,
            ),
          );

  final FlutterSecureStorage _storage;

  @override
  Future<String?> read(String key) => _storage.read(key: key);

  @override
  Future<void> write(String key, String value) =>
      _storage.write(key: key, value: value);

  @override
  Future<void> delete(String key) => _storage.delete(key: key);
}

/// One unverified purchase waiting for a definitive server answer.
class PendingVerification {
  PendingVerification({
    required this.body,
    this.attempts = 0,
    DateTime? nextAttemptAt,
  }) : nextAttemptAt = nextAttemptAt ?? DateTime.fromMillisecondsSinceEpoch(0);

  final Map<String, dynamic> body;
  final int attempts;
  final DateTime nextAttemptAt;

  String get key => verifyBodyKey(body);

  bool isDue(DateTime now) => !nextAttemptAt.isAfter(now);

  PendingVerification copyWith({int? attempts, DateTime? nextAttemptAt}) =>
      PendingVerification(
        body: body,
        attempts: attempts ?? this.attempts,
        nextAttemptAt: nextAttemptAt ?? this.nextAttemptAt,
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'body': body,
    'attempts': attempts,
    'nextAttemptAt': nextAttemptAt.toUtc().toIso8601String(),
  };

  static PendingVerification? fromJson(Object? json) {
    if (json is! Map) return null;
    final Object? body = json['body'];
    if (body is! Map) return null;
    return PendingVerification(
      body: Map<String, dynamic>.from(body),
      attempts: (json['attempts'] as num?)?.toInt() ?? 0,
      nextAttemptAt: DateTime.tryParse(json['nextAttemptAt']?.toString() ?? ''),
    );
  }
}

/// Persists purchase evidence until `POST /subscriptions/verify` answers
/// definitively (spec §5). Keyed by Loci user id so user A's purchase is never
/// verified while user B is signed in.
class PendingVerificationQueue {
  PendingVerificationQueue({QueueStore? store, DateTime Function()? clock})
    : _store = store ?? SecureQueueStore(),
      _clock = clock ?? DateTime.now;

  final QueueStore _store;
  final DateTime Function() _clock;

  /// Backoff after the Nth failed attempt (1-based); after the last step the
  /// entry is only retried on the next launch.
  static const List<Duration> backoff = <Duration>[
    Duration(seconds: 5),
    Duration(seconds: 30),
    Duration(minutes: 2),
    Duration(minutes: 10),
  ];

  static String _storageKey(String userId) => 'iap-pending-verify-$userId';

  Future<List<PendingVerification>> entries(String userId) async {
    if (userId.isEmpty) return const <PendingVerification>[];
    final String? raw = await _store.read(_storageKey(userId));
    if (raw == null || raw.isEmpty) return <PendingVerification>[];
    try {
      final Object? decoded = jsonDecode(raw);
      if (decoded is! List) return <PendingVerification>[];
      return decoded
          .map(PendingVerification.fromJson)
          .whereType<PendingVerification>()
          .toList();
    } catch (_) {
      return <PendingVerification>[];
    }
  }

  /// Entries whose backoff has elapsed. [ignoreBackoff] is used on launch.
  Future<List<PendingVerification>> due(
    String userId, {
    bool ignoreBackoff = false,
  }) async {
    final DateTime now = _clock();
    final List<PendingVerification> all = await entries(userId);
    if (ignoreBackoff) return all;
    return all.where((PendingVerification e) => e.isDue(now)).toList();
  }

  /// Adds (or keeps) the body. Saving the same purchase twice is a no-op so a
  /// re-delivered transaction doesn't reset its backoff.
  Future<void> save(String userId, Map<String, dynamic> body) async {
    if (userId.isEmpty) return;
    final List<PendingVerification> all = await entries(userId);
    final String key = verifyBodyKey(body);
    if (all.any((PendingVerification e) => e.key == key)) return;
    all.add(PendingVerification(body: Map<String, dynamic>.from(body)));
    await _write(userId, all);
  }

  Future<void> remove(String userId, Map<String, dynamic> body) async {
    if (userId.isEmpty) return;
    final List<PendingVerification> all = await entries(userId);
    final String key = verifyBodyKey(body);
    final int before = all.length;
    all.removeWhere((PendingVerification e) => e.key == key);
    if (all.length != before) await _write(userId, all);
  }

  /// Records a non-definitive attempt and schedules the next one.
  Future<void> markAttempt(String userId, Map<String, dynamic> body) async {
    if (userId.isEmpty) return;
    final List<PendingVerification> all = await entries(userId);
    final String key = verifyBodyKey(body);
    final int index = all.indexWhere((PendingVerification e) => e.key == key);
    if (index < 0) return;
    final int attempts = all[index].attempts + 1;
    final DateTime now = _clock();
    final DateTime next = attempts <= backoff.length
        ? now.add(backoff[attempts - 1])
        // Exhausted: wait for the next launch (which ignores backoff).
        : now.add(const Duration(days: 3650));
    all[index] = all[index].copyWith(attempts: attempts, nextAttemptAt: next);
    await _write(userId, all);
  }

  Future<void> _write(String userId, List<PendingVerification> all) async {
    if (all.isEmpty) {
      await _store.delete(_storageKey(userId));
      return;
    }
    await _store.write(
      _storageKey(userId),
      jsonEncode(all.map((PendingVerification e) => e.toJson()).toList()),
    );
  }
}
