import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:hive_ce/hive.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:tmail_ui_user/features/composer/presentation/composer_controller.dart';
import 'package:tmail_ui_user/features/composer/presentation/composer_view_web.dart';
import 'package:tmail_ui_user/features/composer/presentation/manager/composer_manager.dart';
import 'package:tmail_ui_user/features/caching/config/hive_cache_config.dart';
import 'package:tmail_ui_user/features/caching/utils/caching_constants.dart';
import 'package:tmail_ui_user/features/composer/presentation/providers/composer_auto_save_notifier.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/action/dashboard_action.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/search_controller.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/delegates/getx_account_switch_dashboard.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/data/model/composer_cache.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/dashboard_routes.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/providers/composer_cache_data_providers.dart';
import 'package:tmail_ui_user/main/providers/app_provider_container.dart';

import '../../../../fixtures/delegation_fixtures.dart';
import 'getx_account_switch_dashboard_test.mocks.dart';

mockControllerCallback() => InternalFinalCallback<void>(callback: () {});
const fallbackGenerators = {
  #onStart: mockControllerCallback,
  #onDelete: mockControllerCallback,
};

@GenerateNiceMocks([
  MockSpec<MailboxDashBoardController>(fallbackGenerators: fallbackGenerators),
  MockSpec<SearchController>(fallbackGenerators: fallbackGenerators),
  MockSpec<ComposerManager>(fallbackGenerators: fallbackGenerators),
  MockSpec<ComposerController>(fallbackGenerators: fallbackGenerators),
])
void main() {
  late MockMailboxDashBoardController dashboard;
  late MockSearchController searchController;
  late MockComposerManager composerManager;
  late GetXAccountSwitchDashboard accountSwitchDashboard;

  setUp(() {
    dashboard = MockMailboxDashBoardController();
    searchController = MockSearchController();
    composerManager = MockComposerManager();
    when(dashboard.searchController).thenReturn(searchController);
    when(dashboard.composerManager).thenReturn(composerManager);
    accountSwitchDashboard = GetXAccountSwitchDashboard(dashboard);
  });

  group('resetForNewAccount:', () {
    test('unselects the folder and closes the opened email', () {
      accountSwitchDashboard.resetForNewAccount();

      verify(dashboard.setSelectedMailbox(null)).called(1);
      verify(dashboard.clearSelectedEmail()).called(1);
    });

    test('goes back to the email list', () {
      accountSwitchDashboard.resetForNewAccount();

      verify(dashboard.dispatchRoute(DashboardRoutes.thread)).called(1);
    });

    test('drops the quick filter, the search and the advanced search fields of the old account', () {
      accountSwitchDashboard.resetForNewAccount();

      verify(dashboard.clearFilterMessageOption()).called(1);
      verify(searchController.disableAllSearchEmail()).called(1);
      verify(dashboard.dispatchAction(argThat(isA<ClearAllFieldOfAdvancedSearchAction>()))).called(1);
    });

    test('makes the first email list of the target catch up with its changes', () {
      accountSwitchDashboard.resetForNewAccount();

      verify(dashboard.setIsFirstSessionLoad(true)).called(1);
    });

    test('forgets the email state of the old account, so a refresh never sends it to the target', () {
      accountSwitchDashboard.resetForNewAccount();

      verify(dashboard.setCurrentEmailState(null)).called(1);
    });
  });

  group('hasOpenComposer:', () {
    for (final hasComposer in [true, false]) {
      test('is $hasComposer when the dashboard composers say $hasComposer', () {
        when(composerManager.hasComposer).thenReturn(hasComposer);

        expect(accountSwitchDashboard.hasOpenComposer, hasComposer);
      });
    }

    for (final (route, tag, isOpen) in [
      ('the route of a mobile composer', null, true),
      ('a web composer, registered under its id,', 'composer-1', false),
    ]) {
      test('is $isOpen while $route is open', () {
        when(composerManager.hasComposer).thenReturn(false);
        Get.lazyPut<ComposerController>(() => throw UnimplementedError('never built'), tag: tag);
        addTearDown(() => Get.delete<ComposerController>(tag: tag, force: true));

        expect(accountSwitchDashboard.hasOpenComposer, isOpen);
      });
    }
  });

  group('closeComposers:', () {
    final accountId = DelegationFixtures.aliceAccountId;
    final session = DelegationFixtures.session();
    final composerCacheRepository = appProviderContainer.read(composerCacheRepositoryProvider);
    late Directory hiveDirectory;

    setUpAll(() async {
      hiveDirectory = Directory.systemTemp.createTempSync('getx_account_switch_dashboard_test');
      await HiveCacheConfig.instance.setUp(cachePath: hiveDirectory.path);
    });

    tearDownAll(() async {
      await IsolatedHive.close();
      hiveDirectory.deleteSync(recursive: true);
    });

    setUp(() {
      when(dashboard.activeAccountId).thenReturn(accountId);
      when(dashboard.sessionCurrent).thenReturn(session);
    });

    tearDown(() => IsolatedHive.deleteBoxFromDisk(CachingConstants.composerHiveCacheBoxName));

    Future<void> saveSnapshot() => composerCacheRepository.saveComposerCache(
          accountId,
          session.username,
          ComposerCache(composerId: 'composer-1'),
        );

    Future<List<ComposerCache>> savedSnapshots() =>
        composerCacheRepository.getComposerCache(accountId, session.username);

    RxMap<String, ComposerView> webComposers(List<String> ids) =>
        {for (final id in ids) id: ComposerView(key: Key(id), composerId: id)}.obs;

    test('closes every web composer and returns how many were open', () async {
      when(composerManager.composers).thenReturn(webComposers(['composer-1', 'composer-2']));

      expect(await accountSwitchDashboard.closeComposers(), 2);
      verify(composerManager.removeAllComposers()).called(1);
    });

    MockComposerController openMobileComposer() {
      final composerController = MockComposerController();
      when(composerController.autoSaveComposerId).thenReturn('composer-1');
      when(composerController.mailboxDashBoardController).thenReturn(dashboard);
      Get.put<ComposerController>(composerController);
      addTearDown(() => Get.delete<ComposerController>(force: true));
      return composerController;
    }

    test('counts the open mobile composer route too', () async {
      when(composerManager.composers).thenReturn(webComposers([]));
      openMobileComposer();

      expect(await accountSwitchDashboard.closeComposers(), 1);
    });

    test('drops the saved snapshot of the open mobile composer of the shown account', () async {
      when(composerManager.composers).thenReturn(webComposers([]));
      openMobileComposer();
      await saveSnapshot();

      await accountSwitchDashboard.closeComposers();

      expect(await savedSnapshots(), isEmpty);
    });

    test('flags the open mobile composer as closed, so a snapshot save still running never writes it back', () async {
      when(composerManager.composers).thenReturn(webComposers([]));
      openMobileComposer();
      addTearDown(() => appProviderContainer.invalidate(composerAutoSaveProvider('composer-1')));

      await accountSwitchDashboard.closeComposers();

      expect(appProviderContainer.read(composerAutoSaveProvider('composer-1').notifier).isCleanClose, isTrue);
    });

    test('SHOULD NOT touch a snapshot when only web composers are open', () async {
      when(composerManager.composers).thenReturn(webComposers(['composer-1']));
      await saveSnapshot();

      await accountSwitchDashboard.closeComposers();

      expect((await savedSnapshots()).map((snapshot) => snapshot.composerId), ['composer-1']);
    });

    test('returns 0 when no composer is open', () async {
      when(composerManager.composers).thenReturn(webComposers([]));

      expect(await accountSwitchDashboard.closeComposers(), 0);
    });
  });
}
