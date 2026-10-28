import 'dart:async';
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:http_parser/http_parser.dart';
import 'package:jmap_dart_client/jmap/core/unsigned_int.dart';
import 'package:model/email/attachment.dart';
import 'package:model/email/read_actions.dart';
import 'package:model/email/mark_star_action.dart';
import 'package:email_recovery/email_recovery/email_recovery_action.dart';
import 'package:email_recovery/email_recovery/email_recovery_action_id.dart';
import 'package:tmail_ui_user/features/delegation/domain/model/active_account.dart';
import 'package:tmail_ui_user/features/email/domain/model/mark_read_action.dart';
import 'package:tmail_ui_user/features/email/domain/model/move_action.dart';
import 'package:tmail_ui_user/features/email/domain/state/move_to_mailbox_state.dart';
import 'package:tmail_ui_user/features/email/domain/state/restore_deleted_message_state.dart';
import 'package:tmail_ui_user/features/mailbox/domain/state/create_default_mailbox_state.dart';
import 'package:tmail_ui_user/features/mailbox/domain/state/get_all_mailboxes_state.dart';
import 'package:tmail_ui_user/features/mailbox/domain/state/refresh_changes_all_mailboxes_state.dart';
import 'package:tmail_ui_user/features/mailbox/domain/state/refresh_all_mailboxes_state.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_actions.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/extensions/handle_download_attachment_extension.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/extensions/handle_preview_attachment_extension.dart';
import 'package:tmail_ui_user/features/thread/domain/state/move_multiple_email_to_mailbox_state.dart';
import 'package:tmail_ui_user/features/thread_detail/domain/model/email_in_thread_detail_info.dart';
import 'package:tmail_ui_user/features/thread/presentation/model/delete_action_type.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/app_routes.dart';
import 'package:tmail_ui_user/features/destination_picker/presentation/model/destination_picker_arguments.dart';
import 'package:tmail_ui_user/features/email_recovery/presentation/model/email_recovery_arguments.dart';

import 'package:core/presentation/resources/image_paths.dart';
import 'package:dartz/dartz.dart' show Either, Left, Right;
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart' hide State;
import 'package:fake_async/fake_async.dart';
import 'package:tmail_ui_user/features/email/domain/state/get_restored_deleted_message_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' show UncontrolledProviderScope;
import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/main/exceptions/remote/network_exception.dart';
import 'package:tmail_ui_user/features/email/presentation/action/email_ui_action.dart';
import 'package:tmail_ui_user/features/delegation/presentation/model/shown_account_load.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/account/account.dart';
import 'package:jmap_dart_client/jmap/core/capability/capability_identifier.dart';
import 'package:jmap_dart_client/jmap/core/capability/default_capability.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/core/state.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:labels/model/label.dart';
import 'package:mockito/mockito.dart';
import 'package:model/email/presentation_email.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:core/utils/platform_info.dart';
import 'package:model/email/email_action_type.dart';
import 'package:rxdart/subjects.dart';
import 'package:tmail_ui_user/features/labels/domain/model/open_edit_label_modal_params.dart';
import 'package:tmail_ui_user/features/labels/presentation/models/label_action_type.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/action/mailbox_ui_action.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/extensions/handle_label_action_type_extension.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/mailbox_controller.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_tree_builder.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/utils/labels/label_method_action_define.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/state/quick_search_email_state.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/action/download_ui_action.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/extensions/handle_action_type_for_email_selection.dart';
import 'package:tmail_ui_user/main/utils/ios_sharing_manager.dart';

import 'mailbox_dashboard_controller_test.mocks.dart';

import '../../../../fixtures/active_account_source_fixtures.dart';
import '../../../../fixtures/delegation_fixtures.dart';
import '../../../../fixtures/route_arguments_recorder.dart';
import 'mailbox_dashboard_controller_test_harness.dart';

void main() {
  setUpMailboxDashboardControllerTest();

  group('folders of the shown account:', () {
    void startMailboxController() => mailboxController = newMailboxController()..onInit();

    setUp(() {
      when(emailReceiveManager.pendingSharedFileInfo).thenAnswer((_) => BehaviorSubject.seeded([]));
      when(downloadController.downloadUIAction).thenAnswer((_) => Rxn(DownloadUIAction.idle));
      when(labelController.isLabelSettingEnabled).thenReturn(RxBool(false));
      clearInteractions(getAllMailboxInteractor);
      when(getAllMailboxInteractor.execute(any, any)).thenAnswer((_) => const Stream.empty());
      Get.replace(mailboxDashboardController);
      mailboxDashboardController.sessionCurrent = testSession;
      mailboxDashboardController.accountId.value = null;
    });

    test('loads the folders of my account once, when a new dashboard applies its session', () {
      final session = DelegationFixtures.session();
      mailboxDashboardController.sessionCurrent = session;
      final source = ActiveAccountSourceFixtures.putEmpty();
      startMailboxController();
      verifyNever(getAllMailboxInteractor.execute(any, any));

      source.applySession(session);

      verify(getAllMailboxInteractor.execute(session, DelegationFixtures.aliceAccountId)).called(1);
    });

    test('does not load the folders of a shown account before the dashboard has its session', () {
      mailboxDashboardController.sessionCurrent = null;
      ActiveAccountSourceFixtures.showForThisTest(DelegationFixtures.bobAccountId);

      startMailboxController();

      verifyNever(getAllMailboxInteractor.execute(any, any));
    });

    test('loads the folders of the shown account at once when it starts after the session was applied', () {
      ActiveAccountSourceFixtures.showForThisTest(DelegationFixtures.bobAccountId);

      startMailboxController();

      verify(getAllMailboxInteractor.execute(testSession, DelegationFixtures.bobAccountId)).called(1);
    });

    test('loads the folders of a newly shown account', () {
      final source = ActiveAccountSourceFixtures.putShowing(testAccountId);
      startMailboxController();

      source.show(DelegationFixtures.bobAccountId);

      verify(getAllMailboxInteractor.execute(testSession, DelegationFixtures.bobAccountId)).called(1);
    });

    test('does not reload the folders on a session re-read of the same account', () {
      mailboxDashboardController.sessionCurrent = DelegationFixtures.session();
      final source = ActiveAccountSourceFixtures.put(DelegationFixtures.session());
      startMailboxController();
      clearInteractions(getAllMailboxInteractor);

      source.applySession(DelegationFixtures.session(state: 'state-2'));

      verifyNever(getAllMailboxInteractor.execute(any, any));
    });

    test('the folder menu offers no filter while a delegated account is shown', () {
      ActiveAccountSourceFixtures.put(DelegationFixtures.session(), shownAccountId: DelegationFixtures.bobAccountId);

      expect(newMailboxController().canCreateFilter, isFalse);
    });

    test('the folder menu offers a filter while my own account is shown', () {
      ActiveAccountSourceFixtures.put(DelegationFixtures.session());

      expect(newMailboxController().canCreateFilter, isTrue);
    });

    test('reports the folder load of the shown account with its switch attempt', () {
      final source = ActiveAccountSourceFixtures.putShowing(testAccountId);

      startMailboxController();

      final (kind, load) = source.reportedLoads.single;
      expect(kind, ShownAccountLoadKind.folders);
      expect(load.attemptId, source.currentSwitchAttemptId);
    });

    test('loads the folders of the shown account again when a switch attempt asks for it', () {
      final source = ActiveAccountSourceFixtures.putShowing(testAccountId);
      startMailboxController();
      clearInteractions(getAllMailboxInteractor);

      source.requestReload();

      verify(getAllMailboxInteractor.execute(testSession, testAccountId)).called(1);
    });

    test('a closed MailboxController no longer reloads the folders when a switch attempt asks for it', () {
      final source = ActiveAccountSourceFixtures.putShowing(testAccountId);
      startMailboxController();
      mailboxController.onClose();
      clearInteractions(getAllMailboxInteractor);

      source.requestReload();

      verifyNever(getAllMailboxInteractor.execute(any, any));
    });

    test('the folders of an account shown before never reach the view once another one is shown', () async {
      final myFolders = StreamController<Either<Failure, Success>>();
      addTearDown(myFolders.close);
      when(getAllMailboxInteractor.execute(testSession, testAccountId)).thenAnswer((_) => myFolders.stream);
      final source = ActiveAccountSourceFixtures.putShowing(testAccountId);
      startMailboxController();

      source.show(DelegationFixtures.bobAccountId);
      myFolders.add(Right(GetAllMailboxSuccess(mailboxList: [], currentMailboxState: State('alice-state'))));
      await pumpEventQueue();

      expect(mailboxController.currentMailboxState, isNull);
      expect(await source.reportedLoads.first.$2.result, isA<ShownAccountLoadDropped>());
    });

    for (final switched in [false, true]) {
      testWidgets('Retry on a failed folder load ${switched ? 'does nothing once another account is shown' : 'loads the folders again'}',
          (tester) async {
        await pumpLocalizedApp(tester);
        // Never closed: a stream nobody listens to never completes its close.
        final retry = StreamController<Either<Failure, Success>>();
        when(getAllMailboxInteractor.execute(testSession, testAccountId)).thenAnswer((_) => Stream.value(
            Left(GetAllMailboxFailure(Exception(), onRetry: retry.stream))));
        final source = ActiveAccountSourceFixtures.putShowing(testAccountId);
        clearInteractions(appToast);
        startMailboxController();
        await tester.pump();
        final retryAction = _retryActionOfToast(appToast);

        if (switched) source.show(DelegationFixtures.bobAccountId);
        retryAction();

        expect(retry.hasListener, !switched);
      });
    }

    test('a folder refresh of an account shown before never reaches the view once another one is shown', () async {
      final source = ActiveAccountSourceFixtures.putShowing(testAccountId);
      startMailboxController();
      final myFolders = StreamController<Either<Failure, Success>>();
      addTearDown(myFolders.close);
      when(getAllMailboxInteractor.execute(testSession, testAccountId)).thenAnswer((_) => myFolders.stream);
      await mailboxController.refreshAllMailbox();

      source.show(DelegationFixtures.bobAccountId);
      myFolders.add(Right(GetAllMailboxSuccess(mailboxList: [], currentMailboxState: State('alice-state'))));
      await pumpEventQueue();

      expect(mailboxController.currentMailboxState, isNull);
    });

    test('the folder changes of an account shown before never reach the view once another one is shown', () async {
      final myChanges = StreamController<Either<Failure, Success>>();
      when(refreshAllMailboxInteractor.execute(any, any, any, properties: anyNamed('properties')))
          .thenAnswer((_) => myChanges.stream);
      final source = ActiveAccountSourceFixtures.putShowing(testAccountId);
      startMailboxController();
      mailboxController.currentMailboxState = State('alice-state');
      mailboxDashboardController.dispatchMailboxUIAction(
          RefreshChangeMailboxAction(newState: State('alice-new-state')));
      await pumpEventQueue();

      source.show(DelegationFixtures.bobAccountId);
      myChanges.add(Right(RefreshChangesAllMailboxSuccess(
        mailboxList: [],
        currentMailboxState: State('alice-refreshed-state'),
      )));
      await myChanges.close();
      await pumpEventQueue();

      expect(mailboxController.currentMailboxState, isNull);
    });

    test('a folder change queued before another account is shown never runs once the folder state is cleared', () async {
      final myChanges = StreamController<Either<Failure, Success>>();
      when(refreshAllMailboxInteractor.execute(any, any, any, properties: anyNamed('properties')))
          .thenAnswer((_) => myChanges.stream);
      clearInteractions(refreshAllMailboxInteractor);
      final source = ActiveAccountSourceFixtures.putShowing(testAccountId);
      final controller = newMailboxController()..onInit();
      mailboxController = controller;
      controller.currentMailboxState = State('alice-state');
      mailboxDashboardController.dispatchMailboxUIAction(
          RefreshChangeMailboxAction(newState: State('alice-new-state')));
      await pumpEventQueue();
      mailboxDashboardController.dispatchMailboxUIAction(
          RefreshChangeMailboxAction(newState: State('alice-newer-state')));
      await pumpEventQueue();

      source.show(DelegationFixtures.bobAccountId);
      myChanges.add(Right(RefreshChangesAllMailboxSuccess(
        mailboxList: [],
        currentMailboxState: State('alice-refreshed-state'),
      )));
      await myChanges.close();
      await pumpEventQueue();

      verify(refreshAllMailboxInteractor.execute(any, any, any, properties: anyNamed('properties'))).called(1);
      expect(controller.viewErrors, isEmpty);
      expect(controller.currentMailboxState, isNull);
    });

    for (final switched in [false, true]) {
      testWidgets('a failed folder changes refresh ${switched ? 'of an account shown before shows no error' : 'shows its error'}',
          (tester) async {
        PlatformInfo.isTestingForWeb = true;
        addTearDown(() => PlatformInfo.isTestingForWeb = false);
        await pumpLocalizedApp(tester);
        final myChanges = StreamController<Either<Failure, Success>>();
        when(refreshAllMailboxInteractor.execute(any, any, any, properties: anyNamed('properties')))
            .thenAnswer((_) => myChanges.stream);
        final source = ActiveAccountSourceFixtures.putShowing(testAccountId);
        startMailboxController();
        mailboxController.currentMailboxState = State('alice-state');
        mailboxDashboardController.dispatchMailboxUIAction(
            RefreshChangeMailboxAction(newState: State('alice-new-state')));
        await tester.pump();
        clearInteractions(appToast);

        if (switched) source.show(DelegationFixtures.bobAccountId);
        myChanges.addError(const ConnectionError());
        await myChanges.close();
        await tester.pump();

        if (switched) {
          verifyNever(appToast.showToastErrorMessage(any, any));
        } else {
          verify(appToast.showToastErrorMessage(any, any)).called(1);
        }
      });
    }

    test('the folders of the account shown before are cleared once another one is shown', () {
      final source = ActiveAccountSourceFixtures.putShowing(testAccountId);
      startMailboxController();
      final aliceInbox = PresentationMailbox(MailboxId(Id('alice-inbox')));
      mailboxController.allMailboxes = [aliceInbox];
      mailboxController.currentMailboxState = State('alice-state');
      mailboxDashboardController.setMapMailboxById({aliceInbox.id: aliceInbox});

      source.show(DelegationFixtures.bobAccountId);

      expect(mailboxController.allMailboxes, isEmpty);
      expect(mailboxController.currentMailboxState, isNull);
      expect(mailboxDashboardController.mapMailboxById, isEmpty);
    });

    test('a reload of the account still shown keeps its folders on screen while they load', () {
      final source = ActiveAccountSourceFixtures.putShowing(testAccountId);
      startMailboxController();
      final aliceInbox = PresentationMailbox(MailboxId(Id('alice-inbox')));
      mailboxController.allMailboxes = [aliceInbox];

      source.requestReload();

      expect(mailboxController.allMailboxes, [aliceInbox]);
    });

    testWidgets('moving a folder opens the folder picker on the shown account, not on my own', (tester) async {
      mailboxDashboardController.accountId.value = testAccountId;
      ActiveAccountSourceFixtures.showForThisTest(DelegationFixtures.bobAccountId);
      startMailboxController();
      final recorder = await RouteArgumentsRecorder.pump(tester, AppRoutes.destinationPicker);

      mailboxController.handleMailboxAction(
        recorder.context,
        MailboxActions.move,
        PresentationMailbox(MailboxId(Id('folder-1'))),
      );
      await tester.pumpAndSettle();

      expect((recorder.arguments as DestinationPickerArguments).accountId, DelegationFixtures.bobAccountId);
    });

    testWidgets('disallowing subaddressing changes the folder of the shown account, not of my own', (tester) async {
      clearInteractions(subaddressingInteractor);
      when(subaddressingInteractor.execute(any, any, any)).thenAnswer((_) => const Stream.empty());
      mailboxDashboardController.accountId.value = testAccountId;
      ActiveAccountSourceFixtures.showForThisTest(DelegationFixtures.bobAccountId);
      startMailboxController();
      await pumpLocalizedApp(tester);

      mailboxController.handleMailboxAction(
        Get.context!,
        MailboxActions.disallowSubaddressing,
        PresentationMailbox(MailboxId(Id('folder-1'))),
      );

      verify(subaddressingInteractor.execute(any, DelegationFixtures.bobAccountId, any)).called(1);
    });

    group('default folders missing after the folders load:', () {
      setUp(() {
        clearInteractions(createDefaultMailboxInteractor);
        when(uuid.v1()).thenReturn('default-folder-id');
        // A real request ends with a state, so onDone does not see the folders load again.
        when(createDefaultMailboxInteractor.execute(any, any, any))
            .thenAnswer((_) => Stream.value(Left(CreateDefaultMailboxFailure(null))));
        mailboxDashboardController.sessionCurrent = DelegationFixtures.session();
      });

      Future<void> loadFoldersShowing(AccountId? shownAccountId) async {
        when(getAllMailboxInteractor.execute(any, any)).thenAnswer((_) => Stream.value(Right(GetAllMailboxSuccess(
              mailboxList: [PresentationMailbox(MailboxId(Id('folder-1')), name: MailboxName('Folder'))],
              currentMailboxState: State('mailbox-state'),
            ))));
        ActiveAccountSourceFixtures.put(DelegationFixtures.session(), shownAccountId: shownAccountId);
        // A real tree, so the loaded folders go through the same path as in the app.
        mailboxController = newMailboxController(mailboxTreeBuilder: TreeBuilder())..onInit();
        mailboxDashboardController.accountId.value = DelegationFixtures.aliceAccountId;
        await pumpEventQueue();
        expect(mailboxDashboardController.refreshingAllMailboxState.value, Right(RefreshAllMailboxSuccess()));
      }

      test('are created in my own account', () async {
        await loadFoldersShowing(null);

        verify(createDefaultMailboxInteractor.execute(any, DelegationFixtures.aliceAccountId, any)).called(1);
      });

      test('are not created in a delegated account', () async {
        await loadFoldersShowing(DelegationFixtures.bobAccountId);

        verifyNever(createDefaultMailboxInteractor.execute(any, any, any));
      });

      group('on iOS:', () {
        late MockIOSSharingManager iosSharingManager;

        setUp(() {
          debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
          addTearDown(() => debugDefaultTargetPlatformOverride = null);
          iosSharingManager = MockIOSSharingManager();
          when(iosSharingManager.isExistMailboxIdsBlockNotificationInKeyChain(any)).thenAnswer((_) async => true);
          Get.put<IOSSharingManager>(iosSharingManager);
          addTearDown(() => Get.delete<IOSSharingManager>());
        });

        test('the notification keychain gets the folders of my own account', () async {
          await loadFoldersShowing(null);

          verify(iosSharingManager.isExistMailboxIdsBlockNotificationInKeyChain(DelegationFixtures.aliceAccountId))
              .called(1);
        });

        test('the notification keychain never gets the folders of a delegated account', () async {
          await loadFoldersShowing(DelegationFixtures.bobAccountId);

          verifyZeroInteractions(iosSharingManager);
        });
      });
    });

    test('a closed MailboxController no longer loads the folders of a newly shown account', () {
      final source = ActiveAccountSourceFixtures.putShowing(testAccountId);
      startMailboxController();
      mailboxController.onClose();

      source.show(DelegationFixtures.bobAccountId);

      verifyNever(getAllMailboxInteractor.execute(any, DelegationFixtures.bobAccountId));
    });
  });

  group('session setup:', () {
    setUp(() {
      when(emailReceiveManager.pendingSharedFileInfo).thenAnswer((_) => BehaviorSubject.seeded([]));
      when(downloadController.downloadUIAction).thenAnswer((_) => Rxn(DownloadUIAction.idle));
      when(labelController.isLabelSettingEnabled).thenReturn(RxBool(false));
    });

    test('a new dashboard shows my account of the session it sets up', () {
      ActiveAccountSourceFixtures.put(DelegationFixtures.session(username: 'someone@else.tld'));

      mailboxDashboardController.handleReloaded(DelegationFixtures.session());

      expect(mailboxDashboardController.activeAccountSource.activeAccount,
          ActiveAccount.personal(DelegationFixtures.session()));
    });

    test('a new dashboard starts without the account shown before', () {
      final source = ActiveAccountSourceFixtures.put(
        DelegationFixtures.session(),
        shownAccountId: DelegationFixtures.bobAccountId,
      );

      Get.put(mailboxDashboardController);

      expect(source.activeAccount, isNull);
    });

    testWidgets('a new dashboard started while its route builds does not modify a provider during the build',
        (tester) async {
      final container = ActiveAccountSourceFixtures.newContainer();
      ActiveAccountSourceFixtures.put(
        DelegationFixtures.session(),
        shownAccountId: DelegationFixtures.bobAccountId,
        container: container,
      );

      await tester.pumpWidget(UncontrolledProviderScope(
        container: container,
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: Builder(builder: (_) {
            // GetPage runs its bindings while the route builds, and Get.put calls onInit at once.
            Get.put(mailboxDashboardController);
            return const SizedBox();
          }),
        ),
      ));

      expect(tester.takeException(), isNull);
    });

    test('a reader put by the bindings of a new dashboard never loads the account shown before', () {
      clearInteractions(getAllMailboxInteractor);
      when(getAllMailboxInteractor.execute(any, any)).thenAnswer((_) => const Stream.empty());
      // MailboxDashBoardBindings registers the dashboard, then MailboxController, whose field
      // initializer finds the dashboard and so runs its onInit first.
      Get.lazyPut(() => mailboxDashboardController);
      mailboxDashboardController.sessionCurrent = DelegationFixtures.session();
      final source = ActiveAccountSourceFixtures.put(
        DelegationFixtures.session(),
        shownAccountId: DelegationFixtures.bobAccountId,
      );

      mailboxController = Get.put(newMailboxController());
      addTearDown(() => Get.delete<MailboxController>(force: true));

      verifyNever(getAllMailboxInteractor.execute(any, any));

      source.applySession(DelegationFixtures.session());

      verify(getAllMailboxInteractor.execute(any, DelegationFixtures.aliceAccountId)).called(1);
      verifyNever(getAllMailboxInteractor.execute(any, DelegationFixtures.bobAccountId));
    });

    test('a reader loads the shown account only once the dashboard holds my account and own address', () {
      final source = ActiveAccountSourceFixtures.putEmpty();
      mailboxDashboardController.accountId.value = null;
      mailboxDashboardController.ownEmailAddress.value = '';
      final dashboardStateOnLoad = <(AccountId?, String)>[];
      addTearDown(source.watchShown((_) => dashboardStateOnLoad.add((
            mailboxDashboardController.accountId.value,
            mailboxDashboardController.ownEmailAddress.value,
          ))));

      mailboxDashboardController.handleReloaded(DelegationFixtures.session());

      expect(dashboardStateOnLoad, [(DelegationFixtures.aliceAccountId, DelegationFixtures.aliceAddress)]);
    });
  });

  group('restored messages polling:', () {
    setUp(() {
      mailboxDashboardController.sessionCurrent = testSession;
      clearInteractions(getRestoredDeletedMessageInteractor);
      when(getRestoredDeletedMessageInteractor.execute(any, any, any)).thenAnswer((_) => const Stream.empty());
    });

    test('stops once a logout cleared the shown account', () {
      ActiveAccountSourceFixtures.putShowing(null);

      mailboxDashboardController.handleSuccessViewState(RestoreDeletedMessageSuccess(
          EmailRecoveryAction(id: EmailRecoveryActionId(Id('recovery-1'))), testAccountId));

      verifyNever(getRestoredDeletedMessageInteractor.execute(any, any, any));
    });

    test('polls the account the restore started on, even once another account is shown', () {
      ActiveAccountSourceFixtures.putShowing(DelegationFixtures.carolAccountId);

      mailboxDashboardController.handleSuccessViewState(RestoreDeletedMessageSuccess(
          EmailRecoveryAction(id: EmailRecoveryActionId(Id('recovery-1'))),
          DelegationFixtures.bobAccountId));

      verify(getRestoredDeletedMessageInteractor.execute(any, DelegationFixtures.bobAccountId, any))
          .called(1);
    });

    for (final (shownAccountId, refreshes) in [
      (DelegationFixtures.bobAccountId, true),
      (DelegationFixtures.carolAccountId, false),
    ]) {
      test('a restore polled on bob ${refreshes ? 'refreshes' : 'does not refresh'} the restored messages '
          'folder while ${shownAccountId.id.value} is shown', () {
        ActiveAccountSourceFixtures.putShowing(shownAccountId);
        mailboxDashboardController.selectedMailbox.value =
            PresentationMailbox(MailboxId(Id('restored')), role: PresentationMailbox.roleRecovered);
        mailboxDashboardController.emailUIAction.value = null;

        mailboxDashboardController.handleSuccessViewState(GetRestoredDeletedMessageInProgress(
          EmailRecoveryAction(id: EmailRecoveryActionId(Id('recovery-1'))),
          DelegationFixtures.bobAccountId,
        ));

        expect(mailboxDashboardController.emailUIAction.value, refreshes ? isA<RefreshChangeEmailAction>() : isNull);
      });
    }

    for (final (shownAccountId, offersOpen) in [
      (DelegationFixtures.bobAccountId, true),
      (DelegationFixtures.carolAccountId, false),
    ]) {
      testWidgets('a restore finished on bob ${offersOpen ? 'offers' : 'offers no'} button to open its folder '
          'while ${shownAccountId.id.value} is shown', (tester) async {
        await pumpLocalizedApp(tester);
        clearInteractions(appToast);
        ActiveAccountSourceFixtures.putShowing(shownAccountId);

        mailboxDashboardController.handleSuccessViewState(GetRestoredDeletedMessageCompleted(
          EmailRecoveryAction(id: EmailRecoveryActionId(Id('recovery-1'))),
          DelegationFixtures.bobAccountId,
          recoveredMailbox: Mailbox(id: MailboxId(Id('bob-restored'))),
        ));

        if (offersOpen) {
          verify(_showToastWithAction(appToast)).called(1);
          verifyNever(appToast.showToastSuccessMessage(any, any));
        } else {
          verifyNever(_showToastWithAction(appToast));
          verify(appToast.showToastSuccessMessage(any, any)).called(1);
        }
      });
    }

    for (final switched in [false, true]) {
      testWidgets('Open on a restore finished on bob ${switched ? 'does nothing once carol is shown' : 'opens its folder'}',
          (tester) async {
        await pumpLocalizedApp(tester);
        clearInteractions(appToast);
        final source = ActiveAccountSourceFixtures.putShowing(DelegationFixtures.bobAccountId);
        mailboxDashboardController.mailboxUIAction.value = null;
        mailboxDashboardController.handleSuccessViewState(GetRestoredDeletedMessageCompleted(
          EmailRecoveryAction(id: EmailRecoveryActionId(Id('recovery-1'))),
          DelegationFixtures.bobAccountId,
          recoveredMailbox: Mailbox(id: MailboxId(Id('bob-restored'))),
        ));
        final open = verify(appToast.showToastMessage(
          any,
          any,
          actionName: anyNamed('actionName'),
          onActionClick: captureAnyNamed('onActionClick'),
          actionIcon: anyNamed('actionIcon'),
          leadingSVGIcon: anyNamed('leadingSVGIcon'),
          leadingSVGIconColor: anyNamed('leadingSVGIconColor'),
          backgroundColor: anyNamed('backgroundColor'),
          textColor: anyNamed('textColor'),
        )).captured.single as Function;

        if (switched) source.show(DelegationFixtures.carolAccountId);
        open();

        final action = mailboxDashboardController.mailboxUIAction.value;
        if (switched) {
          expect(action, isNull);
        } else {
          expect((action as OpenMailboxAction).presentationMailbox.id, MailboxId(Id('bob-restored')));
        }
      });
    }

    test('keeps polling the account the restore started on while it is in progress', () {
      ActiveAccountSourceFixtures.putShowing(DelegationFixtures.carolAccountId);
      final recoveryAction = EmailRecoveryAction(id: EmailRecoveryActionId(Id('recovery-1')));

      fakeAsync((async) {
        mailboxDashboardController.handleSuccessViewState(
            GetRestoredDeletedMessageInProgress(recoveryAction, DelegationFixtures.bobAccountId));
        async.elapse(const Duration(seconds: 2));
      });

      verify(getRestoredDeletedMessageInteractor.execute(any, DelegationFixtures.bobAccountId, any))
          .called(1);
    });
  });

  group('empty spam folder:', () {
    setUp(() {
      mailboxDashboardController.sessionCurrent = testSession;
      mailboxDashboardController.accountId.value = testAccountId;
      clearInteractions(emptySpamFolderInteractor);
      clearInteractions(clearMailboxInteractor);
    });

    test('never falls back to my own account once a logout cleared the shown account', () {
      ActiveAccountSourceFixtures.putShowing(null);

      mailboxDashboardController.emptySpamFolderAction(spamFolderId: MailboxId(Id('spam')), totalEmails: 2);

      verifyNever(emptySpamFolderInteractor.execute(any, any, any, any, any));
      verifyNever(clearMailboxInteractor.execute(any, any, any, any));
    });
  });

  group('readers of the shown account:', () {
    final bob = DelegationFixtures.bobAccountId;
    final destinationId = MailboxId(Id('destination'));
    final email = PresentationEmail(
      id: EmailId(Id('email-1')),
      mailboxIds: {testMailboxId: true},
      mailboxContain: PresentationMailbox(testMailboxId),
    );

    void stubInteractorsWithEmptyStreams() {
      when(deleteEmailPermanentlyInteractor.execute(any, any, any, any)).thenAnswer((_) => const Stream.empty());
      when(deleteMultipleEmailsPermanentlyInteractor.execute(any, any, any, any))
          .thenAnswer((_) => const Stream.empty());
      when(markAsEmailReadInteractor.execute(any, any, any, any, any, any)).thenAnswer((_) => const Stream.empty());
      when(markAsStarEmailInteractor.execute(any, any, any, any)).thenAnswer((_) => const Stream.empty());
      when(markAsMultipleEmailReadInteractor.execute(any, any, any, any, any)).thenAnswer((_) => const Stream.empty());
      when(markAsStarMultipleEmailInteractor.execute(any, any, any, any)).thenAnswer((_) => const Stream.empty());
      when(markAsMailboxReadInteractor.execute(any, any, any, any, any, any)).thenAnswer((_) => const Stream.empty());
      when(moveToMailboxInteractor.execute(any, any, any, any)).thenAnswer((_) => const Stream.empty());
      when(moveMultipleEmailToMailboxInteractor.execute(any, any, any, any)).thenAnswer((_) => const Stream.empty());
      when(unsubscribeEmailInteractor.execute(any, any, any)).thenAnswer((_) => const Stream.empty());
      when(restoreDeletedMessageInteractor.execute(any, any, any)).thenAnswer((_) => const Stream.empty());
      when(getRestoredDeletedMessageInteractor.execute(any, any, any)).thenAnswer((_) => const Stream.empty());
      when(emptySpamFolderInteractor.execute(any, any, any, any, any)).thenAnswer((_) => const Stream.empty());
      when(clearMailboxInteractor.execute(any, any, any, any)).thenAnswer((_) => const Stream.empty());
    }

    setUp(() {
      mailboxDashboardController.sessionCurrent = testSession;
      mailboxDashboardController.accountId.value = testAccountId;
      mailboxDashboardController.selectedMailbox.value = PresentationMailbox(
        testMailboxId,
        unreadEmails: UnreadEmails(UnsignedInt(3)),
      );
      mailboxDashboardController.setMapDefaultMailboxIdByRole({
        PresentationMailbox.roleSpam: MailboxId(Id('spam')),
        PresentationMailbox.roleInbox: MailboxId(Id('inbox')),
        PresentationMailbox.roleArchive: MailboxId(Id('archive')),
        PresentationMailbox.roleTrash: MailboxId(Id('trash')),
      });
      mailboxDashboardController.mapMailboxById = {
        testMailboxId: PresentationMailbox(testMailboxId),
      };
      ActiveAccountSourceFixtures.putShowing(bob);
      clearInteractions(appToast);
      for (final interactor in [
        deleteEmailPermanentlyInteractor,
        deleteMultipleEmailsPermanentlyInteractor,
        markAsEmailReadInteractor,
        markAsStarEmailInteractor,
        markAsMultipleEmailReadInteractor,
        markAsStarMultipleEmailInteractor,
        markAsMailboxReadInteractor,
        moveToMailboxInteractor,
        moveMultipleEmailToMailboxInteractor,
        unsubscribeEmailInteractor,
        restoreDeletedMessageInteractor,
        getRestoredDeletedMessageInteractor,
        emptySpamFolderInteractor,
        clearMailboxInteractor,
        spamReportController,
        downloadAttachmentForWebInteractor,
        parseEmailByBlobIdInteractor,
      ]) {
        clearInteractions(interactor);
      }
      when(spamReportController.enableSpamReport).thenReturn(true);
      when(downloadController.uuid).thenReturn(uuid);
      when(uuid.v4()).thenReturn('task-1');
      when(downloadController.dynamicUrlInterceptors).thenReturn(dynamicUrlInterceptors);
      when(downloadController.downloadAttachmentForWebInteractor).thenReturn(downloadAttachmentForWebInteractor);
      when(downloadController.parseEmailByBlobIdInteractor).thenReturn(parseEmailByBlobIdInteractor);
      when(downloadAttachmentForWebInteractor.execute(
        any,
        any,
        any,
        any,
        onReceiveController: anyNamed('onReceiveController'),
        cancelToken: anyNamed('cancelToken'),
        previewerSupported: anyNamed('previewerSupported'),
        sourceView: anyNamed('sourceView'),
      )).thenAnswer((_) => const Stream.empty());
      when(parseEmailByBlobIdInteractor.execute(any, any, any, any)).thenAnswer((_) => const Stream.empty());
      stubInteractorsWithEmptyStreams();
    });

    /// Runs [act] in a localized app, then taps the undo action of the move toast it shows.
    Future<void> undoMove(WidgetTester tester, Success moveSuccess) async {
      await pumpLocalizedApp(tester);
      mailboxDashboardController.handleSuccessViewState(moveSuccess);
      final undo = verify(appToast.showToastMessage(
        any,
        any,
        actionName: anyNamed('actionName'),
        onActionClick: captureAnyNamed('onActionClick'),
        actionIcon: anyNamed('actionIcon'),
        leadingSVGIcon: anyNamed('leadingSVGIcon'),
        leadingSVGIconColor: anyNamed('leadingSVGIconColor'),
        backgroundColor: anyNamed('backgroundColor'),
        textColor: anyNamed('textColor'),
      )).captured.single as Function;
      undo();
    }

    void expectDownloadInShownAccount() => verify(downloadAttachmentForWebInteractor.execute(
          any,
          any,
          bob,
          any,
          onReceiveController: anyNamed('onReceiveController'),
          cancelToken: anyNamed('cancelToken'),
          previewerSupported: anyNamed('previewerSupported'),
          sourceView: anyNamed('sourceView'),
        )).called(1);

    final interactorReaders = <({
      String name,
      Future<void> Function(WidgetTester tester) act,
      void Function() expectShownAccount,
    })>[
      (
        name: 'deleteEmailPermanently',
        act: (_) async => mailboxDashboardController.deleteEmailPermanently(email),
        expectShownAccount: () => verify(deleteEmailPermanentlyInteractor.execute(any, bob, any, any)).called(1),
      ),
      (
        name: 'markAsEmailRead',
        act: (_) async => mailboxDashboardController.markAsEmailRead(
            email.id!, ReadActions.markAsRead, MarkReadAction.tap, testMailboxId),
        expectShownAccount: () =>
            verify(markAsEmailReadInteractor.execute(any, bob, any, any, any, any)).called(1),
      ),
      (
        name: 'markAsStarEmail',
        act: (_) async => mailboxDashboardController.markAsStarEmail(email, MarkStarAction.markStar),
        expectShownAccount: () => verify(markAsStarEmailInteractor.execute(any, bob, any, any)).called(1),
      ),
      (
        name: 'markAsReadSelectedMultipleEmail',
        act: (_) async =>
            mailboxDashboardController.markAsReadSelectedMultipleEmail([email], ReadActions.markAsRead),
        expectShownAccount: () =>
            verify(markAsMultipleEmailReadInteractor.execute(any, bob, any, any, any)).called(1),
      ),
      (
        name: 'markAsStarSelectedMultipleEmail',
        act: (_) async =>
            mailboxDashboardController.markAsStarSelectedMultipleEmail([email], MarkStarAction.markStar),
        expectShownAccount: () => verify(markAsStarMultipleEmailInteractor.execute(any, bob, any, any)).called(1),
      ),
      (
        name: 'dragging emails to the favorite folder',
        act: (_) async => mailboxDashboardController.dragSelectedMultipleEmailToMailboxAction(
            [email], PresentationMailbox(destinationId, role: PresentationMailbox.roleFavorite)),
        expectShownAccount: () => verify(markAsStarMultipleEmailInteractor.execute(any, bob, any, any)).called(1),
      ),
      for (final role in [PresentationMailbox.roleTrash, PresentationMailbox.roleSpam, null])
        (
          name: 'dragging an email to the ${role?.value ?? 'other'} folder',
          act: (_) async => mailboxDashboardController.dragSelectedMultipleEmailToMailboxAction(
              [email], PresentationMailbox(destinationId, role: role)),
          expectShownAccount: () => verify(moveToMailboxInteractor.execute(any, bob, any, any)).called(1),
        ),
      (
        name: 'archiveMessage',
        act: (_) async => mailboxDashboardController.archiveMessage(email),
        expectShownAccount: () => verify(moveToMailboxInteractor.execute(any, bob, any, any)).called(1),
      ),
      (
        name: 'undoing the move of an email',
        act: (tester) => undoMove(
          tester,
          MoveToMailboxSuccess(
            email.id!,
            testMailboxId,
            destinationId,
            MoveAction.moving,
            EmailActionType.moveToMailbox,
            originalMailboxIdsWithEmailIds: {testMailboxId: [email.id!]},
            emailIdsWithReadStatus: {email.id!: false},
          ),
        ),
        expectShownAccount: () => verify(moveToMailboxInteractor.execute(any, bob, any, any)).called(1),
      ),
      (
        name: 'undoing the move of selected emails',
        act: (tester) => undoMove(
          tester,
          MoveMultipleEmailToMailboxAllSuccess(
            [email.id!],
            destinationId,
            MoveAction.moving,
            EmailActionType.moveToMailbox,
            originalMailboxIdsWithEmailIds: {testMailboxId: [email.id!]},
            emailIdsWithReadStatus: {email.id!: false},
          ),
        ),
        expectShownAccount: () =>
            verify(moveMultipleEmailToMailboxInteractor.execute(any, bob, any, any)).called(1),
      ),
      (
        name: 'unSpamSelectedMultipleEmail',
        act: (_) async => mailboxDashboardController.unSpamSelectedMultipleEmail([email]),
        expectShownAccount: () =>
            verify(moveMultipleEmailToMailboxInteractor.execute(any, bob, any, any)).called(1),
      ),
      (
        name: 'moveMultipleEmailInThreadDetail',
        act: (_) async => mailboxDashboardController.moveMultipleEmailInThreadDetail(
          [
            EmailInThreadDetailInfo(
              emailId: email.id!,
              keywords: null,
              mailboxIds: {testMailboxId: true},
              isValidToDisplay: true,
            ),
          ],
          destinationMailboxId: destinationId,
          emailActionType: EmailActionType.moveToMailbox,
        ),
        expectShownAccount: () =>
            verify(moveMultipleEmailToMailboxInteractor.execute(any, bob, any, any)).called(1),
      ),
      (
        name: 'deleting the selected emails permanently',
        act: (tester) async {
          await pumpLocalizedApp(tester);
          mailboxDashboardController.deleteSelectionEmailsPermanently(
            Get.context!,
            DeleteActionType.multiple,
            listEmails: [email],
          );
          await tester.pumpAndSettle();
          await tester.tap(find.text(AppLocalizations.of(Get.context!).delete).last);
          await tester.pumpAndSettle();
        },
        expectShownAccount: () =>
            verify(deleteMultipleEmailsPermanentlyInteractor.execute(any, bob, any, any)).called(1),
      ),
      (
        name: 'markAsReadMailboxAction',
        act: (tester) async {
          await pumpLocalizedApp(tester);
          mailboxDashboardController.markAsReadMailboxAction(Get.context!);
        },
        expectShownAccount: () =>
            verify(markAsMailboxReadInteractor.execute(any, bob, any, any, any, any)).called(1),
      ),
      (
        name: 'moving emails to the trash from a virtual folder',
        act: (_) async {
          mailboxDashboardController.selectedMailbox.value =
              PresentationMailbox(destinationId, role: PresentationMailbox.roleFavorite);
          mailboxDashboardController.moveEmailsToFolder([email], EmailActionType.moveToTrash);
        },
        expectShownAccount: () =>
            verify(moveMultipleEmailToMailboxInteractor.execute(any, bob, any, any)).called(1),
      ),
      (
        name: 'downloadMessageAsEML',
        act: (_) async => mailboxDashboardController.downloadMessageAsEML(
            presentationEmail: PresentationEmail(id: email.id, blobId: Id('blob-1'))),
        expectShownAccount: expectDownloadInShownAccount,
      ),
      (
        name: 'downloadAttachment',
        act: (_) async {
          PlatformInfo.isTestingForWeb = true;
          addTearDown(() => PlatformInfo.isTestingForWeb = false);
          mailboxDashboardController.downloadAttachment(attachment: Attachment(blobId: Id('blob-1')));
        },
        expectShownAccount: expectDownloadInShownAccount,
      ),
      (
        name: 'previewAttachment of an EML file',
        act: (tester) async {
          final recorder = await RouteArgumentsRecorder.pump(tester, AppRoutes.emailEMLPreviewer);
          mailboxDashboardController.previewAttachment(
            context: recorder.context,
            attachment: Attachment(blobId: Id('blob-1'), type: MediaType('message', 'rfc822')),
            onPreviewOrDownloadAction: (_, __) {},
          );
          // The loading dialog it opens stays for a least loading time and waits for the parse
          // result, which never comes here.
          await tester.pump(SmartDialog.config.loading.leastLoadingTime);
          unawaited(SmartDialog.dismiss());
          await tester.pump(const Duration(seconds: 1));
        },
        expectShownAccount: () => verify(parseEmailByBlobIdInteractor.execute(bob, any, any, any)).called(1),
      ),
      (
        name: 'refreshSpamReportBanner',
        act: (_) async => mailboxDashboardController.refreshSpamReportBanner(),
        expectShownAccount: () => verify(spamReportController.getSpamMailboxCached(bob, any)).called(1),
      ),
      (
        name: 'unsubscribeMail',
        act: (_) async => mailboxDashboardController.unsubscribeMail(email.id!),
        expectShownAccount: () => verify(unsubscribeEmailInteractor.execute(any, bob, any)).called(1),
      ),
      (
        name: 'emptySpamFolderAction without Mailbox/clear',
        act: (_) async => mailboxDashboardController.emptySpamFolderAction(totalEmails: 2),
        expectShownAccount: () =>
            verify(emptySpamFolderInteractor.execute(any, bob, MailboxId(Id('spam')), 2, any)).called(1),
      ),
      (
        name: 'emptySpamFolderAction with Mailbox/clear in the shown account only',
        act: (_) async {
          mailboxDashboardController.sessionCurrent = Session(
            {},
            {
              testAccountId: Account(AccountName('me'), true, false, {}),
              bob: Account(AccountName('bob'), false, false, {
                CapabilityIdentifier.jmapMailboxClear: DefaultCapability(<String, dynamic>{}),
              }),
            },
            {},
            UserName('data'),
            google,
            google,
            google,
            google,
            State('1'),
          );
          mailboxDashboardController.emptySpamFolderAction();
        },
        expectShownAccount: () => verify(clearMailboxInteractor.execute(
              any,
              bob,
              MailboxId(Id('spam')),
              PresentationMailbox.roleSpam,
            )).called(1),
      ),
      (
        name: 'handleRestoreEmailAction',
        act: (_) async => mailboxDashboardController.handleRestoreEmailAction(EmailRecoveryAction()),
        expectShownAccount: () => verify(restoreDeletedMessageInteractor.execute(any, bob, any)).called(1),
      ),
      (
        name: 'polling the restored messages',
        act: (_) async => mailboxDashboardController.handleSuccessViewState(RestoreDeletedMessageSuccess(
            EmailRecoveryAction(id: EmailRecoveryActionId(Id('recovery-1'))), bob)),
        expectShownAccount: () => verify(getRestoredDeletedMessageInteractor.execute(any, bob, any)).called(1),
      ),
    ];

    for (final reader in interactorReaders) {
      testWidgets('${reader.name} acts on the shown account, not on my own', (tester) async {
        await reader.act(tester);

        reader.expectShownAccount();
      });
    }

    final pickerReaders = <({String name, String route, Future<void> Function() open, AccountId? Function(Object?) accountIdOf})>[
      (
        name: 'moveEmailsToMailbox',
        route: AppRoutes.destinationPicker,
        open: () => mailboxDashboardController.moveEmailsToMailbox([email]),
        accountIdOf: (arguments) => (arguments as DestinationPickerArguments).accountId,
      ),
      (
        name: 'selectFolderSearchFilter',
        route: AppRoutes.destinationPicker,
        open: () => mailboxDashboardController.selectFolderSearchFilter(),
        accountIdOf: (arguments) => (arguments as DestinationPickerArguments).accountId,
      ),
      (
        name: 'gotoEmailRecovery',
        route: AppRoutes.emailRecovery,
        open: () async => mailboxDashboardController.gotoEmailRecovery(),
        accountIdOf: (arguments) => (arguments as EmailRecoveryArguments).accountId,
      ),
    ];

    for (final reader in pickerReaders) {
      testWidgets('${reader.name} opens its page on the shown account, not on my own', (tester) async {
        final recorder = await RouteArgumentsRecorder.pump(tester, reader.route);

        unawaited(reader.open());
        await tester.pumpAndSettle();

        expect(reader.accountIdOf(recorder.arguments), bob);
      });
    }

    testWidgets('moveEmailsToMailbox moves the emails in the shown account once a folder is picked', (tester) async {
      await RouteArgumentsRecorder.pump(tester, AppRoutes.destinationPicker);

      unawaited(mailboxDashboardController.moveEmailsToMailbox([email]));
      await tester.pumpAndSettle();
      Get.back(result: PresentationMailbox(destinationId));
      await tester.pumpAndSettle();

      verify(moveMultipleEmailToMailboxInteractor.execute(any, bob, any, any)).called(1);
    });

    test('currentAccountId of the label mixins is the shown account', () {
      expect(mailboxDashboardController.currentAccountId, bob);
    });
  });

  group('shown account:', () {
    setUp(() {
      mailboxDashboardController.sessionCurrent = testSession;
      mailboxDashboardController.accountId.value = testAccountId;
      ActiveAccountSourceFixtures.putShowing(DelegationFixtures.bobAccountId);
      when(quickSearchEmailInteractor.execute(
        any,
        any,
        limit: anyNamed('limit'),
        sort: anyNamed('sort'),
        filter: anyNamed('filter'),
        properties: anyNamed('properties'),
      )).thenAnswer((_) async => Right(QuickSearchEmailSuccess(const [])));
    });

    test('quickSearchEmails searches the shown account, not my own', () async {
      await mailboxDashboardController.quickSearchEmails('invoice');

      verify(quickSearchEmailInteractor.execute(
        any,
        DelegationFixtures.bobAccountId,
        limit: anyNamed('limit'),
        sort: anyNamed('sort'),
        filter: anyNamed('filter'),
        properties: anyNamed('properties'),
      )).called(1);
    });

    test('moveEmailsToFolder moves the selected emails in the shown account', () {
      when(moveMultipleEmailToMailboxInteractor.execute(any, any, any, any))
          .thenAnswer((_) => const Stream.empty());
      mailboxDashboardController.selectedMailbox.value = PresentationMailbox(testMailboxId);

      mailboxDashboardController.moveEmailsToFolder(
        [PresentationEmail(id: EmailId(Id('email-1')))],
        EmailActionType.moveToMailbox,
        selectedMailboxId: MailboxId(Id('destination')),
      );

      verify(moveMultipleEmailToMailboxInteractor.execute(
        any,
        DelegationFixtures.bobAccountId,
        any,
        any,
      )).called(1);
    });

    test('editing a label from its menu edits it in the shown account', () async {
      when(labelController.openLabelMenuAction(any, any, any, any, position: anyNamed('position')))
          .thenAnswer((invocation) async {
        final onLabelActionType = invocation.positionalArguments[3] as OnLabelActionTypeCallback;
        onLabelActionType(invocation.positionalArguments[2] as Label, LabelActionType.edit);
      });
      when(labelController.openEditLabelModal(params: anyNamed('params')))
          .thenAnswer((_) async => null);

      await mailboxDashboardController.openLabelPopupMenuAction(
        _FakeBuildContext(),
        ImagePaths(),
        Label(id: Id('label-1'), displayName: 'Work'),
        RelativeRect.fill,
      );

      final params = verify(labelController.openEditLabelModal(params: captureAnyNamed('params')))
          .captured
          .single as OpenEditLabelModalParams;
      expect(params.accountId, DelegationFixtures.bobAccountId);
    });
  });
}

class _FakeBuildContext extends Fake implements BuildContext {}

Function _retryActionOfToast(MockAppToast appToast) {
  final actions = verify(appToast.showToastMessageWithMultipleActions(
    any,
    any,
    actions: captureAnyNamed('actions'),
    backgroundColor: anyNamed('backgroundColor'),
    textColor: anyNamed('textColor'),
    infinityToast: anyNamed('infinityToast'),
  )).captured.single as List<({String? actionName, Function? onActionClick, Widget? actionIcon})>;
  return actions.first.onActionClick!;
}

void _showToastWithAction(MockAppToast appToast) => appToast.showToastMessage(
      any,
      any,
      actionName: anyNamed('actionName'),
      onActionClick: anyNamed('onActionClick'),
      actionIcon: anyNamed('actionIcon'),
      leadingSVGIcon: anyNamed('leadingSVGIcon'),
      leadingSVGIconColor: anyNamed('leadingSVGIconColor'),
      backgroundColor: anyNamed('backgroundColor'),
      textColor: anyNamed('textColor'),
    );
