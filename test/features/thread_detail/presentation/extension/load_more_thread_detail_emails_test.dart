import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/core/properties/properties.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:model/email/presentation_email.dart';
import 'package:tmail_ui_user/features/email/presentation/utils/email_utils.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/thread_detail/domain/usecases/get_emails_by_ids_interactor.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/extension/load_more_thread_detail_emails.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/thread_detail_controller.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/utils/thread_detail_presentation_utils.dart';

import '../../../../fixtures/account_fixtures.dart';
import '../../../../fixtures/session_fixtures.dart';
import 'load_more_thread_detail_emails_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<ThreadDetailController>(),
  MockSpec<GetEmailsByIdsInteractor>(),
  MockSpec<MailboxDashBoardController>(),
])
void main() {
  late MockThreadDetailController controller;
  late MockGetEmailsByIdsInteractor getEmailsByIdsInteractor;
  late MockMailboxDashBoardController mailboxDashBoardController;

  setUp(() {
    controller = MockThreadDetailController();
    getEmailsByIdsInteractor = MockGetEmailsByIdsInteractor();
    mailboxDashBoardController = MockMailboxDashBoardController();
  });

  test('Only call getEmailsByIdsInteractor.execute on emails where presentation email is null, max 20 emails', () async {
    // Arrange
    when(controller.emailIdsPresentation).thenReturn({
      for (int i = 0; i < 40; i++) EmailId(Id('$i')): null,
    }.obs);
    when(controller.currentExpandedEmailId).thenReturn(Rxn());
    when(controller.session).thenReturn(SessionFixtures.aliceSession);
    when(controller.accountId).thenReturn(AccountFixtures.aliceAccountId);
    when(controller.getEmailsByIdsInteractor).thenReturn(getEmailsByIdsInteractor);
    when(controller.additionalProperties).thenReturn(Properties.empty());
    when(controller.mailboxDashBoardController).thenReturn(mailboxDashBoardController);
    when(mailboxDashBoardController.selectedEmail).thenReturn(Rxn());

    // Act
    controller.loadMoreThreadDetailEmails(
      loadMoreIndex: 0,
      loadMoreCount: controller.emailIdsPresentation.length,
    );

    // Assert
    verify(getEmailsByIdsInteractor.execute(
      SessionFixtures.aliceSession,
      AccountFixtures.aliceAccountId,
      List.generate(20, (i) => EmailId(Id('$i'))),
      properties: EmailUtils.getPropertiesForEmailGetMethod(
        SessionFixtures.aliceSession,
        AccountFixtures.aliceAccountId,
      ),
      loadMoreIndex: 0,
    )).called(1);
  });

  test('No getEmailsByIdsInteractor.execute call if emailIdsToLoadMetaData is empty', () async {
    // Arrange
    when(controller.emailIdsPresentation).thenReturn(<EmailId, PresentationEmail?>{}.obs);
    when(controller.currentExpandedEmailId).thenReturn(Rxn());
    when(controller.session).thenReturn(SessionFixtures.aliceSession);
    when(controller.accountId).thenReturn(AccountFixtures.aliceAccountId);
    when(controller.getEmailsByIdsInteractor).thenReturn(getEmailsByIdsInteractor);
    when(controller.mailboxDashBoardController).thenReturn(mailboxDashBoardController);
    when(mailboxDashBoardController.selectedEmail).thenReturn(Rxn());

    // Act
    controller.loadMoreThreadDetailEmails(
      loadMoreIndex: 0,
      loadMoreCount: controller.emailIdsPresentation.length,
    );

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
      for (int i = 0; i < limit; i++) EmailId(Id('$i')): null,
    }.obs);
    when(controller.currentExpandedEmailId).thenReturn(Rxn());
    when(controller.session).thenReturn(SessionFixtures.aliceSession);
    when(controller.accountId).thenReturn(AccountFixtures.aliceAccountId);
    when(controller.getEmailsByIdsInteractor).thenReturn(getEmailsByIdsInteractor);
    when(controller.additionalProperties).thenReturn(Properties.empty());
    when(controller.mailboxDashBoardController).thenReturn(mailboxDashBoardController);
    when(mailboxDashBoardController.selectedEmail).thenReturn(Rxn());

    // Act
    controller.loadMoreThreadDetailEmails(
      loadMoreIndex: 0,
      loadMoreCount: controller.emailIdsPresentation.length,
    );

    // Assert
    verify(getEmailsByIdsInteractor.execute(
      SessionFixtures.aliceSession,
      AccountFixtures.aliceAccountId,
      List.generate(limit, (i) => EmailId(Id('$i'))),
      properties: EmailUtils.getPropertiesForEmailGetMethod(
        SessionFixtures.aliceSession,
        AccountFixtures.aliceAccountId,
      ),
      loadMoreIndex: 0,
    )).called(1);
  });


  test(
    'should call getEmailsByIdsInteractor.execute '
    'with ThreadDetailPresentationUtils.defaultLoadSize (20) top to bottom '
    'when loadMoreIndex is larger than index of currentExpandedEmailId',
  () {
    // arrange
    final loadMoreEmails = {
      for (int i = 31; i < 60; i++) EmailId(Id('$i')): null
    };
    const loadMoreIndex = 32;
    when(controller.emailIdsPresentation).thenReturn({
      for (int i = 0; i < 30; i++) EmailId(Id('$i')): null,
      EmailId(Id('30')): PresentationEmail(),
      ...loadMoreEmails,
    }.obs);
    when(controller.currentExpandedEmailId).thenReturn(Rxn(EmailId(Id('30'))));
    when(controller.session).thenReturn(SessionFixtures.aliceSession);
    when(controller.accountId).thenReturn(AccountFixtures.aliceAccountId);
    when(controller.additionalProperties).thenReturn(Properties.empty());
    when(controller.getEmailsByIdsInteractor).thenReturn(getEmailsByIdsInteractor);
    when(controller.mailboxDashBoardController).thenReturn(mailboxDashBoardController);
    when(mailboxDashBoardController.selectedEmail).thenReturn(Rxn());
    
    // act
    controller.loadMoreThreadDetailEmails(
      loadMoreIndex: loadMoreIndex,
      loadMoreCount: loadMoreEmails.length,
    );
    
    // assert
    verify(getEmailsByIdsInteractor.execute(
      SessionFixtures.aliceSession,
      AccountFixtures.aliceAccountId,
      List.generate(
        ThreadDetailPresentationUtils.defaultLoadSize,
        (i) => EmailId(Id('${i + loadMoreIndex}')),
      ),
      properties: EmailUtils.getPropertiesForEmailGetMethod(
        SessionFixtures.aliceSession,
        AccountFixtures.aliceAccountId,
      ),
      loadMoreIndex: loadMoreIndex,
    )).called(1);
  });

  test(
    'should call getEmailsByIdsInteractor.execute '
    'with ThreadDetailPresentationUtils.defaultLoadSize (20) bottom to top '
    'when loadMoreIndex is larger than index of currentExpandedEmailId',
  () {
    // arrange
    final loadMoreEmails = {
      for (int i = 0; i < 30; i++) EmailId(Id('$i')): null
    };
    const loadMoreIndex = 0;
    when(controller.emailIdsPresentation).thenReturn({
      ...loadMoreEmails,
      EmailId(Id('30')): PresentationEmail(),
      for (int i = 31; i < 60; i++) EmailId(Id('$i')): null,
    }.obs);
    when(controller.currentExpandedEmailId).thenReturn(Rxn(EmailId(Id('30'))));
    when(controller.session).thenReturn(SessionFixtures.aliceSession);
    when(controller.accountId).thenReturn(AccountFixtures.aliceAccountId);
    when(controller.additionalProperties).thenReturn(Properties.empty());
    when(controller.getEmailsByIdsInteractor).thenReturn(getEmailsByIdsInteractor);
    when(controller.mailboxDashBoardController).thenReturn(mailboxDashBoardController);
    when(mailboxDashBoardController.selectedEmail).thenReturn(Rxn());
    
    // act
    controller.loadMoreThreadDetailEmails(
      loadMoreIndex: loadMoreIndex,
      loadMoreCount: loadMoreEmails.length,
    );
    
    // assert
    verify(getEmailsByIdsInteractor.execute(
      SessionFixtures.aliceSession,
      AccountFixtures.aliceAccountId,
      List.generate(
        ThreadDetailPresentationUtils.defaultLoadSize,
        (i) => EmailId(Id('${loadMoreEmails.length - i - 1}')),
      ).reversed.toList(),
      properties: EmailUtils.getPropertiesForEmailGetMethod(
        SessionFixtures.aliceSession,
        AccountFixtures.aliceAccountId,
      ),
      loadMoreIndex: loadMoreIndex,
    )).called(1);
  });
}
