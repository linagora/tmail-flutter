import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:model/email/email_action_type.dart';
import 'package:model/extensions/account_id_extensions.dart';
import 'package:patrol/patrol.dart';
import 'package:tmail_ui_user/features/caching/utils/cache_utils.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/state/get_all_composer_cache_state.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/usecases/get_all_composer_cache_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/extensions/reopen_composer_cache_extension.dart';
import 'package:universal_html/html.dart' as html;

import '../../base/core_robot.dart';
import '../../models/composer_reload_test_context.dart';
import '../../utils/wait_for_condition.dart';
import '../abstract/abstract_composer_reload_assertion_robot.dart';
import '../abstract/abstract_composer_reload_robot.dart';
import 'web_composer_reload_assertion_robot.dart';

class WebComposerReloadRobot extends CoreRobot
    implements AbstractComposerReloadRobot {
  WebComposerReloadRobot(PatrolIntegrationTester $) : super($);

  ComposerReloadTestContext? _context;

  ComposerReloadTestContext get _current =>
      _context ?? (throw StateError('Capture the composer before reloading'));

  @override
  late final AbstractComposerReloadAssertionRobot assertion =
      WebComposerReloadAssertionRobot($, () => _current);

  @override
  void captureCurrentComposer() {
    final dashboard = Get.find<MailboxDashBoardController>();
    final composerId = dashboard.composerManager.composerIdsQueue.last;
    final session = dashboard.sessionCurrent!;
    final accountId = dashboard.accountId.value!;
    final cacheKey = TupleKey(
      EmailActionType.reopenComposerBrowser.name,
      accountId.asString,
      session.username.value,
      composerId,
    ).toString();
    _context = ComposerReloadTestContext(
      dashboard: dashboard,
      originalController: dashboard.composerManager
          .getComposerView(composerId)
          .controller,
      session: session,
      accountId: accountId,
      composerId: composerId,
      cacheKey: cacheKey,
    );
    addTearDown(() {
      dashboard.composerManager.removeComposer(composerId);
      html.window.sessionStorage.remove(cacheKey);
    });
  }

  @override
  Future<void> waitForContentReady(
    String subject,
    String recipient,
    String body,
  ) {
    final controller = _current.originalController;
    return waitForCondition(
      () =>
          controller.subjectEmail.value == subject &&
          controller.listToEmailAddress.any(
            (address) => address.email == recipient,
          ) &&
          (controller.textEditorWeb?.contains(body) ?? false),
    );
  }

  @override
  void dispatchBeforeUnload() =>
      html.window.dispatchEvent(html.Event('beforeunload'));

  @override
  void tearDownWithoutClose() {
    _current.dashboard.composerManager.removeComposer(_current.composerId);
  }

  @override
  Future<void> restoreFromCache() async {
    final context = _current;
    final cacheState = await Get.find<GetAllComposerCacheInteractor>()
        .execute(context.accountId, context.session.username)
        .last;
    final cacheSuccess = cacheState.fold(
      (failure) => throw StateError('Could not read composer cache: $failure'),
      (success) => success as GetAllComposerCacheSuccess,
    );
    final cache = cacheSuccess.listComposerCache.singleWhere(
      (item) => item.composerId == context.composerId,
    );
    context.dashboard.handleGetAllComposerCacheSuccess(
      GetAllComposerCacheSuccess([cache]),
    );
  }
}
