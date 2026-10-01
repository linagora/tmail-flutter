import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:core/presentation/views/container/tmail_container_widget.dart';
import 'package:core/utils/logging/app_logger_registry.dart';
import 'package:core/utils/logging/log_handler.dart';
import 'package:core/utils/logging/log_record.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:marionette_flutter/marionette_flutter.dart';
import 'package:tmail_ui_user/main/marionette/marionette_composer_extensions.dart';

/// Opt-in switch for Marionette MCP (AI agents driving the running app).
///
/// Enable with `--dart-define=MARIONETTE=true` in debug or profile builds.
/// Release builds never enable it: they expose no VM service, and the
/// compile-time `kReleaseMode` check lets the compiler drop this code.
const bool _marionetteFlag = bool.fromEnvironment('MARIONETTE');

const bool isMarionetteEnabled = !kReleaseMode && _marionetteFlag;

/// Installs [MarionetteBinding] as the app's [WidgetsBinding].
///
/// Must run before any other binding is created (in particular before
/// `SentryWidgetsFlutterBinding.ensureInitialized()`), because Flutter allows
/// only one binding per process. Sentry reuses an existing binding, so
/// initializing Marionette first keeps both working.
void initMarionetteIfEnabled() {
  if (!isMarionetteEnabled) return;

  final logCollector = PrintLogCollector();

  MarionetteBinding.ensureInitialized(
    MarionetteConfiguration(
      isInteractiveWidget: (type) =>
          type == TMailButtonWidget || type == TMailContainerWidget,
      extractText: _extractTMailText,
      logCollector: logCollector,
    ),
  );

  AppLoggerRegistry.instance.registerHandler(
    _MarionetteLogHandler(logCollector),
  );

  registerComposerExtensions();
}

/// Exposes tmail's custom buttons by their label so agents can
/// `tap(text: ...)` them. Icon-only buttons fall back to their tooltip.
String? _extractTMailText(Element element) {
  final widget = element.widget;
  if (widget is TMailButtonWidget) {
    if (widget.text.isNotEmpty) return widget.text;
    return widget.tooltipMessage;
  }
  if (widget is TMailContainerWidget) {
    return widget.tooltipMessage;
  }
  return null;
}

/// Forwards app logs to Marionette so agents can read them via `get_logs`.
class _MarionetteLogHandler extends LogHandler {
  final PrintLogCollector _collector;

  const _MarionetteLogHandler(this._collector);

  @override
  void handle(LogRecord record) {
    _collector.addLog('[${record.level.name}] ${record.rawMessage}');
  }
}
