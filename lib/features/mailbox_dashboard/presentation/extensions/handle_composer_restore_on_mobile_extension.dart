import 'package:core/utils/app_logger.dart';
import 'package:core/utils/platform_info.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:model/extensions/session_extension.dart';
import 'package:tmail_ui_user/features/composer/presentation/providers/composer_cache_interactor_providers.dart';
import 'package:tmail_ui_user/features/delegation/presentation/utils/until_no_account_switch_runs.dart';
import 'package:tmail_ui_user/features/email/presentation/model/composer_arguments.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/data/model/composer_persistent_cache.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/state/resolve_composer_cache_for_restore_state.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/extensions/open_and_close_composer_extension.dart';
import 'package:tmail_ui_user/main/providers/app_provider_container.dart';

extension HandleComposerRestoreOnMobileExtension on MailboxDashBoardController {
  /// [onlyDelegated] skips mine, whose draft the session load already restored.
  Future<void> checkAndRestoreComposerOnMobile({bool onlyDelegated = false}) async {
    // The shown account only. Mine restores as today; a delegated snapshot waits
    // until that mailbox is shown, after the start switch (ADR-0114).
    if (!PlatformInfo.isAndroid) return;

    try {
      while (!await _restoreForSettledShownAccount(onlyDelegated)) {
        // Opened now, the draft would compose with the identities of the mailbox a switch shows.
        log('HandleComposerRestoreOnMobileExtension::checkAndRestoreComposerOnMobile: shown account changed, retry');
      }
    } catch (e, stackTrace) {
      logWarning('HandleComposerRestoreOnMobileExtension::checkAndRestoreComposerOnMobile: error=$e\n$stackTrace');
    }
  }

  /// False when the shown account changed while its draft was read, so the restore runs again.
  Future<bool> _restoreForSettledShownAccount(bool onlyDelegated) async {
    await untilNoAccountSwitchRuns(appProviderContainer);
    final shownAccountId = activeAccountId;
    final session = sessionCurrent;
    if (shownAccountId == null || session == null) return true;
    if (onlyDelegated && shownAccountId == session.accountId) return true;

    final cache = await _resolveRestorableCache(shownAccountId, session.username);
    if (activeAccountId != shownAccountId) return false;
    if (cache != null) _reopenComposer(cache, shownAccountId);
    return true;
  }

  void _reopenComposer(ComposerPersistentCache cache, AccountId accountId) {
    log('HandleComposerRestoreOnMobileExtension::checkAndRestoreComposerOnMobile: reopening composer');
    openComposer(ComposerArguments.fromComposerPersistentCache(
      cache,
      accountId: accountId,
    ));
  }

  Future<ComposerPersistentCache?> _resolveRestorableCache(
    AccountId accountId,
    UserName userName,
  ) async {
    final result = await appProviderContainer
        .read(resolveComposerCacheForRestoreProvider)
        .execute(accountId, userName);
    return result.fold(
      (failure) {
        log('HandleComposerRestoreOnMobileExtension::_resolveRestorableCache: failure=${failure.runtimeType}');
        return null;
      },
      (success) {
        if (success is ResolveComposerCacheForRestoreSuccess) {
          return success.cache;
        }
        log('HandleComposerRestoreOnMobileExtension::_resolveRestorableCache: unexpected success type=${success.runtimeType}');
        return null;
      }
    );
  }
}
