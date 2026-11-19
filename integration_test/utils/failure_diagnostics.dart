import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart' show find;
import 'package:get/get.dart';
import 'package:labels/labels.dart';
import 'package:patrol/patrol.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/base_mailbox_view.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/extensions/presentation_mailbox_extension.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/widgets/sidebar/sidebar_label_item.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/extensions/labels/handle_logic_label_extension.dart';
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

String describeLabelState() {
  try {
    final dashboard = getBinding<MailboxDashBoardController>();
    final lc = dashboard?.labelController;
    final sel = dashboard?.selectedMailboxForDisplay;
    List<String> names(Iterable<Element> elements, {bool selectedOnly = false}) =>
        elements
            .map((e) => e.widget as SidebarLabelItem)
            .where((w) => !selectedOnly || w.isSelected)
            .map((w) => w.label.safeDisplayName)
            .toList();
    final all = find.byType(SidebarLabelItem).evaluate();
    final hit = find.byType(SidebarLabelItem).hitTestable().evaluate();
    final sidebar = find
        .descendant(
          of: find.byWidgetPredicate((w) => w is BaseMailboxView),
          matching: find.byType(Scrollable),
        )
        .evaluate()
        .firstOrNull;
    final pos = sidebar == null
        ? null
        : ((sidebar as StatefulElement).state as ScrollableState).position;
    final scroll = pos == null
        ? 'none'
        : '${pos.pixels}/${pos.maxScrollExtent} vp=${pos.viewportDimension}';
    final firstIsSidebar =
        find.byType(Scrollable).evaluate().firstOrNull == sidebar;
    final header = lc == null
        ? null
        : find.byKey(lc.labelAppBarKey).evaluate().isNotEmpty;
    return 'available=${dashboard?.isLabelAvailable} '
        'enabled=${lc?.isLabelSettingEnabled.value} loaded=${lc?.isLabelsLoaded.value} '
        'expand=${lc?.labelListExpandMode.value} '
        'ctrl=${lc?.labels.map((l) => l.safeDisplayName).toList()} '
        'ctrlIds=${lc?.labels.map((l) => l.id?.value).toList()} '
        'selected=${sel?.id.id.value} isLabel=${sel?.isLabelMailbox} labelId=${sel?.labelId?.value} '
        'items=${names(all)} hitTestable=${names(hit)} '
        'selectedItems=${names(all, selectedOnly: true)} header=$header '
        'sidebarScroll=$scroll firstScrollableIsSidebar=$firstIsSidebar';
  } catch (e) {
    return 'label state failed: $e';
  }
}

void _printLabelState() =>
    debugPrintSynchronously('[FAILURE STATE] ${describeLabelState()}');

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
