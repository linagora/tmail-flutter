import 'package:core/utils/logging/app_logger_registry.dart';
import 'package:core/utils/logging/log_handler.dart';
import 'package:core/utils/logging/log_record.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'primary_focus_logger.dart';
import 'utc_clock.dart';

const _maxEntries = 40;
// Composer focus decisions and thread reload/load-more triggers; other app logs would push them out before the failure dump.
const _prefixes = [
  'ComposerController::_autoFocusFieldWhenLauncher',
  'ComposerController::_subjectEmailInputFocusListener',
  'ThreadController::_registerObxStreamListener:SelectedMailbox',
  'ThreadController::resetToOriginalValue',
  'ThreadController::_getAllEmailAction',
  'ThreadController::_handleOnDoneGetAllEmailSuccess',
  'ThreadController::_refreshChangesAllEmailSuccess: COUNT',
  'ThreadController::_performAutomaticallyLoadMoreEmails',
  'ThreadController::handleLoadMoreEmailsRequest',
];

// Buffers app log lines a profile build never prints; printed by the failure dump.
class AppLogRecorder extends LogHandler {
  AppLogRecorder._();

  static final instance = AppLogRecorder._();

  final _entries = <String>[];
  bool _recording = false;

  void start() {
    _entries.clear();
    _recording = true;
    AppLoggerRegistry.instance.registerHandler(this);
  }

  // The registry has no unregister; a stopped recorder ignores every record.
  void stop() => _recording = false;

  @override
  bool canHandle(LogRecord record) =>
      _recording && _prefixes.any(record.rawMessage.startsWith);

  @override
  void handle(LogRecord record) {
    _entries.add(
      'at=${utcClock()} focus=${describeFocusKey(FocusManager.instance.primaryFocus)} '
      '${record.rawMessage}',
    );
    if (_entries.length > _maxEntries) _entries.removeAt(0);
  }

  void dump() {
    for (var i = 0; i < _entries.length; i++) {
      debugPrintSynchronously('[APP LOG] $i ${_entries[i]}');
    }
  }
}
