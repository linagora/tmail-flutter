import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
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
  group('handle get email ids by thread id success test:', () {
    test(
      'should assign emailIds with result from success '
      'when result from success is not empty',
    () {
      // arrange
      final success = GetThreadByIdSuccess([
        EmailId(Id('1')),
        EmailId(Id('2')),
      ]);
      when(threadDetailController.emailIdsPresentation).thenReturn(
        <EmailId, PresentationEmail?>{}.obs,
      );
      
      // act
      threadDetailController.handleGetEmailIdsByThreadIdSuccess(success);
      
      // assert
      expect(threadDetailController.emailIdsPresentation.keys, success.emailIds);
    });

    test(
      'should assign emailIds with result from mailbox dashboard controller '
      'when result from success is empty '
      'and mailbox dashboard controller selected email is not null',
    () {
      // arrange
      final mailboxDashBoardController = MockMailboxDashBoardController();
      final success = GetThreadByIdSuccess([]);
      when(mailboxDashBoardController.selectedEmail).thenReturn(
        Rxn(PresentationEmail(id: EmailId(Id('1')))),
      );
      when(threadDetailController.emailIdsPresentation).thenReturn(
        <EmailId, PresentationEmail?>{}.obs,
      );
      when(threadDetailController.mailboxDashBoardController).thenReturn(mailboxDashBoardController);
      
      // act
      threadDetailController.handleGetEmailIdsByThreadIdSuccess(success);
      
      // assert
      expect(
        threadDetailController.emailIdsPresentation.keys,
        [mailboxDashBoardController.selectedEmail.value!.id!],
      );
    });
  });
}