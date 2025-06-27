import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get_rx/get_rx.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:model/email/presentation_email.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/thread_detail/domain/state/get_emails_by_ids_state.dart';
import 'package:tmail_ui_user/features/thread_detail/domain/state/get_thread_by_id_state.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/extension/handle_get_thread_by_id_failure.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/thread_detail_controller.dart';

import 'handle_get_thread_by_id_failure_test.mocks.dart';

@GenerateNiceMocks([MockSpec<ThreadDetailController>()])
@GenerateNiceMocks([MockSpec<MailboxDashBoardController>()])
void main() {
  late MockThreadDetailController controller;
  late MockMailboxDashBoardController mailboxDashBoardController;

  setUp(() {
    controller = MockThreadDetailController();
    mailboxDashBoardController = MockMailboxDashBoardController();
  });

  group('handle get thread by id failure test', () {
    test(
      'should not call consumeState '
      'when updateCurrentThreadDetail is true',
    () {
      // arrange
      final failure = GetThreadByIdFailure(updateCurrentThreadDetail: true);
      
      // act
      controller.handleGetThreadByIdFailure(failure);
      
      // assert
      verifyNever(controller.consumeState(any));
    });

    test(
      'should consumeState GetEmailsByIdsSuccess with selected email '
      'when updateCurrentThreadDetail is false '
      'and selected email is not null',
    () {
      // arrange
      final failure = GetThreadByIdFailure(updateCurrentThreadDetail: false);
      final selectedEmail = PresentationEmail(id: EmailId(Id('1')));
      when(controller.mailboxDashBoardController)
          .thenReturn(mailboxDashBoardController);
      when(mailboxDashBoardController.selectedEmail)
          .thenReturn(Rxn(selectedEmail));
      
      // act
      controller.handleGetThreadByIdFailure(failure);
      
      // assert
      final streamsConsumed = (verify(
        controller.consumeState(captureAny),
      ).captured as List<Object?>).first as Stream?;
      expect(
        streamsConsumed,
        emitsInOrder([
          Right(GetEmailsByIdsSuccess([selectedEmail])),
        ]),
      );
    });

    test(
      'should show retry toast '
      'when updateCurrentThreadDetail is false '
      'and selected email is null',
    () {
      // arrange
      final failure = GetThreadByIdFailure(updateCurrentThreadDetail: false);
      when(controller.mailboxDashBoardController)
          .thenReturn(mailboxDashBoardController);
      when(mailboxDashBoardController.selectedEmail).thenReturn(Rxn());
      
      // act
      controller.handleGetThreadByIdFailure(failure);
      
      // assert
      verify(controller.showRetryToast(failure));
      verifyNever(controller.consumeState(any));
    });
  });
}