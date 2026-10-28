import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:patrol/patrol.dart';

// Keeps the dump under the logcat buffer limit; the top route prints last, so keep the tail.
const _maxTreeLines = 1500;

// One print per line: the web console forwarder keeps only the first line of a message.
void _printLines(String text, {int? maxLines}) {
  final lines = text.split('\n');
  final shown = maxLines == null || lines.length <= maxLines
      ? lines
      : lines.skip(lines.length - maxLines);
  for (final line in shown) {
    debugPrintSynchronously(line);
  }
}

// debugPrint, not dart:developer log: the latter is not written to Android logcat.
void dumpFailureState(PatrolIntegrationTester $) {
  try {
    final views = WidgetsBinding.instance.platformDispatcher.views;
    final keyboardInset = views.isEmpty ? 'n/a' : '${views.first.viewInsets.bottom}';
    final summary = '[FAILURE STATE] route=${Get.currentRoute} '
        'focus=${FocusManager.instance.primaryFocus} keyboardInset=$keyboardInset';
    $.log(summary);
    debugPrintSynchronously(summary);
    _printLines(FocusManager.instance.toStringDeep());
    _printLines(
      WidgetsBinding.instance.rootElement?.toStringDeep() ?? 'no root element',
      maxLines: _maxTreeLines,
    );
  } catch (e) {
    debugPrintSynchronously('[FAILURE STATE] dump failed: $e');
  }
}
