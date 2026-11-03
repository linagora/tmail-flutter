import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:tmail_ui_user/features/composer/presentation/composer_controller.dart';
import 'package:tmail_ui_user/features/composer/presentation/manager/composer_manager.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/action/dashboard_action.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/search_controller.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/delegates/getx_account_switch_dashboard.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/dashboard_routes.dart';

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
}
