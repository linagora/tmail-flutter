import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:model/email/email_in_thread_status.dart';
import 'package:model/email/presentation_email.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/thread_detail/domain/state/get_thread_by_id_state.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/extension/handle_get_email_ids_by_thread_id_success.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/thread_detail_controller.dart';

import 'handle_get_email_ids_by_thread_id_success_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<ThreadDetailController>(),
  MockSpec<MailboxDashBoardController>(),
])
void main() {
  final threadDetailController = MockThreadDetailController();
  final mailboxDashBoardController = MockMailboxDashBoardController();
  group('handle get email ids by thread id success test:', () {
    test(
      'should not change emailIdsPresentation '
      'when GetThreadByIdSuccess.success.emailIds is empty',
    () {
      // arrange
      final initialEmailIdsPresentation = {
        EmailId(Id('1')): PresentationEmail(),
      };
      when(threadDetailController.emailIdsPresentation)
        .thenReturn(initialEmailIdsPresentation.obs);
      when(threadDetailController.mailboxDashBoardController)
        .thenReturn(mailboxDashBoardController);
      when(mailboxDashBoardController.selectedEmail)
        .thenReturn(Rxn(PresentationEmail(id: EmailId(Id('1')))));
      
      // act
      threadDetailController.handleGetEmailIdsByThreadIdSuccess(
        GetThreadByIdSuccess([], threadId: null),
      );
      
      // assert
      expect(
        threadDetailController.emailIdsPresentation,
        initialEmailIdsPresentation,
      );
    });

    test(
      'should remove email id from emailIdsPresentation '
      'which is not in GetThreadByIdSuccess.success.emailIds '
      'and add new email ids from GetThreadByIdSuccess.success.emailIds '
      'when GetThreadByIdSuccess.success.emailIds is not empty '
      'and updateCurrentThreadDetail is true',
    () {
      // arrange
      final initialEmailIdsPresentation = {
        EmailId(Id('1')): PresentationEmail(),
        EmailId(Id('2')): null,
      };
      when(threadDetailController.emailIdsPresentation)
        .thenReturn(initialEmailIdsPresentation.obs);
      when(threadDetailController.mailboxDashBoardController)
        .thenReturn(mailboxDashBoardController);
      when(mailboxDashBoardController.selectedEmail)
        .thenReturn(Rxn(PresentationEmail(id: EmailId(Id('1')))));
      
      // act
      threadDetailController.handleGetEmailIdsByThreadIdSuccess(
        GetThreadByIdSuccess(
          [
            EmailId(Id('1')),
            EmailId(Id('3')),
            EmailId(Id('4')),
          ],
          threadId: null,
          updateCurrentThreadDetail: true,
        ),
      );
      
      // assert
      expect(
        threadDetailController.emailIdsPresentation,
        {
          EmailId(Id('1')): PresentationEmail(),
          EmailId(Id('3')): null,
          EmailId(Id('4')): null,
        },
      );
    });

    test(
      'should add all email ids from GetThreadByIdSuccess.success.emailIds '
      'except selected email id '
      'and keep selected email id in emailIdsPresentation '
      'when GetThreadByIdSuccess.success.emailIds is not empty '
      'and updateCurrentThreadDetail is false '
      'and selected email is available in emailIdsPresentation',
    () {
      // arrange
      final existedSelectedEmailId = PresentationEmail(
        id: EmailId(Id('1')),
        emailInThreadStatus: EmailInThreadStatus.expanded,
      );
      final initialEmailIdsPresentation = <EmailId, PresentationEmail?>{
        EmailId(Id('1')): existedSelectedEmailId,
      };
      when(threadDetailController.emailIdsPresentation)
        .thenReturn(initialEmailIdsPresentation.obs);
      when(threadDetailController.mailboxDashBoardController)
        .thenReturn(mailboxDashBoardController);
      when(mailboxDashBoardController.selectedEmail)
        .thenReturn(Rxn(PresentationEmail(id: EmailId(Id('1')))));
      
      // act
      threadDetailController.handleGetEmailIdsByThreadIdSuccess(
        GetThreadByIdSuccess(
          [
            EmailId(Id('1')),
            EmailId(Id('3')),
            EmailId(Id('4')),
          ],
          threadId: null,
          updateCurrentThreadDetail: false,
        ),
      );
      
      // assert
      expect(
        threadDetailController.emailIdsPresentation,
        {
          EmailId(Id('1')): existedSelectedEmailId,
          EmailId(Id('3')): null,
          EmailId(Id('4')): null,
        },
      );
    });

    test(
      'should add all email ids from GetThreadByIdSuccess.success.emailIds '
      'except selected email id '
      'and take selected email from mailbox dashboard controller '
      'when GetThreadByIdSuccess.success.emailIds is not empty '
      'and updateCurrentThreadDetail is false '
      'and selected email is not available in emailIdsPresentation',
    () {
      // arrange
      final selectedEmailId = PresentationEmail(id: EmailId(Id('1')));
      final initialEmailIdsPresentation = <EmailId, PresentationEmail?>{
        EmailId(Id('1')): null,
      };
      when(threadDetailController.emailIdsPresentation)
        .thenReturn(initialEmailIdsPresentation.obs);
      when(threadDetailController.mailboxDashBoardController)
        .thenReturn(mailboxDashBoardController);
      when(mailboxDashBoardController.selectedEmail)
        .thenReturn(Rxn(PresentationEmail(id: EmailId(Id('1')))));
      
      // act
      threadDetailController.handleGetEmailIdsByThreadIdSuccess(
        GetThreadByIdSuccess(
          [
            EmailId(Id('1')),
            EmailId(Id('3')),
            EmailId(Id('4')),
          ],
          threadId: null,
          updateCurrentThreadDetail: false,
        ),
      );
      
      // assert
      expect(
        threadDetailController.emailIdsPresentation,
        {
          EmailId(Id('1')): selectedEmailId,
          EmailId(Id('3')): null,
          EmailId(Id('4')): null,
        },
      );
    });
  });
}