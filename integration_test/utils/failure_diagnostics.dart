import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart' show find;
import 'package:get/get.dart';
import 'package:labels/labels.dart';
import 'package:patrol/patrol.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/widgets/sidebar/sidebar_label_item.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

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

// The web console forwarder keeps only the first line of a message; print the whole error.
void logFlutterErrorDetails(FlutterErrorDetails details) {
  try {
    debugPrintSynchronously(
      '[FLUTTER ERROR] ${details.exceptionAsString()} '
      'library=${details.library} context=${details.context?.toDescription()}',
    );
    _printLines(details.stack?.toString() ?? 'no stack');
  } catch (e) {
    debugPrintSynchronously('[FLUTTER ERROR] log failed: $e');
  }
}

void _printLabelState() {
  try {
    final lc = getBinding<MailboxDashBoardController>()?.labelController;
    List<String> names(Iterable<Element> elements) => elements
        .map((e) => (e.widget as SidebarLabelItem).label.safeDisplayName)
        .toList();
    final items = names(find.byType(SidebarLabelItem).evaluate());
    final hit = names(find.byType(SidebarLabelItem).hitTestable().evaluate());
    debugPrintSynchronously('[FAILURE STATE] labels enabled=${lc?.isLabelSettingEnabled.value} '
        'loaded=${lc?.isLabelsLoaded.value} expand=${lc?.labelListExpandMode.value} '
        'ctrl=${lc?.labels.map((l) => l.safeDisplayName).toList()} items=$items hitTestable=$hit');
  } catch (e) {
    debugPrintSynchronously('[FAILURE STATE] label state failed: $e');
  }
}

var _dumped = false;

// A test dumps once: the error hook and the test's catch block both call it.
void resetFailureDump() => _dumped = false;

// debugPrint, not dart:developer log: the latter is not written to Android logcat.
void dumpFailureState(PatrolIntegrationTester $) {
  if (_dumped) return;
  _dumped = true;
  try {
    final views = WidgetsBinding.instance.platformDispatcher.views;
    final keyboardInset = views.isEmpty ? 'n/a' : '${views.first.viewInsets.bottom}';
    final summary = '[FAILURE STATE] route=${Get.currentRoute} '
        'focus=${FocusManager.instance.primaryFocus} keyboardInset=$keyboardInset';
    $.log(summary);
    debugPrintSynchronously(summary);
    _printLabelState();
    _printLines(FocusManager.instance.toStringDeep());
    _printLines(
      WidgetsBinding.instance.rootElement?.toStringDeep() ?? 'no root element',
      maxLines: _maxTreeLines,
    );
  } catch (e) {
    debugPrintSynchronously('[FAILURE STATE] dump failed: $e');
  }
}
