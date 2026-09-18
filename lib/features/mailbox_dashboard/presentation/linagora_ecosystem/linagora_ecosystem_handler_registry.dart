import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/linagora_ecosystem/linagora_ecosystem.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/linagora_ecosystem/linagora_ecosystem_handler.dart';

part 'linagora_ecosystem_handler_registry.g.dart';

class LinagoraEcosystemHandlerRegistry {
  final List<LinagoraEcosystemHandler> _handlers = [];
  Ref? _ref;

  bool get hasHandlers => _handlers.isNotEmpty;

  /// This registry's own provider-scoped [Ref] — safe to read from at any
  /// time (including from another widget's `dispose()`), unlike a
  /// [WidgetRef] captured from a widget that may later unmount. Set once
  /// when the registry provider builds.
  Ref get ref {
    final attachedRef = _ref;
    assert(attachedRef != null,
        'LinagoraEcosystemHandlerRegistry.ref read before attachRef()');
    return attachedRef!;
  }

  void attachRef(Ref ref) => _ref ??= ref;

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

/// App-lifetime registry: handlers are registered once and must survive the
/// dashboard being rebuilt.
@Riverpod(keepAlive: true)
LinagoraEcosystemHandlerRegistry linagoraEcosystemHandlerRegistry(Ref ref) =>
    LinagoraEcosystemHandlerRegistry()..attachRef(ref);
