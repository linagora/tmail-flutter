import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:model/email/presentation_email.dart';
import 'package:model/extensions/session_extension.dart';
import 'package:tmail_ui_user/features/email/presentation/action/email_ui_action.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/thread/data/model/email_change_response.dart';
import 'package:tmail_ui_user/features/thread_detail/domain/state/get_thread_by_id_state.dart';
import 'package:tmail_ui_user/features/thread_detail/domain/usecases/get_thread_by_id_interactor.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/extension/handle_refresh_thread_detail_action.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/thread_detail_controller.dart';

import '../../../../fixtures/account_fixtures.dart';
import '../../../../fixtures/session_fixtures.dart';
import 'handle_refresh_thread_detail_action_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<ThreadDetailController>(),
  MockSpec<MailboxDashBoardController>(),
  MockSpec<GetThreadByIdInteractor>(),
])
void main() {
  late MockThreadDetailController threadDetailController;
  late MockMailboxDashBoardController mailboxDashBoardController;
  late MockGetThreadByIdInteractor getThreadByIdInteractor;

  final sentMailboxId = MailboxId(Id('sent'));
  final ownEmailAddress = SessionFixtures.aliceSession.getOwnEmailAddress();

  setUp(() {
    threadDetailController = MockThreadDetailController();
    mailboxDashBoardController = MockMailboxDashBoardController();
    getThreadByIdInteractor = MockGetThreadByIdInteractor();
  });

  group('handle refresh thread detail action test', () {
    test(
      'should call getThreadByIdInteractor.execute '
      'when refreshThreadDetailAction is called '
      'and list email created contains currentThreadId '
      'and isThreadDetailEnabled is true',
    () {
      // arrange
      final emailId = EmailId(Id('1'));
      final threadId = ThreadId(Id('some-id'));
      final action = RefreshThreadDetailAction(EmailChangeResponse(
        created: [Email(id: emailId, threadId: threadId)],
      ));
      when(threadDetailController.mailboxDashBoardController)
          .thenReturn(mailboxDashBoardController);
      when(mailboxDashBoardController.selectedEmail)
          .thenReturn(Rxn(PresentationEmail(id: emailId, threadId: threadId)));
      when(threadDetailController.session)
          .thenReturn(SessionFixtures.aliceSession);
      when(threadDetailController.accountId)
          .thenReturn(AccountFixtures.aliceAccountId);
      when(threadDetailController.sentMailboxId).thenReturn(sentMailboxId);
      when(threadDetailController.ownEmailAddress).thenReturn(ownEmailAddress);
      when(threadDetailController.isThreadDetailEnabled).thenReturn(true);
      
      // act
      threadDetailController.handleRefreshThreadDetailAction(
        action,
        getThreadByIdInteractor,
      );
      
      // assert
      verify(getThreadByIdInteractor.execute(
        threadId,
        SessionFixtures.aliceSession,
        AccountFixtures.aliceAccountId,
        sentMailboxId,
        ownEmailAddress,
        updateCurrentThreadDetail: true,
      )).called(1);
    });

    test(
      'should call getThreadByIdInteractor.execute '
      'when refreshThreadDetailAction is called '
      'and list email updated contains currentThreadId '
      'and isThreadDetailEnabled is true',
    () {
      // arrange
      final emailId = EmailId(Id('1'));
      final threadId = ThreadId(Id('some-id'));
      final action = RefreshThreadDetailAction(EmailChangeResponse(
        updated: [Email(id: emailId, threadId: threadId)],
      ));
      when(threadDetailController.mailboxDashBoardController)
          .thenReturn(mailboxDashBoardController);
      when(mailboxDashBoardController.selectedEmail)
          .thenReturn(Rxn(PresentationEmail(id: emailId, threadId: threadId)));
      when(threadDetailController.session)
          .thenReturn(SessionFixtures.aliceSession);
      when(threadDetailController.accountId)
          .thenReturn(AccountFixtures.aliceAccountId);
      when(threadDetailController.sentMailboxId).thenReturn(sentMailboxId);
      when(threadDetailController.ownEmailAddress).thenReturn(ownEmailAddress);
      when(threadDetailController.isThreadDetailEnabled).thenReturn(true);
      
      // act
      threadDetailController.handleRefreshThreadDetailAction(
        action,
        getThreadByIdInteractor,
      );
      
      // assert
      verify(getThreadByIdInteractor.execute(
        threadId,
        SessionFixtures.aliceSession,
        AccountFixtures.aliceAccountId,
        sentMailboxId,
        ownEmailAddress,
        updateCurrentThreadDetail: true,
      )).called(1);
    });

    test(
      'should call getThreadByIdInteractor.execute '
      'when refreshThreadDetailAction is called '
      'and list email destroyed contains any of emailId in current thread '
      'and isThreadDetailEnabled is true',
    () {
      // arrange
      final emailId = EmailId(Id('1'));
      final threadId = ThreadId(Id('some-id'));
      final action = RefreshThreadDetailAction(EmailChangeResponse(
        destroyed: [emailId],
      ));
      when(threadDetailController.mailboxDashBoardController)
          .thenReturn(mailboxDashBoardController);
      when(mailboxDashBoardController.selectedEmail)
          .thenReturn(Rxn(PresentationEmail(id: emailId, threadId: threadId)));
      when(threadDetailController.session)
          .thenReturn(SessionFixtures.aliceSession);
      when(threadDetailController.accountId)
          .thenReturn(AccountFixtures.aliceAccountId);
      when(threadDetailController.sentMailboxId).thenReturn(sentMailboxId);
      when(threadDetailController.ownEmailAddress).thenReturn(ownEmailAddress);
      when(threadDetailController.emailIdsPresentation).thenReturn({
        emailId: null
      }.obs);
      when(threadDetailController.isThreadDetailEnabled).thenReturn(true);
      
      // act
      threadDetailController.handleRefreshThreadDetailAction(
        action,
        getThreadByIdInteractor,
      );
      
      // assert
      verify(getThreadByIdInteractor.execute(
        threadId,
        SessionFixtures.aliceSession,
        AccountFixtures.aliceAccountId,
        sentMailboxId,
        ownEmailAddress,
        updateCurrentThreadDetail: true,
      )).called(1);
    });

    test(
      'should consume GetThreadByIdSuccess with selected email id '
      'when refreshThreadDetailAction is called '
      'and isThreadDetailEnabled is false '
      'and selected email id not null '
      'and list email updated contains selected email id',
    () async {
      // arrange
      final emailId = EmailId(Id('1'));
      final action = RefreshThreadDetailAction(EmailChangeResponse(
        updated: [Email(id: emailId)],
      ));
      when(threadDetailController.mailboxDashBoardController)
          .thenReturn(mailboxDashBoardController);
      when(mailboxDashBoardController.selectedEmail)
          .thenReturn(Rxn(PresentationEmail(id: emailId)));
      when(threadDetailController.isThreadDetailEnabled).thenReturn(false);
      
      // act
      threadDetailController.handleRefreshThreadDetailAction(
        action,
        getThreadByIdInteractor,
      );
      
      // assert
      verifyNever(getThreadByIdInteractor.execute(
        any,
        any,
        any,
        any,
        any,
        updateCurrentThreadDetail: anyNamed('updateCurrentThreadDetail'),
      ));
      final args = verify(
        threadDetailController.consumeState(captureAny),
      ).captured.first as Stream;
      final state = await args.last;
      expect(
        state,
        Right(GetThreadByIdSuccess(
          [emailId],
          updateCurrentThreadDetail: true,
        )),
      );
    });

    test(
      'should not call getThreadByIdInteractor.execute '
      'and not consume GetThreadByIdSuccess with selected email id'
      'when refreshThreadDetailAction is called '
      'and list email created does not contain currentThreadId '
      'and list email updated does not contain currentThreadId '
      'and list email destroyed does not contain any of emailId in current thread '
      'and isThreadDetailEnabled is true',
    () async {
      // arrange
      final emailId = EmailId(Id('1'));
      final action = RefreshThreadDetailAction(EmailChangeResponse(
        created: [
          Email(id: EmailId(Id('2')), threadId: ThreadId(Id('some-id-2'))),
        ],
        updated: [
          Email(id: EmailId(Id('3')), threadId: ThreadId(Id('some-id-3'))),
        ],
        destroyed: [
          EmailId(Id('4')),
        ],
      ));
      when(threadDetailController.mailboxDashBoardController)
          .thenReturn(mailboxDashBoardController);
      when(mailboxDashBoardController.selectedEmail)
          .thenReturn(Rxn(PresentationEmail()));
      when(threadDetailController.session)
          .thenReturn(SessionFixtures.aliceSession);
      when(threadDetailController.accountId)
          .thenReturn(AccountFixtures.aliceAccountId);
      when(threadDetailController.sentMailboxId).thenReturn(sentMailboxId);
      when(threadDetailController.ownEmailAddress).thenReturn(ownEmailAddress);
      when(threadDetailController.emailIdsPresentation).thenReturn({
        emailId: null,
      }.obs);
      when(threadDetailController.viewState).thenReturn(Rx(Right(UIState.idle)));
      when(threadDetailController.isThreadDetailEnabled).thenReturn(true);
      
      // act
      threadDetailController.handleRefreshThreadDetailAction(
        action,
        getThreadByIdInteractor,
      );
      
      // assert
      verifyNever(getThreadByIdInteractor.execute(
        any,
        any,
        any,
        any,
        any,
        updateCurrentThreadDetail: anyNamed('updateCurrentThreadDetail'),
      ));
      verifyNever(threadDetailController.consumeState(any));
    });

    test(
      'should not call getThreadByIdInteractor.execute '
      'and not consume GetThreadByIdSuccess with selected email id'
      'when refreshThreadDetailAction is called '
      'and isThreadDetailEnabled is false '
      'and updated email ids does not contain selected email id',
    () async {
      // arrange
      final emailId = EmailId(Id('1'));
      final action = RefreshThreadDetailAction(EmailChangeResponse(
        updated: [
          Email(id: EmailId(Id('3')), threadId: ThreadId(Id('some-id-3'))),
        ],
      ));
      when(threadDetailController.mailboxDashBoardController)
          .thenReturn(mailboxDashBoardController);
      when(mailboxDashBoardController.selectedEmail)
          .thenReturn(Rxn(PresentationEmail(id: emailId)));
      when(threadDetailController.isThreadDetailEnabled).thenReturn(false);
      
      // act
      threadDetailController.handleRefreshThreadDetailAction(
        action,
        getThreadByIdInteractor,
      );
      
      // assert
      verifyNever(getThreadByIdInteractor.execute(
        any,
        any,
        any,
        any,
        any,
        updateCurrentThreadDetail: anyNamed('updateCurrentThreadDetail'),
      ));
      verifyNever(threadDetailController.consumeState(any));
    });
  });
}