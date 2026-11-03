import 'dart:async';

import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/utils/platform_info.dart';
import 'package:dartz/dartz.dart';
import 'package:fcm/model/type_name.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/core/state.dart' as jmap;
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:model/email/presentation_email.dart';
import 'package:tmail_ui_user/features/email/presentation/action/email_ui_action.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/push_notification/domain/repository/fcm_repository.dart';
import 'package:tmail_ui_user/features/push_notification/domain/state/get_email_changes_to_push_notification_state.dart';
import 'package:tmail_ui_user/features/push_notification/domain/state/get_mailboxes_not_put_notifications_state.dart';
import 'package:tmail_ui_user/features/push_notification/domain/state/get_stored_email_delivery_state.dart';
import 'package:tmail_ui_user/features/push_notification/domain/usecases/get_email_changes_to_push_notification_interactor.dart';
import 'package:tmail_ui_user/features/push_notification/domain/usecases/get_mailboxes_not_put_notifications_interactor.dart';
import 'package:tmail_ui_user/features/push_notification/domain/usecases/get_stored_email_delivery_state_interactor.dart';
import 'package:tmail_ui_user/features/push_notification/domain/usecases/store_email_delivery_state_interactor.dart';
import 'package:tmail_ui_user/features/push_notification/presentation/action/push_notification_state_change_action.dart';
import 'package:tmail_ui_user/features/push_notification/presentation/listener/email_change_listener.dart';

import '../../../../fixtures/session_fixtures.dart';

class _UnusedFcmRepository implements FCMRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _RecordingGetStoredEmailDeliveryStateInteractor
    extends GetStoredEmailDeliveryStateInteractor {
  _RecordingGetStoredEmailDeliveryStateInteractor() : super(_UnusedFcmRepository());

  final calls = <(AccountId, UserName)>[];

  @override
  Stream<Either<Failure, Success>> execute(
    AccountId accountId,
    UserName userName,
  ) {
    calls.add((accountId, userName));
    return const Stream.empty();
  }
}

class _RecordingStoreEmailDeliveryStateInteractor
    extends StoreEmailDeliveryStateInteractor {
  _RecordingStoreEmailDeliveryStateInteractor() : super(_UnusedFcmRepository());

  final calls = <(AccountId, UserName, jmap.State)>[];

  @override
  Stream<Either<Failure, Success>> execute(
    AccountId accountId,
    UserName userName,
    jmap.State newState,
  ) {
    calls.add((accountId, userName, newState));
    return const Stream.empty();
  }
}

class _RecordingGetEmailChangesInteractor
    extends GetEmailChangesToPushNotificationInteractor {
  _RecordingGetEmailChangesInteractor() : super(_UnusedFcmRepository());

  final calls = <(AccountId, UserName, jmap.State)>[];

  @override
  Stream<Either<Failure, Success>> execute(
    session,
    AccountId accountId,
    UserName userName,
    jmap.State currentState, {
    propertiesCreated,
    propertiesUpdated,
  }) {
    calls.add((accountId, userName, currentState));
    return const Stream.empty();
  }
}

class _ViewRefreshes extends Fake implements MailboxDashBoardController {
  final actions = <EmailUIAction>[];

  @override
  final onStart = InternalFinalCallback<void>(callback: () {});

  @override
  void dispatchEmailUIAction(EmailUIAction newAction) {
    actions.add(newAction);
  }
}

class _RecordingGetMailboxesInteractor
    extends GetMailboxesNotPutNotificationsInteractor {
  _RecordingGetMailboxesInteractor() : super(_UnusedFcmRepository());

  final calls = <AccountId>[];

  @override
  Stream<Either<Failure, Success>> execute(session, AccountId accountId) {
    calls.add(accountId);
    return const Stream.empty();
  }
}

void main() {
  final accountA = AccountId(Id('account-a'));
  final accountB = AccountId(Id('account-b'));
  final userA = UserName('user-a@example.com');
  final userB = UserName('user-b@example.com');
  final session = SessionFixtures.aliceSession;
  final newStateA = jmap.State('new-a');
  final newStateB = jmap.State('new-b');
  final storedStateA = jmap.State('stored-a');
  final storedStateB = jmap.State('stored-b');

  PresentationEmail emailWithId(String id) => PresentationEmail(
        id: EmailId(Id(id)),
        subject: id,
      );

  late _RecordingGetStoredEmailDeliveryStateInteractor getStored;
  late _RecordingStoreEmailDeliveryStateInteractor store;
  late _RecordingGetEmailChangesInteractor getChanges;
  late _RecordingGetMailboxesInteractor getMailboxes;
  late List<(UserName, List<PresentationEmail>)> pushed;
  late EmailChangeListener listener;
  final viewRefreshes = _ViewRefreshes();

  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    PlatformInfo.isTestingForWeb = false;
    if (!Get.isRegistered<MailboxDashBoardController>()) {
      Get.put<MailboxDashBoardController>(viewRefreshes);
    }
    viewRefreshes.actions.clear();
    getStored = _RecordingGetStoredEmailDeliveryStateInteractor();
    store = _RecordingStoreEmailDeliveryStateInteractor();
    getChanges = _RecordingGetEmailChangesInteractor();
    getMailboxes = _RecordingGetMailboxesInteractor();
    pushed = [];
    listener = EmailChangeListener.forTesting(
      getStoredEmailDeliveryStateInteractor: getStored,
      storeEmailDeliveryStateInteractor: store,
      getEmailChangesToPushNotificationInteractor: getChanges,
      getMailboxesNotPutNotificationsInteractor: getMailboxes,
      presentLocalPush: ({
        required UserName userName,
        required List<PresentationEmail> emailList,
      }) async {
        pushed.add((userName, List.of(emailList)));
      },
    );
  });

  tearDown(() {
    debugDefaultTargetPlatformOverride = null;
  });

  test(
    'each account compares and stores delivery state with its own new state',
    () {
      listener.dispatchActions([
        PushNotificationAction(
          TypeName.emailDelivery,
          newStateA,
          session,
          accountA,
          userA,
        ),
        PushNotificationAction(
          TypeName.emailDelivery,
          newStateB,
          session,
          accountB,
          userB,
        ),
      ]);

      expect(getStored.calls, [(accountA, userA), (accountB, userB)]);

      listener.handleSuccessViewState(
        GetStoredEmailDeliveryStateSuccess(storedStateA, accountA, userA),
      );
      listener.handleSuccessViewState(
        GetStoredEmailDeliveryStateSuccess(storedStateB, accountB, userB),
      );

      expect(getChanges.calls, [
        (accountA, userA, storedStateA),
        (accountB, userB, storedStateB),
      ]);

      listener.handleSuccessViewState(
        GetEmailChangesToPushNotificationSuccess(accountA, userA, const []),
      );
      listener.handleSuccessViewState(
        GetEmailChangesToPushNotificationSuccess(accountB, userB, const []),
      );

      expect(store.calls, [
        (accountA, userA, newStateA),
        (accountB, userB, newStateB),
      ]);
    },
  );

  test(
    'GetMailboxesNotPutNotifications success and failure take only that account pending emails',
    () {
      final emailA = emailWithId('email-a');
      final emailB = emailWithId('email-b');

      listener.dispatchActions([
        PushNotificationAction(
          TypeName.emailDelivery,
          newStateA,
          session,
          accountA,
          userA,
        ),
        PushNotificationAction(
          TypeName.emailDelivery,
          newStateB,
          session,
          accountB,
          userB,
        ),
      ]);

      listener.handleSuccessViewState(
        GetStoredEmailDeliveryStateSuccess(storedStateA, accountA, userA),
      );
      listener.handleSuccessViewState(
        GetStoredEmailDeliveryStateSuccess(storedStateB, accountB, userB),
      );
      listener.handleSuccessViewState(
        GetEmailChangesToPushNotificationSuccess(accountA, userA, [emailA]),
      );
      listener.handleSuccessViewState(
        GetEmailChangesToPushNotificationSuccess(accountB, userB, [emailB]),
      );

      expect(getMailboxes.calls, [accountA, accountB]);

      listener.handleSuccessViewState(
        GetMailboxesNotPutNotificationsSuccess(const [], accountA, userA),
      );
      expect(pushed, hasLength(1));
      expect(pushed.single.$1, userA);
      expect(pushed.single.$2.map((email) => email.id).toList(), [emailA.id]);

      listener.handleFailureViewState(
        GetMailboxesNotPutNotificationsFailure('err', accountB, userB),
      );
      expect(pushed, hasLength(2));
      expect(pushed[1].$1, userB);
      expect(pushed[1].$2.map((email) => email.id).toList(), [emailB.id]);
    },
  );

  test(
    'foreground sync with refreshView false does not refresh the view',
    () {
      EmailChangeListener.instance.dispatchActions([
        SynchronizeEmailOnForegroundAction(
          TypeName.emailType,
          newStateA,
          accountA,
          session,
          refreshView: false,
          storeOfflineBodies: false,
          updateDeliveryAndNotifications: true,
        ),
      ]);

      expect(viewRefreshes.actions, isEmpty);
    },
  );

  test(
    'foreground sync with refreshView true refreshes the view once',
    () {
      EmailChangeListener.instance.dispatchActions([
        SynchronizeEmailOnForegroundAction(
          TypeName.emailType,
          newStateA,
          accountA,
          session,
          refreshView: true,
        ),
      ]);

      expect(
        viewRefreshes.actions,
        [RefreshChangeEmailAction(newState: newStateA)],
      );
    },
  );
}
