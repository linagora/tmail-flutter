import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/email/keyword_identifier.dart';
import 'package:labels/model/label.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/add_a_label_to_a_thread_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/extension/labels/add_label_to_thread_extension.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/thread_detail_controller.dart';

import '../../../../../fixtures/delegation_fixtures.dart';
import 'add_label_to_thread_extension_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<ThreadDetailController>(),
  MockSpec<MailboxDashBoardController>(),
  MockSpec<AddALabelToAThreadInteractor>(),
])
void main() {
  test('adds the label to the thread of the shown account, not of my own', _addsLabelInShownAccount);
}

void _addsLabelInShownAccount() {
  final controller = MockThreadDetailController();
  final dashboard = MockMailboxDashBoardController();
  final interactor = MockAddALabelToAThreadInteractor();
  when(controller.mailboxDashBoardController).thenReturn(dashboard);
  when(controller.addALabelToAThreadInteractor).thenReturn(interactor);
  when(controller.activeAccountId).thenReturn(DelegationFixtures.bobAccountId);
  when(dashboard.sessionCurrent).thenReturn(DelegationFixtures.session());

  controller.toggleLabelToThread(
    Label(keyword: KeyWordIdentifier('\$label_work'), displayName: 'Work'),
    isSelected: true,
    currentEmailIds: [EmailId(Id('email-1'))],
  );

  verify(interactor.execute(any, DelegationFixtures.bobAccountId, any, any, any)).called(1);
}
