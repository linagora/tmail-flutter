import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:tmail_ui_user/features/email/presentation/utils/email_action_reactor/email_action_reactor.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/extension/thread_detail_open_email_address_detail_action.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/thread_detail_controller.dart';

import '../../../../fixtures/delegation_fixtures.dart';
import 'thread_detail_open_email_address_detail_action_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<ThreadDetailController>(),
  MockSpec<EmailActionReactor>(),
])
void main() {
  test('opens the email address dialog on the shown account', () {
    final controller = MockThreadDetailController();
    final reactor = MockEmailActionReactor();
    when(controller.emailActionReactor).thenReturn(reactor);
    when(controller.session).thenReturn(DelegationFixtures.session());
    when(controller.accountId).thenReturn(DelegationFixtures.bobAccountId);

    controller.openEmailAddressDetailAction(EmailAddress('Carol', DelegationFixtures.carolAddress));

    verify(reactor.openEmailAddressDialog(
      any,
      DelegationFixtures.bobAccountId,
      emailAddress: anyNamed('emailAddress'),
      responsiveUtils: anyNamed('responsiveUtils'),
      imagePaths: anyNamed('imagePaths'),
      appToast: anyNamed('appToast'),
      onComposeEmailFromEmailAddressRequest: anyNamed('onComposeEmailFromEmailAddressRequest'),
      onQuickCreateRuleRequest: anyNamed('onQuickCreateRuleRequest'),
    )).called(1);
  });
}
