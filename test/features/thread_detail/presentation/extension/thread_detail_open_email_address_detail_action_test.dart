import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:tmail_ui_user/features/email/presentation/utils/email_action_reactor/email_action_reactor.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/extension/thread_detail_open_email_address_detail_action.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/thread_detail_controller.dart';

import '../../../../fixtures/delegation_fixtures.dart';
import 'thread_detail_open_email_address_detail_action_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<ThreadDetailController>(),
  MockSpec<MailboxDashBoardController>(),
  MockSpec<EmailActionReactor>(),
])
void main() {
  test(
    'opens the email address dialog on my own account, whose quick rule is my email rule filter',
    () {
      final controller = MockThreadDetailController();
      final dashboard = MockMailboxDashBoardController();
      final reactor = MockEmailActionReactor();
      when(controller.mailboxDashBoardController).thenReturn(dashboard);
      when(controller.emailActionReactor).thenReturn(reactor);
      when(controller.session).thenReturn(DelegationFixtures.session());
      when(controller.activeAccountId).thenReturn(DelegationFixtures.bobAccountId);
      when(dashboard.accountId).thenReturn(Rxn(DelegationFixtures.aliceAccountId));

      controller.openEmailAddressDetailAction(EmailAddress('Carol', DelegationFixtures.carolAddress));

      verify(reactor.openEmailAddressDialog(
        any,
        DelegationFixtures.aliceAccountId,
        emailAddress: anyNamed('emailAddress'),
        responsiveUtils: anyNamed('responsiveUtils'),
        imagePaths: anyNamed('imagePaths'),
        appToast: anyNamed('appToast'),
        onComposeEmailFromEmailAddressRequest: anyNamed('onComposeEmailFromEmailAddressRequest'),
        onQuickCreateRuleRequest: anyNamed('onQuickCreateRuleRequest'),
      )).called(1);
    },
  );
}
