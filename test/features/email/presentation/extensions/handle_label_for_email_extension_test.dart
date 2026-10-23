import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/remove_a_label_from_an_email_interactor.dart';
import 'package:tmail_ui_user/features/email/presentation/controller/single_email_controller.dart';
import 'package:tmail_ui_user/features/email/presentation/extensions/handle_label_for_email_extension.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';

import '../../../../fixtures/delegation_fixtures.dart';
import 'handle_label_for_email_extension_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<SingleEmailController>(),
  MockSpec<MailboxDashBoardController>(),
  MockSpec<RemoveALabelFromAnEmailInteractor>(),
])
void main() {
  test(
    'removes the needs-action keyword from the email of the shown account, not of my own',
    _removesNeedsActionInShownAccount,
  );
}

void _removesNeedsActionInShownAccount() {
  final controller = MockSingleEmailController();
  final dashboard = MockMailboxDashBoardController();
  final interactor = MockRemoveALabelFromAnEmailInteractor();
  when(controller.mailboxDashBoardController).thenReturn(dashboard);
  when(controller.activeAccountId).thenReturn(DelegationFixtures.bobAccountId);
  when(dashboard.sessionCurrent).thenReturn(DelegationFixtures.session());
  when(dashboard.removeALabelFromAnEmailInteractor).thenReturn(interactor);

  controller.onRemoveNeedsActionKeyword(EmailId(Id('email-1')), labelDisplay: 'Needs action');

  verify(interactor.execute(any, DelegationFixtures.bobAccountId, any, any, any)).called(1);
}
