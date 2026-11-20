import 'dart:async';

import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/utils/platform_info.dart';
import 'package:dartz/dartz.dart';
import 'package:fcm/model/type_name.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/core/state.dart' as jmap;
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:model/email/presentation_email.dart';
import 'package:tmail_ui_user/features/email/domain/repository/email_repository.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/get_stored_email_state_interactor.dart';
import 'package:tmail_ui_user/features/email/presentation/action/email_ui_action.dart';
import 'package:tmail_ui_user/features/push_notification/domain/exceptions/fcm_exception.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/push_notification/domain/repository/fcm_repository.dart';
import 'package:tmail_ui_user/features/push_notification/domain/state/get_email_changes_to_push_notification_state.dart';
import 'package:tmail_ui_user/features/push_notification/domain/state/get_email_changes_to_remove_notification_state.dart';
import 'package:tmail_ui_user/features/push_notification/domain/state/get_mailboxes_not_put_notifications_state.dart';
import 'package:tmail_ui_user/features/push_notification/domain/state/get_stored_email_delivery_state.dart';
import 'package:tmail_ui_user/features/push_notification/domain/usecases/get_email_changes_to_push_notification_interactor.dart';
import 'package:tmail_ui_user/features/push_notification/domain/usecases/get_mailboxes_not_put_notifications_interactor.dart';
import 'package:tmail_ui_user/features/push_notification/domain/usecases/get_stored_email_delivery_state_interactor.dart';
import 'package:tmail_ui_user/features/push_notification/domain/usecases/store_email_delivery_state_interactor.dart';
import 'package:tmail_ui_user/features/push_notification/presentation/action/push_notification_state_change_action.dart';
import 'package:tmail_ui_user/features/push_notification/presentation/listener/email_change_listener.dart';
import 'package:tmail_ui_user/features/push_notification/presentation/model/notification_owner.dart';

import '../../../../fixtures/delegation_fixtures.dart';
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

  final calls = <(Session, AccountId, UserName, jmap.State, jmap.State?)>[];

  @override
  Stream<Either<Failure, Success>> execute(
    Session session,
    AccountId accountId,
    UserName userName,
    jmap.State currentState, {
    propertiesCreated,
    propertiesUpdated,
    jmap.State? deliveryState,
  }) {
    calls.add((session, accountId, userName, currentState, deliveryState));
    return const Stream.empty();
  }
}

class _UnusedEmailRepository implements EmailRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _RecordingGetStoredEmailStateInteractor extends GetStoredEmailStateInteractor {
  _RecordingGetStoredEmailStateInteractor() : super(_UnusedEmailRepository());

  final calls = <AccountId>[];

  @override
  Stream<Either<Failure, Success>> execute(Session session, AccountId accountId) {
    calls.add(accountId);
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
  Stream<Either<Failure, Success>> execute(Session session, AccountId accountId) {
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
  final sessionB = SessionFixtures.aliceSessionWithAICapability;
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
  late List<NotificationOwner?> owners;
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
    owners = [];
    listener = EmailChangeListener.forTesting(
      getStoredEmailDeliveryStateInteractor: getStored,
      storeEmailDeliveryStateInteractor: store,
      getEmailChangesToPushNotificationInteractor: getChanges,
      getMailboxesNotPutNotificationsInteractor: getMailboxes,
      dashBoardController: viewRefreshes,
      presentLocalPush: ({
        required UserName userName,
        required List<PresentationEmail> emailList,
        NotificationOwner? owner,
      }) async {
        pushed.add((userName, List.of(emailList)));
        owners.add(owner);
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
          sessionB,
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
        (session, accountA, userA, storedStateA, newStateA),
        (sessionB, accountB, userB, storedStateB, newStateB),
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
    'a second pending email list is kept until the mailbox lookup consumes both',
    () {
      final first = emailWithId('email-1');
      final second = emailWithId('email-2');

      listener.dispatchActions([
        PushNotificationAction(
          TypeName.emailDelivery,
          newStateA,
          session,
          accountA,
          userA,
        ),
      ]);
      listener.handleSuccessViewState(
        GetStoredEmailDeliveryStateSuccess(storedStateA, accountA, userA),
      );
      listener.handleSuccessViewState(
        GetEmailChangesToPushNotificationSuccess(
          accountA,
          userA,
          [first],
          deliveryState: newStateA,
        ),
      );
      listener.handleSuccessViewState(
        GetEmailChangesToPushNotificationSuccess(
          accountA,
          userA,
          [second],
          deliveryState: newStateA,
        ),
      );

      listener.handleSuccessViewState(
        GetMailboxesNotPutNotificationsSuccess(const [], accountA, userA),
      );

      expect(pushed, hasLength(1));
      expect(
        pushed.single.$2.map((email) => email.id).toList(),
        [first.id, second.id],
      );
    },
  );

  test(
    'an older query does not store a delivery state a newer push already replaced',
    () {
      final newerState = jmap.State('new-a2');

      listener.dispatchActions([
        PushNotificationAction(
          TypeName.emailDelivery,
          newStateA,
          session,
          accountA,
          userA,
        ),
      ]);
      listener.handleSuccessViewState(
        GetStoredEmailDeliveryStateSuccess(storedStateA, accountA, userA),
      );
      listener.dispatchActions([
        PushNotificationAction(
          TypeName.emailDelivery,
          newerState,
          session,
          accountA,
          userA,
        ),
      ]);

      listener.handleSuccessViewState(
        GetEmailChangesToPushNotificationSuccess(
          accountA,
          userA,
          const [],
          deliveryState: newStateA,
        ),
      );
      expect(store.calls, isEmpty);

      listener.handleSuccessViewState(
        GetEmailChangesToPushNotificationSuccess(
          accountA,
          userA,
          const [],
          deliveryState: newerState,
        ),
      );
      expect(store.calls, [(accountA, userA, newerState)]);
    },
  );

  test(
    'foreground sync with refreshView false does not refresh the view',
    () {
      listener.dispatchActions([
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
      listener.dispatchActions([
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

  test(
    'foreground sync for a delegated account with delivery updates off stores no delivery state and refreshes the view once',
    () {
      listener.dispatchActions([
        SynchronizeEmailOnForegroundAction(
          TypeName.emailType,
          newStateA,
          accountA,
          session,
          refreshView: true,
          storeOfflineBodies: false,
          updateDeliveryAndNotifications: false,
        ),
      ]);

      expect(store.calls, isEmpty);
      expect(getChanges.calls, isEmpty);
      expect(
        viewRefreshes.actions,
        [RefreshChangeEmailAction(newState: newStateA)],
      );
    },
  );

  group('notification owner', () {
    final delegatedSession = DelegationFixtures.session();
    final bob = DelegationFixtures.bobAccountId;
    final alice = DelegationFixtures.aliceAccountId;

    void pushOne(AccountId accountId) {
      listener.dispatchActions([
        PushNotificationAction(TypeName.emailDelivery, newStateA, delegatedSession, accountId, userA),
      ]);
      listener.handleSuccessViewState(
        GetStoredEmailDeliveryStateSuccess(storedStateA, accountId, userA),
      );
      listener.handleSuccessViewState(
        GetEmailChangesToPushNotificationSuccess(accountId, userA, [emailWithId('e-1')]),
      );
      listener.handleSuccessViewState(
        GetMailboxesNotPutNotificationsSuccess(const [], accountId, userA),
      );
    }

    test('names the owner of a delegated account the session lists', () {
      pushOne(bob);

      expect(owners, [
        NotificationOwner(accountId: bob, name: DelegationFixtures.bobAddress),
      ]);
    });

    test('SHOULD NOT name an owner for my own account', () {
      pushOne(alice);

      expect(owners, [null]);
    });

    test('SHOULD NOT name an owner for an account the session does not list', () {
      pushOne(DelegationFixtures.unknownAccountId);

      expect(owners, [null]);
    });

    group('when an email is read', () {
      const channel = MethodChannel('dexterous.com/flutter/local_notifications');
      late List<MethodCall> cancels;

      setUp(() {
        cancels = [];
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, (call) async {
          if (call.method == 'cancel') cancels.add(call);
          return null;
        });
      });

      tearDown(() {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, null);
      });

      Future<void> readEmailOf(AccountId accountId) async {
        listener.dispatchActions([
          StoreEmailStateToRefreshAction(TypeName.emailType, newStateA, accountId, userA, delegatedSession),
        ]);
        listener.handleSuccessViewState(
          GetEmailChangesToRemoveNotificationSuccess(userA, [EmailId(Id('e-1'))], accountId),
        );
        await pumpEventQueue();
      }

      test('cancels the notification of a delegated account with its id and tag although no push stored the session', () async {
        await readEmailOf(bob);

        expect(cancels.first.arguments, {'id': '${bob.id.value}/e-1'.hashCode, 'tag': bob.id.value});
      });

      test('SHOULD NOT tag the cancel of my own notification', () async {
        await readEmailOf(alice);

        expect(cancels.first.arguments, {'id': 'e-1'.hashCode, 'tag': null});
      });
    });
  });

  group('without a stored delivery state', () {
    final delegatedSession = DelegationFixtures.session();
    final bob = DelegationFixtures.bobAccountId;
    final alice = DelegationFixtures.aliceAccountId;
    late _RecordingGetStoredEmailStateInteractor getStoredEmailState;

    setUp(() {
      getStoredEmailState = _RecordingGetStoredEmailStateInteractor();
      listener = EmailChangeListener.forTesting(
        getStoredEmailDeliveryStateInteractor: getStored,
        storeEmailDeliveryStateInteractor: store,
        getEmailChangesToPushNotificationInteractor: getChanges,
        getMailboxesNotPutNotificationsInteractor: getMailboxes,
        getStoredEmailStateInteractor: getStoredEmailState,
        presentLocalPush: ({
          required UserName userName,
          required List<PresentationEmail> emailList,
          NotificationOwner? owner,
        }) async => pushed.add((userName, List.of(emailList))),
      );
    });

    void pushWithoutDeliveryState(AccountId accountId) {
      listener.dispatchActions([
        PushNotificationAction(TypeName.emailDelivery, newStateA, delegatedSession, accountId, userA),
      ]);
      listener.handleFailureViewState(GetStoredEmailDeliveryStateFailure(
        const NotFoundEmailDeliveryStateException(),
        accountId: accountId,
        userName: userA,
      ));
    }

    test('a delegated account stores the pushed state as its cursor and notifies nothing', () {
      pushWithoutDeliveryState(bob);

      expect(store.calls, [(bob, userA, newStateA)]);
      expect(getStoredEmailState.calls, isEmpty);
      expect(getChanges.calls, isEmpty);
      expect(pushed, isEmpty);
    });

    test('my own account diffs from its stored email state', () {
      pushWithoutDeliveryState(alice);

      expect(getStoredEmailState.calls, [alice]);
      expect(store.calls, isEmpty);
    });
  });
}
