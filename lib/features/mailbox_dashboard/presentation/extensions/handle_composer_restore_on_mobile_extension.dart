import 'package:core/utils/app_logger.dart';
import 'package:core/utils/platform_info.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:tmail_ui_user/features/composer/presentation/providers/composer_cache_providers.dart';
import 'package:tmail_ui_user/features/email/presentation/model/composer_arguments.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/data/model/composer_persistent_cache.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/state/resolve_composer_cache_for_restore_state.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/extensions/open_and_close_composer_extension.dart';
import 'package:tmail_ui_user/main/providers/app_provider_container.dart';

extension HandleComposerRestoreOnMobileExtension on MailboxDashBoardController {
  Future<void> checkAndRestoreComposerOnMobile() async {
    if (!PlatformInfo.isAndroid) return;

    final currentAccountId = accountId.value;
    final currentUserName = sessionCurrent?.username;
    if (currentAccountId == null || currentUserName == null) return;

    try {
      final cache = await _resolveRestorableCache(currentAccountId, currentUserName);
      if (cache == null) return;
      log('HandleComposerRestoreOnMobileExtension::checkAndRestoreComposerOnMobile: reopening composer');
      openComposer(ComposerArguments.fromComposerPersistentCache(cache));
    } catch (e, stackTrace) {
      logWarning('HandleComposerRestoreOnMobileExtension::checkAndRestoreComposerOnMobile: error=$e\n$stackTrace');
    }
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
