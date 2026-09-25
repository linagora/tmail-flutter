import 'package:core/utils/app_logger.dart';
import 'package:core/utils/platform_info.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:tmail_ui_user/features/base/base_controller.dart';
import 'package:tmail_ui_user/features/composer/presentation/manager/composer_manager.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/usecases/remove_all_composer_cache_interactor.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

extension DiscardWebComposersOnLogoutExtension on BaseController {
  // Explicit logout must not leave reload snapshots that reopen after re-login.
  Future<void> discardWebComposersOnLogout(
    Session session,
    AccountId accountId,
  ) async {
    if (!PlatformInfo.isWeb) return;

    // Close composers first so no beforeunload writes a snapshot back.
    getBinding<ComposerManager>()?.removeAllComposers();
    twakeAppManager.setHasComposer(false);

    final interactor = getBinding<RemoveAllComposerCacheInteractor>();
    if (interactor == null) return;

    final result = await interactor.execute(accountId, session.username);
    result.fold(
      (failure) => logWarning(
        '$runtimeType::discardWebComposersOnLogout: '
        'failure=${failure.runtimeType}',
      ),
      (_) {},
    );
  }
}
