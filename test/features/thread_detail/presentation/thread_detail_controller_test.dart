import 'dart:async';

import 'package:core/data/network/download/download_manager.dart';
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/utils/platform_info.dart';
import 'package:dartz/dartz.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/core/account/account.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/core/state.dart' as jmap;
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:model/email/email_action_type.dart';
import 'package:model/email/presentation_email.dart';
import 'package:rxdart/rxdart.dart' hide Rx;
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:tmail_ui_user/features/delegation/domain/model/active_account.dart';
import 'package:tmail_ui_user/features/delegation/presentation/bridge/active_account_source.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/add_a_label_to_a_thread_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/get_email_content_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/labels/remove_a_label_from_a_thread_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/mark_as_email_read_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/mark_as_star_email_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/print_email_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/network_connection/presentation/network_connection_controller.dart'
    if (dart.library.html) 'package:tmail_ui_user/features/network_connection/presentation/web_network_connection_controller.dart';
import 'package:tmail_ui_user/features/thread/domain/usecases/mark_as_multiple_email_read_interactor.dart';
import 'package:tmail_ui_user/features/thread/domain/usecases/mark_as_star_multiple_email_interactor.dart';
import 'package:tmail_ui_user/features/thread_detail/domain/state/get_thread_by_id_state.dart';
import 'package:tmail_ui_user/features/thread_detail/domain/usecases/get_emails_by_ids_interactor.dart';
import 'package:tmail_ui_user/features/thread_detail/domain/usecases/get_thread_by_id_interactor.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/action/thread_detail_ui_action.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/extension/handle_mail_shortcut_actions_extension.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/model/mail_view_shortcut_action_view_event.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/thread_detail_controller.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/thread_detail_manager.dart';

import '../../../fixtures/active_account_source_fixtures.dart';
import '../../../fixtures/base_controller_fixtures.dart';
import '../../../fixtures/delegation_fixtures.dart';
import '../../../fixtures/session_fixtures.dart';
import 'thread_detail_controller_test.mocks.dart';

mockControllerCallback() => InternalFinalCallback<void>(callback: () {});
const fallbackGenerators = {
  #onStart: mockControllerCallback,
  #onDelete: mockControllerCallback,
};

@GenerateNiceMocks([
  MockSpec<GetThreadByIdInteractor>(),
  MockSpec<GetEmailsByIdsInteractor>(),
  MockSpec<MarkAsEmailReadInteractor>(),
  MockSpec<MarkAsStarEmailInteractor>(),
  MockSpec<PrintEmailInteractor>(),
  MockSpec<GetEmailContentInteractor>(),
  MockSpec<MarkAsStarMultipleEmailInteractor>(),
  MockSpec<MarkAsMultipleEmailReadInteractor>(),
  MockSpec<AddALabelToAThreadInteractor>(),
  MockSpec<RemoveALabelFromAThreadInteractor>(),
  MockSpec<MailboxDashBoardController>(fallbackGenerators: fallbackGenerators),
  MockSpec<NetworkConnectionController>(fallbackGenerators: fallbackGenerators),
  MockSpec<ThreadDetailManager>(fallbackGenerators: fallbackGenerators),
  MockSpec<DownloadManager>(),
])
void main() {
  setUp(() {
    BaseControllerFixtures.registerDependencies();
    Get.put<MailboxDashBoardController>(MockMailboxDashBoardController());
    Get.put<NetworkConnectionController>(MockNetworkConnectionController());
    Get.put<ThreadDetailManager>(MockThreadDetailManager());
    Get.put<DownloadManager>(MockDownloadManager());
    final session = DelegationFixtures.session();
    final source = ActiveAccountSourceFixtures.putShowing(
      DelegationFixtures.bobAccountId,
    );
    source.show(
      DelegationFixtures.bobAccountId,
      ActiveAccount.delegated(session, DelegationFixtures.bobAccountId),
    );
  });

  tearDown(Get.reset);

  test('reads the emails of the shown account, not of my own', () {
    final controller = ThreadDetailController(
      MockGetThreadByIdInteractor(),
      MockGetEmailsByIdsInteractor(),
      MockMarkAsEmailReadInteractor(),
      MockMarkAsStarEmailInteractor(),
      MockPrintEmailInteractor(),
      MockGetEmailContentInteractor(),
      MockMarkAsStarMultipleEmailInteractor(),
      MockMarkAsMultipleEmailReadInteractor(),
      MockAddALabelToAThreadInteractor(),
      MockRemoveALabelFromAThreadInteractor(),
    );

    expect(controller.accountId, DelegationFixtures.bobAccountId);
  });

  test('the thread of an account shown before never reaches the opened email once another one is shown', () {
    fakeAsync((async) {
      final threadId = ThreadId(Id('thread-1'));
      final getThreadByIdInteractor = MockGetThreadByIdInteractor();
      final bobThread = StreamController<Either<Failure, Success>>();
      addTearDown(bobThread.close);
      when(getThreadByIdInteractor.execute(any, any, any, any, any, isSentMailbox: anyNamed('isSentMailbox')))
          .thenAnswer((_) => bobThread.stream);
      final dashboard = Get.find<MailboxDashBoardController>() as MockMailboxDashBoardController;
      final threadDetailUIAction = Rxn<ThreadDetailUIAction>();
      when(dashboard.accountId).thenReturn(Rxn());
      when(dashboard.selectedEmail).thenReturn(Rxn(PresentationEmail(id: EmailId(Id('email-1')), threadId: threadId)));
      when(dashboard.threadDetailUIAction).thenReturn(threadDetailUIAction);
      when(dashboard.emailUIAction).thenReturn(Rxn());
      when(dashboard.sessionCurrent).thenReturn(SessionFixtures.aliceSession);
      when(dashboard.getMailboxIdByRole(PresentationMailbox.roleSent)).thenReturn(MailboxId(Id('sent-id')));
      when(dashboard.ownEmailAddress).thenReturn(RxString(DelegationFixtures.bobAddress));
      when(dashboard.ownerEmailAddresses)
          .thenReturn({DelegationFixtures.bobAddress});
      when(Get.find<NetworkConnectionController>().isNetworkConnectionAvailable()).thenReturn(true);
      when(Get.find<ThreadDetailManager>().isThreadDetailEnabled).thenReturn(true);
      final source = Get.find<ActiveAccountSource>() as FakeActiveAccountSource;
      final session = DelegationFixtures.session();
      final controller = ThreadDetailController(
        getThreadByIdInteractor,
        MockGetEmailsByIdsInteractor(),
        MockMarkAsEmailReadInteractor(),
        MockMarkAsStarEmailInteractor(),
        MockPrintEmailInteractor(),
        MockGetEmailContentInteractor(),
        MockMarkAsStarMultipleEmailInteractor(),
        MockMarkAsMultipleEmailReadInteractor(),
        MockAddALabelToAThreadInteractor(),
        MockRemoveALabelFromAThreadInteractor(),
      )..onInit();
      threadDetailUIAction.value = LoadThreadDetailAfterSelectedEmailAction(threadId, isSentMailbox: false);
      async.elapse(const Duration(seconds: 1));
      verify(getThreadByIdInteractor.execute(any, any, any, any, any, isSentMailbox: false)).called(1);

      source.show(
        DelegationFixtures.carolAccountId,
        ActiveAccount.delegated(session, DelegationFixtures.carolAccountId),
      );
      bobThread.add(Right(GetThreadByIdSuccess([EmailId(Id('email-1'))], threadId: threadId)));
      async.flushMicrotasks();

      expect(controller.emailIdsPresentation, isEmpty);
    });
  });

  test('loads the thread of my own account WHEN the session username is not an email', () {
    fakeAsync((async) {
      final usernameOnlySession = Session(
        {},
        {DelegationFixtures.aliceAccountId: Account(AccountName('alice'), true, false, {})},
        {},
        UserName('alice'),
        Uri.parse('http://domain.com/jmap'),
        Uri.parse('http://domain.com/download/{accountId}/{blobId}/?type={type}&name={name}'),
        Uri.parse('http://domain.com/upload/{accountId}'),
        Uri.parse('http://domain.com/eventSource?types={types}&closeAfter={closeafter}&ping={ping}'),
        jmap.State('state-1'),
      );
      (Get.find<ActiveAccountSource>() as FakeActiveAccountSource).show(
        DelegationFixtures.aliceAccountId,
        ActiveAccount.personal(usernameOnlySession),
      );
      final threadId = ThreadId(Id('thread-1'));
      final getThreadByIdInteractor = MockGetThreadByIdInteractor();
      when(getThreadByIdInteractor.execute(any, any, any, any, any, isSentMailbox: anyNamed('isSentMailbox')))
          .thenAnswer((_) => const Stream.empty());
      final dashboard = Get.find<MailboxDashBoardController>() as MockMailboxDashBoardController;
      final threadDetailUIAction = Rxn<ThreadDetailUIAction>();
      when(dashboard.accountId).thenReturn(Rxn(DelegationFixtures.aliceAccountId));
      when(dashboard.selectedEmail).thenReturn(Rxn(PresentationEmail(id: EmailId(Id('email-1')), threadId: threadId)));
      when(dashboard.threadDetailUIAction).thenReturn(threadDetailUIAction);
      when(dashboard.emailUIAction).thenReturn(Rxn());
      when(dashboard.sessionCurrent).thenReturn(usernameOnlySession);
      when(dashboard.getMailboxIdByRole(PresentationMailbox.roleSent)).thenReturn(MailboxId(Id('sent-id')));
      // The address the dashboard derived from identities for this username-only account.
      when(dashboard.ownEmailAddress).thenReturn(RxString('alice@domain.tld'));
      when(dashboard.ownerEmailAddress).thenReturn('alice@domain.tld');
      when(dashboard.ownerEmailAddresses).thenReturn({'alice@domain.tld'});
      when(Get.find<NetworkConnectionController>().isNetworkConnectionAvailable()).thenReturn(true);
      when(Get.find<ThreadDetailManager>().isThreadDetailEnabled).thenReturn(true);
      ThreadDetailController(
        getThreadByIdInteractor,
        MockGetEmailsByIdsInteractor(),
        MockMarkAsEmailReadInteractor(),
        MockMarkAsStarEmailInteractor(),
        MockPrintEmailInteractor(),
        MockGetEmailContentInteractor(),
        MockMarkAsStarMultipleEmailInteractor(),
        MockMarkAsMultipleEmailReadInteractor(),
        MockAddALabelToAThreadInteractor(),
        MockRemoveALabelFromAThreadInteractor(),
      ).onInit();
      threadDetailUIAction.value = LoadThreadDetailAfterSelectedEmailAction(threadId, isSentMailbox: false);
      async.elapse(const Duration(seconds: 1));

      verify(getThreadByIdInteractor.execute(any, any, any, any, any, isSentMailbox: false)).called(1);
    });
  });

  group('opened-email shortcuts during a switch:', () {
    test('a focus move away from the opened email still lets a pending shortcut fire', () {
      fakeAsync((async) {
        PlatformInfo.isTestingForWeb = true;
        addTearDown(() => PlatformInfo.isTestingForWeb = false);

        final controller = ThreadDetailController(
          MockGetThreadByIdInteractor(),
          MockGetEmailsByIdsInteractor(),
          MockMarkAsEmailReadInteractor(),
          MockMarkAsStarEmailInteractor(),
          MockPrintEmailInteractor(),
          MockGetEmailContentInteractor(),
          MockMarkAsStarMultipleEmailInteractor(),
          MockMarkAsMultipleEmailReadInteractor(),
          MockAddALabelToAThreadInteractor(),
          MockRemoveALabelFromAThreadInteractor(),
        );
        final fired = <MailViewShortcutActionViewEvent>[];
        controller.shortcutActionEventController =
            StreamController<MailViewShortcutActionViewEvent>.broadcast();
        controller.shortcutActionEventSubscription = controller
            .shortcutActionEventController!
            .stream
            .debounceTime(const Duration(milliseconds: 300))
            .listen(fired.add);

        controller.shortcutActionEventController!.add(
          MailViewShortcutActionViewEvent(
            EmailActionType.markAsRead,
            PresentationEmail(id: EmailId(Id('email-1'))),
          ),
        );
        controller.clearMailShortcutFocus();
        async.elapse(const Duration(milliseconds: 300));

        expect(fired, hasLength(1));
      });
    });

    test('DropPendingMailViewShortcutsAction drops a pending shortcut and keeps later ones', () {
      fakeAsync((async) {
        PlatformInfo.isTestingForWeb = true;
        addTearDown(() => PlatformInfo.isTestingForWeb = false);

        final threadDetailUIAction = Rxn<ThreadDetailUIAction>();
        final dashboard = Get.find<MailboxDashBoardController>() as MockMailboxDashBoardController;
        when(dashboard.accountId).thenReturn(Rxn());
        when(dashboard.selectedEmail).thenReturn(Rxn());
        when(dashboard.threadDetailUIAction).thenReturn(threadDetailUIAction);
        when(dashboard.emailUIAction).thenReturn(Rxn());
        when(dashboard.sessionCurrent).thenReturn(SessionFixtures.aliceSession);
        when(dashboard.ownEmailAddress).thenReturn(RxString(DelegationFixtures.bobAddress));

        final controller = ThreadDetailController(
          MockGetThreadByIdInteractor(),
          MockGetEmailsByIdsInteractor(),
          MockMarkAsEmailReadInteractor(),
          MockMarkAsStarEmailInteractor(),
          MockPrintEmailInteractor(),
          MockGetEmailContentInteractor(),
          MockMarkAsStarMultipleEmailInteractor(),
          MockMarkAsMultipleEmailReadInteractor(),
          MockAddALabelToAThreadInteractor(),
          MockRemoveALabelFromAThreadInteractor(),
        )..onInit();
        controller.onKeyboardShortcutInit();

        final fired = <MailViewShortcutActionViewEvent>[];
        controller.shortcutActionEventSubscription?.cancel();
        controller.shortcutActionEventSubscription = controller
            .shortcutActionEventController!
            .stream
            .debounceTime(const Duration(milliseconds: 300))
            .listen(fired.add);

        controller.shortcutActionEventController!.add(
          MailViewShortcutActionViewEvent(
            EmailActionType.markAsRead,
            PresentationEmail(id: EmailId(Id('email-1'))),
          ),
        );
        threadDetailUIAction.value = DropPendingMailViewShortcutsAction();
        async.elapse(Duration.zero);
        async.elapse(const Duration(milliseconds: 300));
        expect(fired, isEmpty);

        // Production re-listened on a fresh broadcast stream after the drop.
        final later = <MailViewShortcutActionViewEvent>[];
        final laterSub = controller.shortcutActionEventController!.stream
            .debounceTime(const Duration(milliseconds: 300))
            .listen(later.add);
        controller.shortcutActionEventController!.add(
          MailViewShortcutActionViewEvent(
            EmailActionType.markAsRead,
            PresentationEmail(id: EmailId(Id('email-2'))),
          ),
        );
        async.elapse(const Duration(milliseconds: 300));
        laterSub.cancel();
        expect(later, hasLength(1));
      });
    });
  });
}
