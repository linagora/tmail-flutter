import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/core/properties/properties.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:model/email/presentation_email.dart';
import 'package:tmail_ui_user/features/thread_detail/domain/state/get_thread_by_id_state.dart';
import 'package:tmail_ui_user/features/thread_detail/domain/usecases/get_emails_by_ids_interactor.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/extension/initialize_thread_detail_emails.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/thread_detail_controller.dart';

import '../../../../fixtures/session_fixtures.dart';
import 'initialize_thread_detail_emails_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<GetEmailsByIdsInteractor>(),
  MockSpec<ThreadDetailController>(),
  MockSpec<MailboxDashBoardController>(),
])
void main() {
  group('InitializeThreadDetailEmails', () {
    late MockGetEmailsByIdsInteractor getEmailsByIdsInteractor;
    late MockThreadDetailController threadDetailController;
    late MockMailboxDashBoardController mailboxDashboardController;

    setUp(() {
      getEmailsByIdsInteractor = MockGetEmailsByIdsInteractor();
      threadDetailController = MockThreadDetailController();
      mailboxDashboardController = MockMailboxDashBoardController();
    });

    test('initializeThreadDetailEmails should call getEmailsByIdsInteractor with 2 elements', () async {
      // Arrange
      final emailIds = [
        EmailId(Id('email1')),
        EmailId(Id('email2')),
        EmailId(Id('email3')),
        EmailId(Id('email4')),
        EmailId(Id('email5')),
      ];

      when(threadDetailController.emailIdsPresentation).thenReturn(
        Map.fromEntries(emailIds.map((emailId) => MapEntry(emailId, null))).obs,
      );
      when(threadDetailController.getEmailsByIdsInteractor).thenReturn(getEmailsByIdsInteractor);
      when(threadDetailController.additionalProperties).thenReturn(Properties.empty());
      when(getEmailsByIdsInteractor.execute(
        any,
        any,
        any,
        properties: anyNamed('properties'),
      )).thenAnswer((_) => const Stream.empty());
      final accountId = AccountId(Id('accountId'));
      final session = SessionFixtures.aliceSession;
      when(threadDetailController.accountId).thenReturn(accountId);
      when(threadDetailController.session).thenReturn(session);
      when(threadDetailController.isThreadDetailEnabled)
        .thenReturn(true);
      when(threadDetailController.networkConnected)
        .thenReturn(true);
      when(threadDetailController.mailboxDashBoardController)
        .thenReturn(mailboxDashboardController);
      when(mailboxDashboardController.selectedEmail)
        .thenReturn(Rxn(PresentationEmail(id: emailIds[0])));

      // Act
      threadDetailController.initializeThreadDetailEmails(
        GetThreadByIdSuccess(emailIds),
      );

      // Assert
      final captured = verify(getEmailsByIdsInteractor.execute(
        captureAny,
        captureAny,
        captureAny,
        properties: captureAnyNamed('properties'),
      )).captured;

      expect((captured[2] as List<EmailId>).length, 2);
    });
  });
}
