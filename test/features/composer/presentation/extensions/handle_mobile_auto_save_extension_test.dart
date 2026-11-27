import 'dart:async';
import 'dart:io';

import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:hive_ce/hive.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:model/model.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:rich_text_composer/rich_text_composer.dart';
import 'package:tmail_ui_user/features/caching/config/hive_cache_config.dart';
import 'package:tmail_ui_user/features/caching/utils/caching_constants.dart';
import 'package:tmail_ui_user/features/composer/domain/repository/composer_repository.dart';
import 'package:tmail_ui_user/features/composer/domain/usecases/save_composer_cache_interactor.dart';
import 'package:tmail_ui_user/features/composer/presentation/composer_controller.dart';
import 'package:tmail_ui_user/features/composer/presentation/extensions/handle_mobile_auto_save_extension.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/create_email_request.dart';
import 'package:tmail_ui_user/features/composer/presentation/providers/composer_auto_save_notifier.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/data/model/composer_cache.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/data/model/composer_persistent_cache.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/repository/composer_cache_repository.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/state/save_composer_cache_state.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/providers/composer_cache_data_providers.dart';
import 'package:tmail_ui_user/main/providers/app_provider_container.dart';

import '../../../../fixtures/delegation_fixtures.dart';
import 'handle_mobile_auto_save_extension_test.mocks.dart';

mockControllerCallback() => InternalFinalCallback<void>(callback: () {});
const fallbackGenerators = {
  #onStart: mockControllerCallback,
  #onDelete: mockControllerCallback,
};

class _BlankEditor extends Fake implements HtmlEditorApi {
  final void Function() onSetText;

  _BlankEditor({required this.onSetText});

  @override
  Future<String> getText() async => '';

  @override
  Future<void> setText(String text) async => onSetText();
}

class _FilledEditor extends Fake implements HtmlEditorApi {
  final void Function() onGetText;

  _FilledEditor({required this.onGetText});

  @override
  Future<String> getText() async {
    onGetText();
    return '<p>draft</p>';
  }
}

class _FailingEditor extends Fake implements HtmlEditorApi {
  final void Function() onSetText;

  _FailingEditor({required this.onSetText});

  @override
  Future<String> getText() async => '';

  @override
  Future<void> setText(String text) async {
    onSetText();
    throw StateError('editor gone');
  }
}

class _HeldEditor extends Fake implements HtmlEditorApi {
  final Future<String> firstContent;
  var _getTextCount = 0;

  _HeldEditor({required this.firstContent});

  @override
  Future<String> getText() async => _getTextCount++ == 0 ? firstContent : '<p>draft</p>';
}

class _RecordingSaveComposerCacheInteractor extends SaveComposerCacheInteractor {
  final saves = <Future<Either<Failure, Success>>>[];

  _RecordingSaveComposerCacheInteractor(ComposerCacheRepository composerCacheRepository, ComposerRepository composerRepository)
      : super(composerCacheRepository, composerRepository);

  @override
  Future<Either<Failure, Success>> execute({
    required CreateEmailRequest createEmailRequest,
    bool isPersistent = false,
    CacheWriteAllowed? isWriteAllowed,
  }) {
    final save = super.execute(
      createEmailRequest: createEmailRequest,
      isPersistent: isPersistent,
      isWriteAllowed: isWriteAllowed,
    );
    saves.add(save);
    return save;
  }
}

class _PendingTimer extends Fake implements Timer {
  @override
  bool get isActive => true;
}

@GenerateNiceMocks([
  MockSpec<MailboxDashBoardController>(fallbackGenerators: fallbackGenerators),
  MockSpec<ComposerController>(fallbackGenerators: fallbackGenerators),
  MockSpec<ComposerRepository>(),
])
void main() {
  const composerId = 'composer-1';
  final alice = DelegationFixtures.aliceAccountId;
  final bob = DelegationFixtures.bobAccountId;
  final session = DelegationFixtures.session();
  final composerCacheRepository = appProviderContainer.read(composerCacheRepositoryProvider);
  late Directory hiveDirectory;
  late MockMailboxDashBoardController dashboard;
  late MockComposerController composerController;
  late AccountId shownAccountId;

  setUpAll(() async {
    hiveDirectory = Directory.systemTemp.createTempSync('handle_mobile_auto_save_extension_test');
    await HiveCacheConfig.instance.setUp(cachePath: hiveDirectory.path);
  });

  tearDownAll(() async {
    await IsolatedHive.close();
    hiveDirectory.deleteSync(recursive: true);
  });

  setUp(() {
    dashboard = MockMailboxDashBoardController();
    composerController = MockComposerController();
    when(dashboard.activeAccountId).thenAnswer((_) => shownAccountId);
    when(dashboard.sessionCurrent).thenReturn(session);
    when(composerController.mailboxDashBoardController).thenReturn(dashboard);
    when(composerController.composerAccountId).thenAnswer((_) => shownAccountId);
    when(composerController.autoSaveComposerId).thenReturn(composerId);
  });

  tearDown(() async {
    appProviderContainer.invalidate(composerAutoSaveProvider(composerId));
    await IsolatedHive.deleteBoxFromDisk(CachingConstants.composerHiveCacheBoxName);
  });

  Future<void> saveSnapshotOf(AccountId accountId) => composerCacheRepository.saveComposerCache(
        accountId,
        session.username,
        ComposerPersistentCache(
          email: Email(),
          composerId: composerId,
          timestampMs: DateTime.now().millisecondsSinceEpoch,
        ),
      );

  Future<List<ComposerCache>> snapshotsOf(AccountId accountId) =>
      composerCacheRepository.getComposerCache(accountId, session.username);

  // The save runs unawaited, so it has reached the request build once the event queue drains.
  Future<void> verifySnapshotSaveStarted() async {
    await pumpEventQueue();
    verify(composerController.buildCreateEmailRequestForAutoSave(htmlContent: anyNamed('htmlContent'))).called(1);
  }

  Future<void> verifyNoSnapshotSave() async {
    await pumpEventQueue();
    verifyNever(composerController.buildCreateEmailRequestForAutoSave(htmlContent: anyNamed('htmlContent')));
  }

  _RecordingSaveComposerCacheInteractor stubSnapshotSaveTo(AccountId accountId) {
    final composerRepository = MockComposerRepository();
    final saveComposerCacheInteractor = _RecordingSaveComposerCacheInteractor(composerCacheRepository, composerRepository);
    when(composerController.saveComposerCacheInteractor).thenReturn(saveComposerCacheInteractor);
    when(composerController.buildCreateEmailRequestForAutoSave(htmlContent: anyNamed('htmlContent')))
        .thenAnswer((_) async => CreateEmailRequest(
              session: session,
              accountId: accountId,
              emailActionType: EmailActionType.compose,
              ownEmailAddress: 'alice@example.test',
              subject: '',
              emailContent: '',
            ));
    when(composerRepository.generateEmail(
      any,
      withIdentityHeader: anyNamed('withIdentityHeader'),
      isDraft: anyNamed('isDraft'),
      isTemplate: anyNamed('isTemplate'),
    )).thenAnswer((_) async => Email());
    return saveComposerCacheInteractor;
  }

  group('inactive lifecycle:', () {
    testWidgets('starts a snapshot save once the inactive guard ends', (tester) async {
      when(composerController.htmlEditorApi).thenReturn(_BlankEditor(onSetText: () {}));
      composerController.initMobileAutoSave();
      final listener = verify(composerController.mobileAutoSaveLifecycleListener = captureAny).captured.single as AppLifecycleListener;
      final periodicTimer = verify(composerController.periodicSnapshotTimer = captureAny).captured.single as Timer;

      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      await tester.pump(const Duration(milliseconds: 300));

      await tester.pump();
      verify(composerController.buildCreateEmailRequestForAutoSave(htmlContent: anyNamed('htmlContent'))).called(1);
      periodicTimer.cancel();
      // A live listener would start a restore on resumed and leave its timer pending past the test.
      listener.dispose();
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    });

    testWidgets('SHOULD NOT start a snapshot save from the inactive guard while restoring, and saves once the restore ends', (tester) async {
      shownAccountId = alice;
      var isRestoring = false;
      when(composerController.isRestoringFromCache).thenAnswer((_) => isRestoring);
      when(composerController.isRestoringFromCache = true).thenAnswer((_) => isRestoring = true);
      when(composerController.isRestoringFromCache = false).thenAnswer((_) => isRestoring = false);
      final restoreRead = Completer<String>();
      when(composerController.htmlEditorApi).thenReturn(_HeldEditor(firstContent: restoreRead.future));
      composerController.initMobileAutoSave();
      final listener = verify(composerController.mobileAutoSaveLifecycleListener = captureAny).captured.single as AppLifecycleListener;
      final periodicTimer = verify(composerController.periodicSnapshotTimer = captureAny).captured.single as Timer;
      unawaited(composerController.restoreIfEditorBlank());

      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump();
      verifyNever(composerController.buildCreateEmailRequestForAutoSave(htmlContent: anyNamed('htmlContent')));

      restoreRead.complete('<p>draft</p>');
      await tester.pump();
      verify(composerController.buildCreateEmailRequestForAutoSave(htmlContent: anyNamed('htmlContent'))).called(1);
      periodicTimer.cancel();
      listener.dispose();
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    });
  });

  group('discardComposerMobileSnapshot:', () {
    test('removes the stored snapshot and makes a save still uploading inline images skip its write', () async {
      shownAccountId = alice;
      final composerRepository = MockComposerRepository();
      final uploadEnds = Completer<Email>();
      final uploadStarted = Completer<void>();
      final saveComposerCacheInteractor = _RecordingSaveComposerCacheInteractor(composerCacheRepository, composerRepository);
      when(composerController.htmlEditorApi).thenReturn(_BlankEditor(onSetText: () {}));
      when(composerController.saveComposerCacheInteractor).thenReturn(saveComposerCacheInteractor);
      when(composerController.buildCreateEmailRequestForAutoSave(htmlContent: anyNamed('htmlContent')))
          .thenAnswer((_) async => CreateEmailRequest(
                session: session,
                accountId: alice,
                emailActionType: EmailActionType.compose,
                ownEmailAddress: 'alice@example.test',
                subject: '',
                emailContent: '',
              ));
      when(composerRepository.generateEmail(
        any,
        withIdentityHeader: anyNamed('withIdentityHeader'),
        isDraft: anyNamed('isDraft'),
        isTemplate: anyNamed('isTemplate'),
      )).thenAnswer((_) {
        uploadStarted.complete();
        return uploadEnds.future;
      });
      WidgetsBinding.instance.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      addTearDown(() => WidgetsBinding.instance.handleAppLifecycleStateChanged(AppLifecycleState.resumed));
      await composerController.restoreIfEditorBlank();
      await uploadStarted.future;
      await saveSnapshotOf(alice);

      await composerController.discardComposerMobileSnapshot();
      expect(await snapshotsOf(alice), isEmpty);
      uploadEnds.complete(Email());

      expect(await saveComposerCacheInteractor.saves.single, Right<Failure, Success>(SaveComposerCacheSkipped()));
      expect(await snapshotsOf(alice), isEmpty);
    });
  });

  group('restoreIfEditorBlank:', () {
    test('clears the snapshot it restored, not the one of the mailbox shown once the editor is filled', () async {
      shownAccountId = bob;
      await saveSnapshotOf(bob);
      await saveSnapshotOf(alice);
      when(composerController.htmlEditorApi).thenReturn(_BlankEditor(onSetText: () => shownAccountId = alice));

      await composerController.restoreIfEditorBlank();

      expect(shownAccountId, alice);
      expect(await snapshotsOf(bob), isEmpty);
      expect((await snapshotsOf(alice)).map((snapshot) => snapshot.composerId), [composerId]);
    });

    void showAppIn(AppLifecycleState state) {
      WidgetsBinding.instance.handleAppLifecycleStateChanged(state);
      addTearDown(() => WidgetsBinding.instance.handleAppLifecycleStateChanged(AppLifecycleState.resumed));
    }

    test('saves a snapshot again once it ends with the app in the background, since a save asked for meanwhile was skipped', () async {
      shownAccountId = alice;
      await saveSnapshotOf(alice);
      showAppIn(AppLifecycleState.resumed);
      when(composerController.htmlEditorApi).thenReturn(_BlankEditor(onSetText: () => showAppIn(AppLifecycleState.paused)));

      await composerController.restoreIfEditorBlank();

      await verifySnapshotSaveStarted();
    });

    test('SHOULD NOT save the blank editor over the snapshot when applying it failed with the app in the background', () async {
      shownAccountId = alice;
      await saveSnapshotOf(alice);
      showAppIn(AppLifecycleState.resumed);
      when(composerController.htmlEditorApi).thenReturn(_FailingEditor(onSetText: () => showAppIn(AppLifecycleState.paused)));

      await composerController.restoreIfEditorBlank();

      await verifyNoSnapshotSave();
      expect((await snapshotsOf(alice)).map((snapshot) => snapshot.composerId), [composerId]);
      verify(composerController.unrestoredMobileSnapshotOwner = (accountId: alice, userName: session.username)).called(1);
    });

    test('SHOULD NOT save the blank editor over a snapshot that a restore failed to apply', () async {
      shownAccountId = alice;
      when(composerController.unrestoredMobileSnapshotOwner).thenReturn((accountId: alice, userName: session.username));
      showAppIn(AppLifecycleState.resumed);
      when(composerController.htmlEditorApi).thenReturn(_BlankEditor(onSetText: () {}));
      showAppIn(AppLifecycleState.paused);

      await composerController.restoreIfEditorBlank();

      await verifyNoSnapshotSave();
    });

    test('lets a blank editor be saved again once a written one replaced the snapshot a restore failed to apply', () async {
      shownAccountId = alice;
      when(composerController.unrestoredMobileSnapshotOwner).thenReturn((accountId: alice, userName: session.username));
      final saveComposerCacheInteractor = stubSnapshotSaveTo(alice);
      when(composerController.htmlEditorApi).thenReturn(_FilledEditor(onGetText: () => showAppIn(AppLifecycleState.paused)));

      await composerController.restoreIfEditorBlank();
      await pumpEventQueue();

      expect(await saveComposerCacheInteractor.saves.single, Right<Failure, Success>(SaveComposerCacheSuccess()));
      verify(composerController.unrestoredMobileSnapshotOwner = null).called(1);
    });

    test('SHOULD NOT forget a snapshot a restore failed to apply when the written editor was saved for another mailbox', () async {
      shownAccountId = alice;
      when(composerController.unrestoredMobileSnapshotOwner).thenReturn((accountId: alice, userName: session.username));
      final saveComposerCacheInteractor = stubSnapshotSaveTo(bob);
      when(composerController.htmlEditorApi).thenReturn(_FilledEditor(onGetText: () => showAppIn(AppLifecycleState.paused)));

      await composerController.restoreIfEditorBlank();
      await pumpEventQueue();

      expect(await saveComposerCacheInteractor.saves.single, Right<Failure, Success>(SaveComposerCacheSuccess()));
      verifyNever(composerController.unrestoredMobileSnapshotOwner = null);
    });

    test('saves a written editor even while a snapshot is still to restore', () async {
      shownAccountId = alice;
      when(composerController.unrestoredMobileSnapshotOwner).thenReturn((accountId: alice, userName: session.username));
      when(composerController.htmlEditorApi).thenReturn(_FilledEditor(onGetText: () => showAppIn(AppLifecycleState.paused)));

      await composerController.restoreIfEditorBlank();

      await verifySnapshotSaveStarted();
    });

    test('saves a snapshot again when the editor already has content and the app went to the background meanwhile', () async {
      shownAccountId = alice;
      showAppIn(AppLifecycleState.resumed);
      when(composerController.htmlEditorApi).thenReturn(_FilledEditor(onGetText: () => showAppIn(AppLifecycleState.paused)));

      await composerController.restoreIfEditorBlank();

      await verifySnapshotSaveStarted();
    });

    test('SHOULD NOT save a snapshot again while the inactive guard is still pending, since it saves on its own', () async {
      shownAccountId = alice;
      showAppIn(AppLifecycleState.resumed);
      when(composerController.inactiveGuardTimer).thenReturn(_PendingTimer());
      when(composerController.htmlEditorApi).thenReturn(_FilledEditor(onGetText: () => showAppIn(AppLifecycleState.inactive)));

      await composerController.restoreIfEditorBlank();

      await verifyNoSnapshotSave();
    });

    test('SHOULD NOT save a snapshot again once it ends with the app in the foreground', () async {
      shownAccountId = alice;
      await saveSnapshotOf(alice);
      showAppIn(AppLifecycleState.resumed);
      when(composerController.htmlEditorApi).thenReturn(_BlankEditor(onSetText: () {}));

      await composerController.restoreIfEditorBlank();

      await verifyNoSnapshotSave();
    });
  });
}
