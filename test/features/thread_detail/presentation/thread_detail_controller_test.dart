import 'dart:async';

import 'package:core/data/network/download/download_manager.dart';
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:model/email/presentation_email.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
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
    ActiveAccountSourceFixtures.putShowing(DelegationFixtures.bobAccountId);
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
      when(Get.find<NetworkConnectionController>().isNetworkConnectionAvailable()).thenReturn(true);
      when(Get.find<ThreadDetailManager>().isThreadDetailEnabled).thenReturn(true);
      final source = Get.find<ActiveAccountSource>() as FakeActiveAccountSource;
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

      source.show(DelegationFixtures.carolAccountId);
      bobThread.add(Right(GetThreadByIdSuccess([EmailId(Id('email-1'))], threadId: threadId)));
      async.flushMicrotasks();

      expect(controller.emailIdsPresentation, isEmpty);
    });
  });
}
