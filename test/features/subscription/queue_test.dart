import 'package:flutter_test/flutter_test.dart';
import 'package:loci/features/subscription/data/storage/pending_verification_queue.dart';

import 'fakes.dart';

void main() {
  final Map<String, dynamic> a = <String, dynamic>{
    'platform': 'apple',
    'productId': 'm',
    'transactionId': '1',
  };
  final Map<String, dynamic> b = <String, dynamic>{
    'platform': 'google',
    'productId': 'm',
    'purchaseToken': 'tok',
  };

  late MemoryQueueStore store;
  late DateTime now;
  late PendingVerificationQueue queue;

  setUp(() {
    store = MemoryQueueStore();
    now = DateTime.utc(2026, 11, 25, 10);
    queue = PendingVerificationQueue(store: store, clock: () => now);
  });

  test('save dedupes, remove deletes, empty queue clears storage', () async {
    await queue.save('u1', a);
    await queue.save('u1', a);
    await queue.save('u1', b);
    expect((await queue.entries('u1')).length, 2);
    await queue.remove('u1', a);
    expect((await queue.entries('u1')).single.body, b);
    await queue.remove('u1', b);
    expect(store.values, isEmpty);
  });

  test('is keyed per user', () async {
    await queue.save('userA', a);
    expect(await queue.entries('userB'), isEmpty);
    expect(await queue.entries(''), isEmpty);
    await queue.save('', a);
    expect(store.values.keys, <String>['iap-pending-verify-userA']);
  });

  test('backs off 5s, 30s, 2m, 10m then waits for next launch', () async {
    await queue.save('u', a);
    expect((await queue.due('u')).length, 1);

    const List<Duration> steps = PendingVerificationQueue.backoff;
    for (final Duration step in steps) {
      await queue.markAttempt('u', a);
      expect(await queue.due('u'), isEmpty);
      now = now.add(step);
      expect((await queue.due('u')).length, 1, reason: 'due after $step');
    }
    await queue.markAttempt('u', a);
    now = now.add(const Duration(days: 1));
    expect(await queue.due('u'), isEmpty);
    // Launch ignores backoff.
    expect((await queue.due('u', ignoreBackoff: true)).length, 1);
  });

  test('re-saving an existing entry keeps its backoff', () async {
    await queue.save('u', a);
    await queue.markAttempt('u', a);
    await queue.save('u', a);
    expect((await queue.entries('u')).single.attempts, 1);
  });

  test('survives a restart (persisted JSON) and ignores corrupt data', () async {
    await queue.save('u', b);
    final PendingVerificationQueue reopened = PendingVerificationQueue(
      store: store,
      clock: () => now,
    );
    expect((await reopened.entries('u')).single.body, b);
    store.values['iap-pending-verify-x'] = '{not json';
    expect(await reopened.entries('x'), isEmpty);
  });
}
