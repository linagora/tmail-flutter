import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:core/presentation/views/container/tmail_container_widget.dart';
import 'package:core/utils/logging/app_logger_registry.dart';
import 'package:core/utils/logging/log_handler.dart';
import 'package:core/utils/logging/log_record.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:marionette_flutter/marionette_flutter.dart';

import '../runtime/mcp_app_binding.dart';
import 'marionette_composer_extensions.dart';

class MarionetteMcpBinding extends McpAppBinding {
  const MarionetteMcpBinding();

  static const bool _flag = bool.fromEnvironment(
    'MARIONETTE',
    defaultValue: true,
  );

  @override
  String get name => 'marionette';

  @override
  bool get isEnabled => !kReleaseMode && _flag;

  @override
  bool get ownsWidgetsBinding => true;

  @override
  void ensureInitialized() {
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
  }

  @override
  void registerExtensions() {
    registerComposerExtensions();
  }

  static String? _extractTMailText(Element element) {
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
}

class _MarionetteLogHandler extends LogHandler {
  final PrintLogCollector _collector;

  const _MarionetteLogHandler(this._collector);

  @override
  void handle(LogRecord record) {
    _collector.addLog('[${record.level.name}] ${record.rawMessage}');
  }
}
