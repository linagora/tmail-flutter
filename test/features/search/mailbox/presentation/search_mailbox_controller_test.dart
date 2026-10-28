import 'package:email_recovery/email_recovery/capability_deleted_messages_vault.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/account/account.dart';
import 'package:jmap_dart_client/jmap/core/capability/capability_identifier.dart';
import 'package:jmap_dart_client/jmap/core/capability/default_capability.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:tmail_ui_user/features/destination_picker/presentation/model/destination_picker_arguments.dart';
import 'package:tmail_ui_user/features/email/domain/model/move_action.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/move_folder_content_request.dart';
import 'package:tmail_ui_user/features/mailbox/domain/state/move_folder_content_state.dart';
import 'package:tmail_ui_user/features/mailbox/domain/usecases/create_new_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/mailbox/domain/usecases/delete_multiple_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/mailbox/domain/usecases/get_all_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/mailbox/domain/usecases/move_folder_content_interactor.dart';
import 'package:tmail_ui_user/features/mailbox/domain/usecases/move_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/mailbox/domain/usecases/refresh_all_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/mailbox/domain/usecases/rename_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/mailbox/domain/usecases/search_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/mailbox/domain/usecases/subaddressing_interactor.dart';
import 'package:tmail_ui_user/features/mailbox/domain/usecases/subscribe_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/mailbox/domain/usecases/subscribe_multiple_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_actions.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_tree_builder.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/utils/mailbox_action_reactor.dart';
import 'package:tmail_ui_user/features/mailbox_creator/domain/usecases/verify_name_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/search/mailbox/presentation/search_mailbox_controller.dart';
import 'package:tmail_ui_user/main/routes/app_routes.dart';
import 'package:tmail_ui_user/main/utils/toast_manager.dart';

import '../../../../fixtures/active_account_source_fixtures.dart';
import '../../../../fixtures/base_controller_fixtures.dart';
import '../../../../fixtures/delegation_fixtures.dart';
import '../../../../fixtures/route_arguments_recorder.dart';
import '../../../../fixtures/widget_fixtures.dart';
import '../../../base/base_controller_test.mocks.dart' show MockToastManager;
import 'search_mailbox_controller_test.mocks.dart';

mockControllerCallback() => InternalFinalCallback<void>(callback: () {});
const fallbackGenerators = {
  #onStart: mockControllerCallback,
  #onDelete: mockControllerCallback,
};

@GenerateNiceMocks([
  MockSpec<SearchMailboxInteractor>(),
  MockSpec<RenameMailboxInteractor>(),
  MockSpec<MoveMailboxInteractor>(),
  MockSpec<DeleteMultipleMailboxInteractor>(),
  MockSpec<SubscribeMailboxInteractor>(),
  MockSpec<SubscribeMultipleMailboxInteractor>(),
  MockSpec<CreateNewMailboxInteractor>(),
  MockSpec<SubaddressingInteractor>(),
  MockSpec<MoveFolderContentInteractor>(),
  MockSpec<GetAllMailboxInteractor>(),
  MockSpec<RefreshAllMailboxInteractor>(),
  MockSpec<MailboxDashBoardController>(fallbackGenerators: fallbackGenerators),
])
void main() {
  late MockMailboxDashBoardController dashboard;

  setUp(() {
    BaseControllerFixtures.registerDependencies();
    dashboard = MockMailboxDashBoardController();
    when(dashboard.sessionCurrent).thenReturn(DelegationFixtures.session());
    when(dashboard.accountId).thenReturn(Rxn(DelegationFixtures.aliceAccountId));
    Get.put<MailboxDashBoardController>(dashboard);
    ActiveAccountSourceFixtures.putShowing(DelegationFixtures.bobAccountId);
  });

  tearDown(Get.reset);

  testWidgets('marks a folder as read in the shown account, not in my own', (tester) async {
    final context = await _pumpContext(tester);

    _newController().markAsReadMailboxAction(
      context,
      PresentationMailbox(MailboxId(Id('folder-1'))),
      dashboard,
    );

    expect(_newController().accountId, DelegationFixtures.bobAccountId);
    verify(dashboard.markAsReadMailbox(any, DelegationFixtures.bobAccountId, any, any, any)).called(1);
  });

  testWidgets('moving a folder opens the folder picker on the shown account, not on my own', (tester) async {
    final recorder = await RouteArgumentsRecorder.pump(tester, AppRoutes.destinationPicker);

    _newController().handleMailboxAction(recorder.context, MailboxActions.move, _folder);
    await tester.pumpAndSettle();

    expect((recorder.arguments as DestinationPickerArguments).accountId, DelegationFixtures.bobAccountId);
  });

  testWidgets('moving the content of a folder moves it in the shown account, not in my own', (tester) async {
    final moveFolderContentInteractor = MockMoveFolderContentInteractor();
    when(moveFolderContentInteractor.execute(
      session: anyNamed('session'),
      accountId: anyNamed('accountId'),
      request: anyNamed('request'),
      onProgressController: anyNamed('onProgressController'),
    )).thenAnswer((_) => const Stream.empty());
    final controller = _newController(moveFolderContentInteractor: moveFolderContentInteractor)
      ..mailboxActionReactor = MailboxActionReactor(moveFolderContentInteractor);
    final recorder = await RouteArgumentsRecorder.pump(tester, AppRoutes.destinationPicker);

    controller.handleMailboxAction(recorder.context, MailboxActions.moveFolderContent, _folder);
    await tester.pumpAndSettle();
    Get.back(result: PresentationMailbox(MailboxId(Id('destination'))));
    await tester.pumpAndSettle();

    expect((recorder.arguments as DestinationPickerArguments).accountId, DelegationFixtures.bobAccountId);
    verify(moveFolderContentInteractor.execute(
      session: anyNamed('session'),
      accountId: DelegationFixtures.bobAccountId,
      request: anyNamed('request'),
      onProgressController: anyNamed('onProgressController'),
    )).called(1);
  });

  test('undoing a folder content move moves it back in the shown account, not in my own', () {
    final moveFolderContentInteractor = MockMoveFolderContentInteractor();
    when(moveFolderContentInteractor.execute(
      session: anyNamed('session'),
      accountId: anyNamed('accountId'),
      request: anyNamed('request'),
      onProgressController: anyNamed('onProgressController'),
    )).thenAnswer((_) => const Stream.empty());
    final reactor = MailboxActionReactor(moveFolderContentInteractor);
    final controller = _newController(moveFolderContentInteractor: moveFolderContentInteractor);
    final toastManager = Get.find<ToastManager>() as MockToastManager;

    controller.handleMoveFolderContentSuccess(
      success: MoveFolderContentSuccess(MoveFolderContentRequest(
        mailboxId: MailboxId(Id('folder-1')),
        moveAction: MoveAction.moving,
        destinationMailboxId: MailboxId(Id('destination')),
        destinationMailboxDisplayName: 'Destination',
      )),
      dashboardController: dashboard,
      baseMailboxController: controller,
      mailboxActionReactor: reactor,
    );
    final undo = verify(toastManager.showMessageSuccessWithAction(
      success: anyNamed('success'),
      onActionCallback: captureAnyNamed('onActionCallback'),
    )).captured.single as VoidCallback;
    undo();

    verify(moveFolderContentInteractor.execute(
      session: anyNamed('session'),
      accountId: DelegationFixtures.bobAccountId,
      request: anyNamed('request'),
      onProgressController: anyNamed('onProgressController'),
    )).called(1);
  });

  testWidgets('disallowing subaddressing changes the folder of the shown account, not of my own', (tester) async {
    final subaddressingInteractor = MockSubaddressingInteractor();
    when(subaddressingInteractor.execute(any, any, any)).thenAnswer((_) => const Stream.empty());
    final context = await _pumpContext(tester);

    _newController(subaddressingInteractor: subaddressingInteractor)
        .handleMailboxAction(context, MailboxActions.disallowSubaddressing, _folder);

    verify(subaddressingInteractor.execute(any, DelegationFixtures.bobAccountId, any)).called(1);
  });

  test('the folder menu offers the deleted messages vault and subaddressing of the shown account', () {
    when(dashboard.sessionCurrent).thenReturn(_sessionWithFolderMenuCapabilitiesOn(DelegationFixtures.bobAccountId));

    final controller = _newController();

    expect(controller.isDeletedMessageVaultSupported, isTrue);
    expect(controller.isSubAddressingSupported, isTrue);
  });

  test('the folder menu hides the deleted messages vault and subaddressing that only my own account has', () {
    when(dashboard.sessionCurrent).thenReturn(_sessionWithFolderMenuCapabilitiesOn(DelegationFixtures.aliceAccountId));

    final controller = _newController();

    expect(controller.isDeletedMessageVaultSupported, isFalse);
    expect(controller.isSubAddressingSupported, isFalse);
  });

  test('the folder menu offers no filter while a delegated account is shown', () {
    ActiveAccountSourceFixtures.put(DelegationFixtures.session(), shownAccountId: DelegationFixtures.bobAccountId);

    expect(_newController().canCreateFilter, isFalse);
  });

  test('the folder menu offers a filter while my own account is shown', () {
    ActiveAccountSourceFixtures.put(DelegationFixtures.session());

    expect(_newController().canCreateFilter, isTrue);
  });
}

/// Alice is my own account and bob the shown one: only [accountId] gets the deleted messages
/// vault and subaddressing.
Session _sessionWithFolderMenuCapabilitiesOn(AccountId accountId) {
  Account account(AccountId id, String address, {required bool isPersonal}) => Account(
        AccountName(address),
        isPersonal,
        false,
        {
          if (id == accountId) ...{
            capabilityDeletedMessagesVault: DefaultCapability({'restorationHorizon': '15 days'}),
            CapabilityIdentifier.jmapTeamMailboxes: DefaultCapability({'subaddressingSupported': true}),
          },
        },
      );
  final base = DelegationFixtures.session();
  return Session(
    base.capabilities,
    {
      DelegationFixtures.aliceAccountId: account(DelegationFixtures.aliceAccountId, DelegationFixtures.aliceAddress, isPersonal: true),
      DelegationFixtures.bobAccountId: account(DelegationFixtures.bobAccountId, DelegationFixtures.bobAddress, isPersonal: false),
    },
    base.primaryAccounts,
    base.username,
    base.apiUrl,
    base.downloadUrl,
    base.uploadUrl,
    base.eventSourceUrl,
    base.state,
  );
}

final _folder = PresentationMailbox(MailboxId(Id('folder-1')));

SearchMailboxController _newController({
  SubaddressingInteractor? subaddressingInteractor,
  MoveFolderContentInteractor? moveFolderContentInteractor,
}) =>
    SearchMailboxController(
      MockSearchMailboxInteractor(),
      MockRenameMailboxInteractor(),
      MockMoveMailboxInteractor(),
      MockDeleteMultipleMailboxInteractor(),
      MockSubscribeMailboxInteractor(),
      MockSubscribeMultipleMailboxInteractor(),
      MockCreateNewMailboxInteractor(),
      subaddressingInteractor ?? MockSubaddressingInteractor(),
      moveFolderContentInteractor ?? MockMoveFolderContentInteractor(),
      TreeBuilder(),
      VerifyNameInteractor(),
      MockGetAllMailboxInteractor(),
      MockRefreshAllMailboxInteractor(),
    );

Future<BuildContext> _pumpContext(WidgetTester tester) async {
  late BuildContext context;
  await tester.pumpWidget(WidgetFixtures.makeTestableWidget(
    child: Builder(builder: (builderContext) {
      context = builderContext;
      return const SizedBox.shrink();
    }),
  ));
  await tester.pump();
  return context;
}
