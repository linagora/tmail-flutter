import 'package:tmail_ui_user/features/mailbox_dashboard/domain/linagora_ecosystem/linagora_ecosystem.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/linagora_ecosystem/linagora_ecosystem_handler.dart';

class LinagoraEcosystemHandlerRegistry {
  final List<LinagoraEcosystemHandler> _handlers = [];

  bool get hasHandlers => _handlers.isNotEmpty;

  void register(LinagoraEcosystemHandler handler) => _handlers.add(handler);

  void dispatchLoaded(LinagoraEcosystem ecosystem) {
    for (final handler in _handlers) {
      handler.onEcosystemLoaded(ecosystem);
    }
  }

  void dispatchCleared() {
    for (final handler in _handlers) {
      handler.onEcosystemCleared();
    }
  }
}
