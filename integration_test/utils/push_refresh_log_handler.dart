import 'package:core/utils/logging/formatters/mobile_console_formatter.dart';
import 'package:core/utils/logging/handlers/console_log_handler.dart';
import 'package:core/utils/logging/log_record.dart';

// Only the websocket-to-mailbox refresh path: other app logs carry email bodies and tokens into archived logcat.
class PushRefreshLogHandler extends ConsoleLogHandler {
  static const _prefixes = [
    'WebSocketController::',
    'PushBaseController::',
    'MailboxController::',
  ];

  const PushRefreshLogHandler() : super(formatter: const MobileConsoleFormatter());

  @override
  bool canHandle(LogRecord record) =>
      super.canHandle(record) && _prefixes.any(record.rawMessage.startsWith);
}
