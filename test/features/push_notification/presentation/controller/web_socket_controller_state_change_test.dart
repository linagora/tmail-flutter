import 'package:fake_async/fake_async.dart';
import 'package:fcm/model/type_name.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/core/state.dart';
import 'package:jmap_dart_client/jmap/push/state_change.dart';
import 'package:jmap_dart_client/jmap/push/type_state.dart';
import 'package:mockito/mockito.dart';
import 'package:tmail_ui_user/features/base/action/ui_action.dart';
import 'package:tmail_ui_user/features/push_notification/presentation/action/push_notification_state_change_action.dart';
import 'package:tmail_ui_user/features/push_notification/presentation/controller/web_socket_controller.dart';
import 'package:tmail_ui_user/features/push_notification/presentation/utils/fcm_utils.dart';

import '../../../../fixtures/active_account_source_fixtures.dart';
import '../../../../fixtures/session_fixtures.dart';
import 'push_base_controller_test.mocks.dart';

void main() {
  final mine = AccountId(Id('mine'));
  final owner = AccountId(Id('owner'));
  final session = SessionFixtures.aliceSession;
  const debounce = Duration(milliseconds: FcmUtils.durationMessageComing);

  late MockEmailChangeListener emailChangeListener;
  late MockMailboxChangeListener mailboxChangeListener;
  late MockLabelChangeListener labelChangeListener;
  late List<List<Action>> dispatchedEmailActions;
  late WebSocketController controller;

  setUp(() {
    emailChangeListener = MockEmailChangeListener();
    mailboxChangeListener = MockMailboxChangeListener();
    labelChangeListener = MockLabelChangeListener();
    dispatchedEmailActions = [];
    when(emailChangeListener.dispatchActions(any)).thenAnswer((invocation) {
      dispatchedEmailActions.add(
        List<Action>.from(invocation.positionalArguments.first as List),
      );
    });
    controller = WebSocketController.forTesting(
      emailChangeListener: emailChangeListener,
      mailboxChangeListener: mailboxChangeListener,
      labelChangeListener: labelChangeListener,
    );
  });

  tearDown(() {
    controller.onClose();
    ActiveAccountSourceFixtures.unregister();
    Get.reset();
  });

  StateChange changeFor(AccountId accountId, String emailState) => StateChange(
        'StateChange',
        {accountId: TypeState({TypeName.emailType.value: emailState})},
      );

  List<SynchronizeEmailOnForegroundAction> emailSyncActions() =>
      dispatchedEmailActions
          .expand((actions) => actions)
          .whereType<SynchronizeEmailOnForegroundAction>()
          .toList();

  test(
    'two StateChange frames for different accounts inside the debounce window '
    'dispatch actions for both accounts',
    () {
      fakeAsync((async) {
        final source = ActiveAccountSourceFixtures.putShowing(owner);
        source.isSwitching = false;

        controller.receiveStateChangeFrame(
          changeFor(mine, 'mine-1'),
          personalAccountId: mine,
          session: session,
        );
        controller.receiveStateChangeFrame(
          changeFor(owner, 'owner-1'),
          personalAccountId: mine,
          session: session,
        );

        expect(dispatchedEmailActions, isEmpty);
        async.elapse(debounce);

        final syncs = emailSyncActions();
        expect(
          syncs.map((action) => action.accountId).toSet(),
          {mine, owner},
        );
        expect(
          syncs.singleWhere((action) => action.accountId == mine).newState,
          State('mine-1'),
        );
        expect(
          syncs.singleWhere((action) => action.accountId == owner).newState,
          State('owner-1'),
        );
        expect(
          syncs.singleWhere((action) => action.accountId == owner).refreshView,
          isTrue,
        );
        expect(
          syncs.singleWhere((action) => action.accountId == mine).refreshView,
          isFalse,
        );
        expect(
          syncs
              .singleWhere((action) => action.accountId == mine)
              .updateDeliveryAndNotifications,
          isTrue,
        );
        expect(
          syncs
              .singleWhere((action) => action.accountId == owner)
              .updateDeliveryAndNotifications,
          isFalse,
        );
        expect(
          syncs
              .singleWhere((action) => action.accountId == owner)
              .storeOfflineBodies,
          isFalse,
        );
      });
    },
  );

  test(
    'a StateChange for the active account while switching dispatches no view refresh for it',
    () {
      fakeAsync((async) {
        final source = ActiveAccountSourceFixtures.putShowing(owner);
        source.isSwitching = true;

        controller.receiveStateChangeFrame(
          changeFor(owner, 'owner-1'),
          personalAccountId: mine,
          session: session,
        );
        async.elapse(debounce);

        expect(emailSyncActions(), isEmpty);
        verifyNever(emailChangeListener.dispatchActions(any));
      });
    },
  );
}
