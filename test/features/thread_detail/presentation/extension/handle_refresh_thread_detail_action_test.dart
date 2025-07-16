import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:model/email/presentation_email.dart';
import 'package:tmail_ui_user/features/email/presentation/action/email_ui_action.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/thread/data/model/email_change_response.dart';
import 'package:tmail_ui_user/features/thread_detail/domain/state/get_thread_by_id_state.dart';
import 'package:tmail_ui_user/features/thread_detail/domain/state/get_emails_by_ids_state.dart';
import 'package:tmail_ui_user/features/thread_detail/domain/usecases/get_thread_by_id_interactor.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/extension/handle_refresh_thread_detail_action.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/thread_detail_controller.dart';

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

  setUp(() {
    threadDetailController = MockThreadDetailController();
    mailboxDashBoardController = MockMailboxDashBoardController();
    getThreadByIdInteractor = MockGetThreadByIdInteractor();
  });

  group('handle refresh thread detail action test', () {
    test(
      'Should consume GetThreadByIdSuccess when isThreadDetailEnabled is false',
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
        final capturedStates = verify(
          threadDetailController.consumeState(captureAny)
        ).captured;
        
        expect(capturedStates, hasLength(1));
        final stateStream = capturedStates.first as Stream;
        final state = await stateStream.last;
        expect(state, isA<Right>());
        expect((state as Right).value, isA<GetThreadByIdSuccess>());
      },
    );

    test(
      'Should consume both success states when isThreadDetailEnabled is true with mixed email changes',
      () async {
        // arrange
        final currentThreadId = ThreadId(Id('current-thread'));
        final createdEmailId = EmailId(Id('created-email'));
        final updatedEmailId = EmailId(Id('updated-email'));
        final destroyedEmailId = EmailId(Id('destroyed-email'));
        
        final action = RefreshThreadDetailAction(EmailChangeResponse(
          created: [Email(id: createdEmailId, threadId: currentThreadId)],
          updated: [Email(id: updatedEmailId, threadId: currentThreadId)],
          destroyed: [destroyedEmailId],
        ));

        when(threadDetailController.mailboxDashBoardController)
            .thenReturn(mailboxDashBoardController);
        when(mailboxDashBoardController.selectedEmail)
            .thenReturn(Rxn(PresentationEmail(threadId: currentThreadId)));
        when(threadDetailController.emailIdsPresentation).thenReturn(RxMap<EmailId, PresentationEmail?>.of({
          destroyedEmailId: PresentationEmail(id: destroyedEmailId),
          updatedEmailId: PresentationEmail(id: updatedEmailId),
        }));
        when(threadDetailController.isThreadDetailEnabled).thenReturn(true);
        when(threadDetailController.currentExpandedEmailId).thenReturn(Rxn());

        // act
        threadDetailController.handleRefreshThreadDetailAction(
          action,
          getThreadByIdInteractor,
        );

        // assert
        final capturedStates = verify(
          threadDetailController.consumeState(captureAny)
        ).captured;
        
        expect(capturedStates, hasLength(2));
        
        // Verify GetThreadByIdSuccess
        final firstState = await (capturedStates.first as Stream).last;
        expect(firstState, isA<Right>());
        final threadSuccess = (firstState as Right).value as GetThreadByIdSuccess;
        expect(threadSuccess.emailIds, containsAll([createdEmailId, updatedEmailId]));
        
        // Verify GetEmailsByIdsSuccess
        final secondState = await (capturedStates[1] as Stream).last;
        expect(secondState, isA<Right>());
        final emailsSuccess = (secondState as Right).value as GetEmailsByIdsSuccess;
        expect(emailsSuccess.presentationEmails, hasLength(2));
        expect(emailsSuccess.presentationEmails.map((e) => e.id), containsAll([
          createdEmailId,
          updatedEmailId,
        ]));
      },
    );
  });
}
