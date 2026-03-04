import 'package:core/presentation/extensions/string_extension.dart';
import 'package:core/utils/app_logger.dart';
import 'package:core/utils/platform_info.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:tmail_ui_user/features/base/base_controller.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/linagora_ecosystem/linagora_ecosystem_identifier.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/linagora_ecosystem/sentry_config_linagora_ecosystem.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/state/get_linagora_ecosystem_state.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/usecases/get_linagora_ecosystem_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/mixin/sentry_ecosystem_mixin.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

class LinagoraEcosystemController with SentryEcosystemMixin {
  GetLinagoraEcosystemInteractor? _getLinagoraEcosystemInteractor;

  final BaseController _baseController;

  LinagoraEcosystemController(this._baseController);

  void init({SentryUser? newSentryUser}) {
    try {
      if (!PlatformInfo.isAndroid) return;

      initSentryUser(newSentryUser);

      _initInteractor();
      _loadLinagoraEcosystem();
    } catch (e) {
      logWarning('LinagoraEcosystemController:init: $e');
    }
  }

  void _initInteractor() {
    _getLinagoraEcosystemInteractor ??=
        getBinding<GetLinagoraEcosystemInteractor>();
  }

  void _loadLinagoraEcosystem() {
    final baseUrl = _baseController.dynamicUrlInterceptors.jmapUrl;

    if (baseUrl == null || baseUrl.trimmed.isEmpty) {
      logWarning('LinagoraEcosystemController:_loadLinagoraEcosystem: baseUrl is empty');
      return;
    }

    if (_getLinagoraEcosystemInteractor == null) {
      logWarning('LinagoraEcosystemController:_loadLinagoraEcosystem: _getLinagoraEcosystemInteractor is null');
      return;
    }

    _baseController.consumeState(
      _getLinagoraEcosystemInteractor!.execute(baseUrl),
    );
  }

  Future<void> handleGetLinagoraEcosystemSuccess(
    GetLinagoraEcosystemSuccess success,
  ) async {
    if (!PlatformInfo.isAndroid) return;

    final properties = success.linagoraEcosystem.properties;

    if (properties?[LinagoraEcosystemIdentifier.sentryConfig]
        case SentryConfigLinagoraEcosystem ecosystemConfig) {
      await setUpSentry(ecosystemConfig);
    } else {
      logWarning(
          'LinagoraEcosystemController:handleGetLinagoraEcosystemSuccess: Sentry config ecosystem is null');
    }
  }

  Future<void> handleGetLinagoraEcosystemFailure(
    GetLinagoraEcosystemFailure failure,
  ) async {
    logWarning('LinagoraEcosystemController:handleGetLinagoraEcosystemFailure: $failure');
  }
}
