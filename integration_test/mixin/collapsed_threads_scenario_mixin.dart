import 'dart:async';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/core/state.dart';
import 'package:model/extensions/presentation_mailbox_extension.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/preferences/preferences_setting.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/preferences/thread_detail_config.dart';
import 'package:tmail_ui_user/features/thread/domain/state/refresh_all_email_state.dart';
import 'package:tmail_ui_user/features/thread/presentation/thread_controller.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/providers/app_provider_container.dart';
import 'package:tmail_ui_user/main/providers/settings/local_settings_notifier.dart';

import '../base/base_test_scenario.dart';
import '../utils/collapsed_thread_provisioner.dart';
import '../utils/test_timeouts.dart';
import '../utils/wait_for_condition.dart';
import '../utils/wait_for_mailbox_ready.dart';

mixin CollapsedThreadsScenarioMixin on BaseTestScenario {
  static const _forceEmailQueryKey = 'FORCE_EMAIL_QUERY';

  String get threadSubjectPrefix;

  MailboxDashBoardController get dashboardController =>
      Get.find<MailboxDashBoardController>();

  ThreadController get threadController => Get.find<ThreadController>();

  CollapsedThreadProvisioner get threadProvisioner =>
      CollapsedThreadProvisioner();

  LocalSettingsNotifier get _localSettings =>
      appProviderContainer.read(localSettingsProvider.notifier);

  List<int> get listedThreads => dashboardController.emailsInCurrentMailbox
      .map((email) => email.subject ?? '')
      .where((subject) => subject.contains(threadSubjectPrefix))
      .map((subject) => int.parse(subject.split(' ').last))
      .toList();

  String get listState =>
      'listed threads: $listedThreads, '
      'canLoadMore: ${threadController.canLoadMore}';

  Future<void> runWithCollapsedThreads(Future<void> Function() body) async {
    await waitForMailboxReady();
    await $.pump(const Duration(seconds: 2));

    final previousForceEmailQuery = dotenv.env[_forceEmailQueryKey];
    final previousSettings = appProviderContainer.read(localSettingsProvider);
    dotenv.env[_forceEmailQueryKey] = 'true';
    _localSettings.update(
      PreferencesSetting([
        ...previousSettings.configs.where(
          (config) => config is! ThreadDetailConfig,
        ),
        previousSettings.threadConfig.copyWith(isEnabled: true),
      ]),
    );
    try {
      await threadProvisioner.deleteProvisionedThreads(threadSubjectPrefix);
      await body();
    } finally {
      await threadProvisioner.deleteProvisionedThreads(threadSubjectPrefix);
      _localSettings.update(previousSettings);
      if (previousForceEmailQuery == null) {
        dotenv.env.remove(_forceEmailQueryKey);
      } else {
        dotenv.env[_forceEmailQueryKey] = previousForceEmailQuery;
      }
    }
  }

  Future<void> reloadFolder() async {
    await dashboardController.refreshMailboxAction();
    // The refresh starts after a delay and a cache clear; rows from the earlier
    // load already satisfy "threads listed", so wait for the refresh itself.
    await waitForStep(
      'folder refreshed',
      () => dashboardController.refreshingAllEmailState.value.fold(
        (_) => false,
        (state) => state is RefreshAllEmailSuccess,
      ),
      timeout: TestTimeouts.long,
    );
    await waitForStep('threads listed', () => listedThreads.isNotEmpty);
    await waitForLoadMoreIdle();
  }

  Future<void> openStarredFolder() async {
    await robots.threadRobot().openMailbox();
    final mailboxMenu = robots.mailboxMenuRobot();
    await mailboxMenu.navigation.openFolder(
      mailboxMenu.mailboxItemByName(
        AppLocalizations().favoriteMailboxDisplayName,
      ),
    );
    await waitForStep(
      'starred folder selected',
      () => dashboardController.selectedMailbox.value?.isFavorite == true,
    );
    await waitForStep('threads listed', () => listedThreads.isNotEmpty);
    await waitForLoadMoreIdle();
  }

  Future<void> waitForStep(
    String step,
    bool Function() condition, {
    Duration timeout = TestTimeouts.medium,
  }) async {
    try {
      await waitForCondition(condition, timeout: timeout);
    } on TimeoutException {
      fail('Timed out waiting for "$step"; $listState');
    }
  }

  Future<void> waitForLoadMoreIdle() async {
    bool isIdle() => !threadController.loadingMoreStatus.value.isRunning;
    await waitForStep('load-more settled', isIdle, timeout: TestTimeouts.long);
    await $.pump(const Duration(seconds: 2));
    await waitForStep('load-more settled', isIdle, timeout: TestTimeouts.long);
    await $.pumpAndSettle();
  }

  Future<void> waitForEmailState(State? state) => waitForStep(
    'websocket change applied',
    () => dashboardController.currentEmailState == state,
    timeout: TestTimeouts.long,
  );

  Future<void> scrollUntilListStopsGrowing() async {
    const maxScrollsWithoutGrowth = 5;
    var scrollsWithoutGrowth = 0;
    var listedCount = dashboardController.emailsInCurrentMailbox.length;

    while (scrollsWithoutGrowth < maxScrollsWithoutGrowth) {
      final scrollController = threadController.listEmailController;
      if (scrollController.hasClients) {
        scrollController
          ..jumpTo(0)
          ..jumpTo(scrollController.position.maxScrollExtent);
      }
      await $.pump(const Duration(milliseconds: 500));
      await waitForLoadMoreIdle();
      final newCount = dashboardController.emailsInCurrentMailbox.length;
      scrollsWithoutGrowth = newCount > listedCount
          ? 0
          : scrollsWithoutGrowth + 1;
      listedCount = newCount;
    }
  }
}
