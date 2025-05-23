import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:model/email/presentation_email.dart';
import 'package:tmail_ui_user/features/email/presentation/utils/email_utils.dart';
import 'package:tmail_ui_user/features/thread_detail/domain/usecases/get_emails_by_ids_interactor.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/extension/load_more_thread_detail_emails.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/thread_detail_controller.dart';

import '../../../../fixtures/account_fixtures.dart';
import '../../../../fixtures/session_fixtures.dart';
import 'load_more_thread_detail_emails_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<ThreadDetailController>(),
  MockSpec<GetEmailsByIdsInteractor>(),
])
void main() {
  late MockThreadDetailController controller;
  late MockGetEmailsByIdsInteractor getEmailsByIdsInteractor;

  setUp(() {
    controller = MockThreadDetailController();
    getEmailsByIdsInteractor = MockGetEmailsByIdsInteractor();
  });

  test('Only call getEmailsByIdsInteractor.execute on emails where presentation email is null, max 20 emails', () async {
    // Arrange
    when(controller.emailIdsPresentation).thenReturn({
      for (int i = 0; i < 40; i++)
        EmailId(Id('$i')): null,
      EmailId(Id('40')): PresentationEmail(),
    }.obs);
    when(controller.session).thenReturn(SessionFixtures.aliceSession);
    when(controller.accountId).thenReturn(AccountFixtures.aliceAccountId);
    when(controller.getEmailsByIdsInteractor).thenReturn(getEmailsByIdsInteractor);

    // Act
    controller.loadMoreThreadDetailEmails();

    // Assert
    verify(getEmailsByIdsInteractor.execute(
      SessionFixtures.aliceSession,
      AccountFixtures.aliceAccountId,
      List.generate(20, (i) => EmailId(Id('${i + 20}'))),
      properties: EmailUtils.getPropertiesForEmailGetMethod(
        SessionFixtures.aliceSession,
        AccountFixtures.aliceAccountId,
      ),
    )).called(1);
  });

  test('No getEmailsByIdsInteractor.execute call if emailIdsToLoadMetaData is empty', () async {
    // Arrange
    when(controller.emailIdsPresentation).thenReturn({
      EmailId(Id('1')): PresentationEmail(),
      EmailId(Id('2')): PresentationEmail(),
    }.obs);
    when(controller.session).thenReturn(SessionFixtures.aliceSession);
    when(controller.accountId).thenReturn(AccountFixtures.aliceAccountId);
    when(controller.getEmailsByIdsInteractor).thenReturn(getEmailsByIdsInteractor);

    // Act
    controller.loadMoreThreadDetailEmails();

    // Assert
    verifyNever(getEmailsByIdsInteractor.execute(
      any,
      any,
      any,
      properties: anyNamed('properties'),
    ));
  });

  test('Call getEmailsByIdsInteractor.execute when there are less than 20 emails', () async {
    // Arrange
    const limit = 15;
    when(controller.emailIdsPresentation).thenReturn({
      for (int i = 0; i < limit; i++)
        EmailId(Id('$i')): null,
      EmailId(Id('$limit')): PresentationEmail(),
    }.obs);
    when(controller.session).thenReturn(SessionFixtures.aliceSession);
    when(controller.accountId).thenReturn(AccountFixtures.aliceAccountId);
    when(controller.getEmailsByIdsInteractor).thenReturn(getEmailsByIdsInteractor);

    // Act
    controller.loadMoreThreadDetailEmails();

    // Assert
    verify(getEmailsByIdsInteractor.execute(
      SessionFixtures.aliceSession,
      AccountFixtures.aliceAccountId,
      List.generate(limit, (i) => EmailId(Id('$i'))),
      properties: EmailUtils.getPropertiesForEmailGetMethod(
        SessionFixtures.aliceSession,
        AccountFixtures.aliceAccountId,
      ),
    )).called(1);
  });
}
