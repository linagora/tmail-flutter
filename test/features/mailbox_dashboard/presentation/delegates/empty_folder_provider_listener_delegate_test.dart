import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:tmail_ui_user/features/delegation/presentation/notifier/active_account_notifier.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/delegates/empty_folder_provider_listener_delegate.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/empty_folder_request.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/providers/empty_folder_provider.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/riverpod_widgets/mailbox_dashboard_provider_listener_widget.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/strategies/empty_folder_tag.dart';

import '../../../../fixtures/delegation_fixtures.dart';
import 'empty_folder_provider_listener_delegate_test.mocks.dart';

mockControllerCallback() => InternalFinalCallback<void>(callback: () {});
const fallbackGenerators = {
  #onStart: mockControllerCallback,
  #onDelete: mockControllerCallback,
};

/// Records the account an empty-folder run was started with, without running it.
class _RecordingEmptyFolderNotifier extends EmptyFolderNotifier {
  static final executedAccountIds = <AccountId>[];

  @override
  Future<void> execute(
    Session session,
    AccountId accountId,
    PresentationMailbox mailbox,
    List<MailboxId> childIds,
    bool useJmapClear,
  ) async {
    executedAccountIds.add(accountId);
  }
}

@GenerateNiceMocks([
  MockSpec<MailboxDashBoardController>(fallbackGenerators: fallbackGenerators),
])
void main() {
  tearDown(() {
    Get.reset();
    _RecordingEmptyFolderNotifier.executedAccountIds.clear();
  });

  testWidgets('empties the trash of the shown account, not of my own', _emptiesTrashOfShownAccount);
}

Future<void> _emptiesTrashOfShownAccount(WidgetTester tester) async {
  final session = DelegationFixtures.session();
  final requests = StreamController<EmptyFolderRequest>.broadcast();
  addTearDown(requests.close);
  final dashboard = MockMailboxDashBoardController();
  when(dashboard.sessionCurrent).thenReturn(session);
  when(dashboard.mapMailboxById).thenReturn({});
  when(dashboard.onEmptyFolderRequested).thenAnswer((_) => requests.stream);
  Get.put<MailboxDashBoardController>(dashboard);

  final container = ProviderContainer(overrides: [
    emptyFolderProvider.overrideWith2((_) => _RecordingEmptyFolderNotifier()),
  ]);
  addTearDown(container.dispose);
  container.read(activeAccountProvider.notifier)
    ..applySession(session)
    ..select(DelegationFixtures.bobAccountId);

  await tester.pumpWidget(UncontrolledProviderScope(
    container: container,
    child: const MaterialApp(
      home: MailboxDashboardProviderListenerWidget(
        delegateFactories: [EmptyFolderProviderListenerDelegate.trash],
        child: SizedBox.shrink(),
      ),
    ),
  ));
  requests.add(EmptyFolderRequest(
    mailbox: PresentationMailbox(MailboxId(Id('trash-id'))),
    tag: EmptyFolderTag.trash,
  ));
  await tester.pump();

  expect(_RecordingEmptyFolderNotifier.executedAccountIds, [DelegationFixtures.bobAccountId]);
}
