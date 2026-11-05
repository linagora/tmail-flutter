import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/push/state_change.dart';
import 'package:tmail_ui_user/features/push_notification/presentation/controller/fcm_message_controller.dart';
import 'package:tmail_ui_user/features/push_notification/presentation/extensions/state_change_merge_extension.dart';
import 'package:tmail_ui_user/features/push_notification/presentation/services/fcm_service.dart';
import 'package:tmail_ui_user/features/push_notification/presentation/utils/fcm_utils.dart';

void main() {
  final accountA = AccountId(Id('account-a'));
  final accountB = AccountId(Id('account-b'));
  const debounce = Duration(
    milliseconds: FcmUtils.durationBackgroundMessageComing,
  );

  Map<String, dynamic> payloadFor(AccountId accountId, String state) => {
        'data': {
          '${accountId.id.value}:Email': state,
        },
      };

  tearDown(() async {
    await FcmService.instance.closeStream();
  });

  test(
    'one background payload is handled once the debounce duration passes',
    () {
      fakeAsync((async) {
        FcmService.instance.initialStreamController();
        final batches = <List<Map<String, dynamic>>>[];
        final subscription = listenDebouncedBackgroundMessageBatches(
          FcmService.instance.backgroundMessageStreamController!.stream,
          batches.add,
          (e, st) => fail('$e\n$st'),
        );
        addTearDown(subscription.cancel);

        FcmService.instance.backgroundMessageStreamController!.add(
          payloadFor(accountA, 'state-a1'),
        );

        expect(batches, isEmpty);
        async.elapse(debounce);
        expect(batches, hasLength(1));
        expect(batches.single, [payloadFor(accountA, 'state-a1')]);
      });
    },
  );

  test(
    'two background payloads inside one debounce window are handled once and merged per account',
    () {
      fakeAsync((async) {
        FcmService.instance.initialStreamController();
        final batches = <List<Map<String, dynamic>>>[];
        final subscription = listenDebouncedBackgroundMessageBatches(
          FcmService.instance.backgroundMessageStreamController!.stream,
          batches.add,
          (e, st) => fail('$e\n$st'),
        );
        addTearDown(subscription.cancel);

        FcmService.instance.backgroundMessageStreamController!.add(
          payloadFor(accountA, 'state-a1'),
        );
        FcmService.instance.backgroundMessageStreamController!.add(
          payloadFor(accountB, 'state-b1'),
        );

        expect(batches, isEmpty);
        async.elapse(debounce);
        expect(batches, hasLength(1));
        expect(batches.single, [
          payloadFor(accountA, 'state-a1'),
          payloadFor(accountB, 'state-b1'),
        ]);

        final merged = batches.single
            .map(FcmUtils.instance.convertFirebaseDataMessageToStateChange)
            .whereType<StateChange>()
            .mergeAll();
        expect(merged!.changed.keys, {accountA, accountB});
        expect(merged.changed[accountA]!.typeState['Email'], 'state-a1');
        expect(merged.changed[accountB]!.typeState['Email'], 'state-b1');
      });
    },
  );

  test(
    'a sustained burst flushes once the max wait elapses',
    () {
      fakeAsync((async) {
        FcmService.instance.initialStreamController();
        final batches = <List<Map<String, dynamic>>>[];
        final subscription = listenDebouncedBackgroundMessageBatches(
          FcmService.instance.backgroundMessageStreamController!.stream,
          batches.add,
          (e, st) => fail('$e\n$st'),
        );
        addTearDown(subscription.cancel);

        FcmService.instance.backgroundMessageStreamController!.add(
          payloadFor(accountA, 'state-a1'),
        );
        async.elapse(const Duration(seconds: 10));
        FcmService.instance.backgroundMessageStreamController!.add(
          payloadFor(accountA, 'state-a2'),
        );
        async.elapse(const Duration(seconds: 10));
        FcmService.instance.backgroundMessageStreamController!.add(
          payloadFor(accountB, 'state-b1'),
        );

        expect(batches, isEmpty);
        async.elapse(const Duration(seconds: 10));
        expect(batches, hasLength(1));
        expect(batches.single, [
          payloadFor(accountA, 'state-a1'),
          payloadFor(accountA, 'state-a2'),
          payloadFor(accountB, 'state-b1'),
        ]);
      });
    },
  );

  test(
    'one malformed payload does not drop the other payloads in the batch',
    () {
      final merged = mergeBackgroundMessagePayloads([
        {'data': 'not-a-map'},
        payloadFor(accountA, 'state-a1'),
      ]);

      expect(merged, isNotNull);
      expect(merged!.changed.keys, {accountA});
      expect(merged.changed[accountA]!.typeState['Email'], 'state-a1');
    },
  );
}
