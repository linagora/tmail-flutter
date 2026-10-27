import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/base/model/ui_keys.dart';
import 'package:tmail_ui_user/features/base/widget/clean_messages_banner.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/dashboard_routes.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

import '../base/core_robot.dart';
import '../utils/wait_for_condition.dart';
import 'abstract/abstract_thread_assertion_robot.dart';

class ThreadAssertionRobot extends CoreRobot implements AbstractThreadAssertionRobot {
  ThreadAssertionRobot(super.$);

  MailboxDashBoardController get _dashboard =>
      Get.find<MailboxDashBoardController>();

  List<int> _listedThreads(String subjectPrefix) =>
      _dashboard.emailsInCurrentMailbox
          .map((email) => email.subject ?? '')
          .where((subject) => subject.contains(subjectPrefix))
          .map((subject) => int.parse(subject.split(' ').last))
          .toList();

  @override
  Future<void> expectAppGridButtonVisible() async {
    await $(const ValueKey(UiKeys.toggleAppGridButton)).waitUntilVisible();
  }

  @override
  Future<void> expectTrashBannerVisible() async {
    await $(find.textContaining(AppLocalizations().empty_trash_now)).waitUntilVisible();
  }

  @override
  Future<void> expectTrashBannerInvisible() async {
    await $(const Key(UiKeys.cleanMessageBannerNotVisible)).waitUntilExists();
    await waitForCondition(() => !$(CleanMessagesBanner).visible);
  }

  @override
  Future<void> expectThreadsListedOnce(
    List<int> threads,
    String subjectPrefix,
  ) async {
    expect(
      _listedThreads(subjectPrefix),
      threads,
      reason: 'every thread of the folder must be listed once, newest first',
    );
  }

  @override
  Future<void> expectEachThreadListedOnce(
    List<int> threads,
    String subjectPrefix,
  ) async {
    final listed = _listedThreads(subjectPrefix);
    expect(
      listed.toSet().length,
      listed.length,
      reason: 'no thread may be listed twice; listed: $listed',
    );
    expect(
      listed.toSet(),
      threads.toSet(),
      reason: 'every thread must be listed, in any order',
    );
  }

  @override
  Future<void> expectListedThreadsArePrefixOf(
    List<int> threads,
    String subjectPrefix,
  ) async {
    final listed = _listedThreads(subjectPrefix);
    expect(
      listed,
      threads.take(listed.length),
      reason: 'precondition: the first page lists the newest threads',
    );
  }

  @override
  Future<void> expectListedThreadCountBelow(
    int n,
    String subjectPrefix,
  ) async {
    expect(
      _listedThreads(subjectPrefix).length,
      lessThan(n),
      reason: 'precondition: older threads are left to load-more',
    );
  }

  @override
  Future<void> expectListedThreadCountAbove(
    int n,
    String subjectPrefix,
  ) async {
    expect(
      _listedThreads(subjectPrefix).length,
      greaterThan(n),
      reason: 'the list must load more on its own to fill the viewport',
    );
  }

  @override
  Future<void> expectEmptyTrashThreadView() async {
    // The empty view only appears once the post-empty-trash email reload returns.
    // waitUntilVisible's frame-only retry loop does not yield to the browser event
    // loop on web, so JMAP responses may never be processed; waitForCondition does.
    final emptyThreadView = $(const Key(UiKeys.emptyThreadView));
    await waitForCondition(() async {
      await $.pump();
      return emptyThreadView.visible;
    });
  }

  @override
  Future<void> expectThreadDetailOpened() async {
    await waitForCondition(
      () => _dashboardRoute == DashboardRoutes.threadDetailed,
    );
  }

  @override
  Future<void> expectThreadDetailClosed() async {
    await waitForCondition(() => _dashboardRoute == DashboardRoutes.thread);
  }

  DashboardRoutes get _dashboardRoute => _dashboard.dashboardRoute.value;
}
