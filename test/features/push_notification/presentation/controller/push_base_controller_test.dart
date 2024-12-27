import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:fcm/model/type_name.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/core/state.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:tmail_ui_user/features/push_notification/presentation/action/push_notification_state_change_action.dart';
import 'package:tmail_ui_user/features/push_notification/presentation/controller/push_base_controller.dart';
import 'package:tmail_ui_user/features/push_notification/presentation/listener/email_change_listener.dart';
import 'package:tmail_ui_user/features/push_notification/presentation/listener/mailbox_change_listener.dart';

import 'push_base_controller_test.mocks.dart';

class TestPushController extends PushBaseController {
  @override
  void handleFailureViewState(Failure failure) {}

  @override
  void handleSuccessViewState(Success success) {}
}

@GenerateNiceMocks([
  MockSpec<EmailChangeListener>(),
  MockSpec<MailboxChangeListener>(),
])
void main() {
  final accountId = AccountId(Id('accountId'));
  final userName = UserName('userName');

  group('push base controller test:', () {
    group('mappingTypeStateToAction:', () {
      final emailChangeListener = MockEmailChangeListener();
      final mailboxChangeListener = MockMailboxChangeListener();

      test(
        'should call emailChangeListener.dispatchActions with nothing '
        'when mapTypeState contains emailDelivery '
        'and isForeground is true',
      () {
        // arrange
        final state = State('some-state');
        final mapTypeState = {TypeName.emailDelivery.value: state.value};

        // act
        final pushBaseController = TestPushController();
        pushBaseController.mappingTypeStateToAction(
          mapTypeState,
          accountId,
          userName,
          isForeground: true,
          emailChangeListener: emailChangeListener,
          mailboxChangeListener: mailboxChangeListener
        );

        // assert
        verifyNever(emailChangeListener.dispatchActions(any));
        verifyNever(mailboxChangeListener.dispatchActions(any));
      });

      test(
        'should call emailChangeListener.dispatchActions with PushNotificationAction '
        'when mapTypeState contains emailDelivery '
        'and isForeground is false',
      () {
        // arrange
        final state = State('some-state');
        final mapTypeState = {TypeName.emailDelivery.value: state.value};

        // act
        final pushBaseController = TestPushController();
        pushBaseController.mappingTypeStateToAction(
          mapTypeState,
          accountId,
          userName,
          isForeground: false,
          emailChangeListener: emailChangeListener,
          mailboxChangeListener: mailboxChangeListener
        );

        // assert
        verify(
          emailChangeListener.dispatchActions([
            PushNotificationAction(
              TypeName.emailDelivery,
              state,
              null,
              accountId,
              userName,
            ),
          ]),
        ).called(1);
        verifyNever(mailboxChangeListener.dispatchActions(any));
      });
      
      test(
        'should call mailboxChangeListener.dispatchActions with SynchronizeMailboxOnForegroundAction '
        'when mapTypeState contains mailboxType '
        'and isForeground is true',
      () {
        // arrange
        final state = State('some-state');
        final mapTypeState = {TypeName.mailboxType.value: state.value};

        // act
        final pushBaseController = TestPushController();
        pushBaseController.mappingTypeStateToAction(
          mapTypeState,
          accountId,
          userName,
          isForeground: true,
          emailChangeListener: emailChangeListener,
          mailboxChangeListener: mailboxChangeListener
        );

        // assert
        verify(
          mailboxChangeListener.dispatchActions([
            SynchronizeMailboxOnForegroundAction(
              TypeName.mailboxType,
              state,
              accountId,
            ),
          ]),
        ).called(1);
        verifyNever(emailChangeListener.dispatchActions(any));
      });

      test(
        'should call mailboxChangeListener.dispatchActions with StoreMailboxStateToRefreshAction '
        'when mapTypeState contains mailboxType '
        'and isForeground is false',
      () {
        // arrange
        final state = State('some-state');
        final mapTypeState = {TypeName.mailboxType.value: state.value};

        // act
        final pushBaseController = TestPushController();
        pushBaseController.mappingTypeStateToAction(
          mapTypeState,
          accountId,
          userName,
          isForeground: false,
          emailChangeListener: emailChangeListener,
          mailboxChangeListener: mailboxChangeListener
        );

        // assert
        verify(
          mailboxChangeListener.dispatchActions([
            StoreMailboxStateToRefreshAction(
              TypeName.mailboxType,
              state,
              accountId,
              userName,
            ),
          ]),
        ).called(1);
        verifyNever(emailChangeListener.dispatchActions(any));
      });
    });
  });
}