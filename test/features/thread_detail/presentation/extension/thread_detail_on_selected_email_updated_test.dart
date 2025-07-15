import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get_rx/get_rx.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/core/properties/properties.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:model/email/presentation_email.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/thread_detail/domain/state/get_emails_by_ids_state.dart';
import 'package:tmail_ui_user/features/thread_detail/domain/state/get_thread_by_id_state.dart';
import 'package:tmail_ui_user/features/thread_detail/domain/usecases/get_thread_by_id_interactor.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/extension/thread_detail_on_selected_email_updated.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/thread_detail_controller.dart';

import '../../../../fixtures/account_fixtures.dart';
import '../../../../fixtures/session_fixtures.dart';
import 'thread_detail_on_selected_email_updated_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<ThreadDetailController>(),
  MockSpec<GetThreadByIdInteractor>(),
  MockSpec<MailboxDashBoardController>(),
])
void main() {
  late MockThreadDetailController threadDetailController;
  late MockGetThreadByIdInteractor getThreadByIdInteractor;
  late MockMailboxDashBoardController mailboxDashboardController;

  setUp(() {
    threadDetailController = MockThreadDetailController();
    getThreadByIdInteractor = MockGetThreadByIdInteractor();
    mailboxDashboardController = MockMailboxDashBoardController();
    when(threadDetailController.session)
      .thenReturn(SessionFixtures.aliceSession);
    when(threadDetailController.accountId)
      .thenReturn(AccountFixtures.aliceAccountId);
    when(threadDetailController.additionalProperties)
      .thenReturn(Properties.empty());
    when(threadDetailController.mailboxDashBoardController)
      .thenReturn(mailboxDashboardController);
  });
  
  group('thread detail on selected email updated test:', () {
    test(
      'should reset thread detail controller '
      'when selected email is null',
    () {
      // act
      threadDetailController.onSelectedEmailUpdated(
        null,
        getThreadByIdInteractor,
        null,
      );
      
      // assert
      verify(threadDetailController.reset()).called(1);
    });

    test(
      'should not reset thread detail controller '
      'and consume PreloadEmailIdsInThreadSuccess and PreloadEmailsByIdsSuccess '
      'when selected email and its id is not null',
    () async {
      // arrange
      final selectedEmail = PresentationEmail(
        id: EmailId(Id('1')),
        threadId: ThreadId(Id('1')),
      );
      when(threadDetailController.currentExpandedEmailId).thenReturn(Rxn());

      // act
      threadDetailController.onSelectedEmailUpdated(
        selectedEmail,
        getThreadByIdInteractor,
        null,
      );
      
      // assert
      verifyNever(threadDetailController.reset());
      final streamsConsumed = (verify(
        threadDetailController.consumeState(captureAny),
      ).captured as List<Object?>).first as Stream?;
      expect(
        streamsConsumed,
        emitsInOrder([
          Right(PreloadEmailIdsInThreadSuccess([selectedEmail.id!], threadId: ThreadId(Id('1')))),
          Right(PreloadEmailsByIdsSuccess([selectedEmail])),
        ]),
      );
    });
  });
}