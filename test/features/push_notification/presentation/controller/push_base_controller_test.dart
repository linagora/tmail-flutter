import 'dart:async';

import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart' show Either, Left, Right;
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
  int successCount = 0;
  int failureCount = 0;

  @override
  void handleFailureViewState(Failure failure) {
    failureCount++;
  }

  @override
  void handleSuccessViewState(Success success) {
    successCount++;
  }
}

class _FakeSuccess extends Success {
  @override
  List<Object?> get props => [];
}

class _FakeFailure extends FeatureFailure {
  _FakeFailure() : super();
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
        'should call emailChangeListener.dispatchActions with SynchronizeEmailOnForegroundAction '
        'when mapTypeState contains emailType '
        'and isForeground is true',
        () {
          // arrange
          final state = State('some-state');
          final mapTypeState = {TypeName.emailType.value: state.value};

          // act
          final pushBaseController = TestPushController();
          pushBaseController.mappingTypeStateToAction(
            mapTypeState,
            accountId,
            userName,
            isForeground: true,
            emailChangeListener: emailChangeListener,
            mailboxChangeListener: mailboxChangeListener,
          );

          // assert
          verify(
            emailChangeListener.dispatchActions([
              SynchronizeEmailOnForegroundAction(
                TypeName.emailType,
                state,
                accountId,
                null,
              ),
            ]),
          ).called(1);
          verifyNever(mailboxChangeListener.dispatchActions(any));
        },
      );

      test(
        'should call emailChangeListener.dispatchActions with StoreEmailStateToRefreshAction '
        'when mapTypeState contains emailType '
        'and isForeground is false',
        () {
          // arrange
          final state = State('some-state');
          final mapTypeState = {TypeName.emailType.value: state.value};

          // act
          final pushBaseController = TestPushController();
          pushBaseController.mappingTypeStateToAction(
            mapTypeState,
            accountId,
            userName,
            isForeground: false,
            emailChangeListener: emailChangeListener,
            mailboxChangeListener: mailboxChangeListener,
          );

          // assert
          verify(
            emailChangeListener.dispatchActions([
              StoreEmailStateToRefreshAction(
                TypeName.emailType,
                state,
                accountId,
                userName,
                null,
              ),
            ]),
          ).called(1);
          verifyNever(mailboxChangeListener.dispatchActions(any));
        },
      );

      test(
        'should call emailChangeListener.dispatchActions with SynchronizeEmailOnForegroundAction '
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
            mailboxChangeListener: mailboxChangeListener,
          );

          // assert
          // emailDelivery in foreground should now trigger sync to show new emails
          verify(
            emailChangeListener.dispatchActions([
              SynchronizeEmailOnForegroundAction(
                TypeName.emailDelivery,
                state,
                accountId,
                null,
              ),
            ]),
          ).called(1);
          verifyNever(mailboxChangeListener.dispatchActions(any));
        },
      );

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
            mailboxChangeListener: mailboxChangeListener,
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
        },
      );

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
            mailboxChangeListener: mailboxChangeListener,
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
        },
      );

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
            mailboxChangeListener: mailboxChangeListener,
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
        },
      );
    });

    group('consumeState lifecycle:', () {
      test(
        'should cancel consumed stream subscriptions when onClose is called',
        () async {
          final pushBaseController = TestPushController();
          final streamController = StreamController<Either<Failure, Success>>();

          pushBaseController.consumeState(streamController.stream);

          streamController.add(Right<Failure, Success>(_FakeSuccess()));
          await Future.microtask(() {});

          expect(pushBaseController.successCount, 1);

          pushBaseController.onClose();

          streamController.add(Right<Failure, Success>(_FakeSuccess()));
          streamController.add(Left<Failure, Success>(_FakeFailure()));
          await Future.microtask(() {});
          await Future.microtask(() {});

          expect(
            pushBaseController.successCount,
            1,
            reason: 'Success events leaked through after onClose',
          );
          expect(
            pushBaseController.failureCount,
            0,
            reason: 'Failure events leaked through after onClose',
          );

          await streamController.close();
        },
      );
    });
  });
}
