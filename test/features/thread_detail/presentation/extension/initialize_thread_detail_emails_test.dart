import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:tmail_ui_user/features/thread_detail/domain/usecases/get_emails_by_ids_interactor.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/extension/initialize_thread_detail_emails.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/thread_detail_controller.dart';

import '../../../../fixtures/session_fixtures.dart';
import 'initialize_thread_detail_emails_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<GetEmailsByIdsInteractor>(),
  MockSpec<ThreadDetailController>(),
])
void main() {
  group('InitializeThreadDetailEmails', () {
    late MockGetEmailsByIdsInteractor getEmailsByIdsInteractor;
    late MockThreadDetailController threadDetailController;

    setUp(() {
      getEmailsByIdsInteractor = MockGetEmailsByIdsInteractor();
      threadDetailController = MockThreadDetailController();
    });

    test('initializeThreadDetailEmails should call getEmailsByIdsInteractor with 3 elements', () async {
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

      // Act
      threadDetailController.initializeThreadDetailEmails();

      // Assert
      final captured = verify(getEmailsByIdsInteractor.execute(
        captureAny,
        captureAny,
        captureAny,
        properties: captureAnyNamed('properties'),
      )).captured;

      expect((captured[2] as List<EmailId>).length, 3);
    });
  });
}
