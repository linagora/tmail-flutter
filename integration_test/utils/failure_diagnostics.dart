import 'dart:ui' show ViewFocusEvent;

import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:patrol/patrol.dart';

import 'dom_focus_logger.dart';

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

const _maxAncestors = 24;

String _ancestorChain(BuildContext context) {
  final types = <String>[context.widget.runtimeType.toString()];
  context.visitAncestorElements((element) {
    types.add(element.widget.runtimeType.toString());
    return types.length < _maxAncestors;
  });
  return types.join(' < ');
}

// Topmost detached render ancestor tells whether the subtree was dropped from its parent.
String _detachedRoot(RenderObject renderObject) {
  var top = renderObject;
  while (top.parent != null && !top.parent!.attached) {
    top = top.parent!;
  }
  return '${top.runtimeType} renderParent=${top.parent?.runtimeType}';
}

// A deactivated subtree loses its parent link until finalizeTree unmounts it.
bool _reachesRootElement(BuildContext context) {
  Element? top;
  context.visitAncestorElements((element) {
    top = element;
    return true;
  });
  return top == WidgetsBinding.instance.rootElement;
}

String _describeFocusNode(FocusNode node) {
  final context = node.context;
  if (context == null) return '${node.runtimeType} context=null';
  if (!context.mounted) return '${node.runtimeType} mounted=false';
  final renderObject = context.findRenderObject();
  final detached = renderObject != null && !renderObject.attached
      ? ' detachedRoot=${_detachedRoot(renderObject)}'
      : '';
  return '${node.runtimeType} canFocus=${node.canRequestFocus} '
      'skip=${node.skipTraversal} primary=${node.hasPrimaryFocus} '
      'ro=${renderObject.runtimeType} attached=${renderObject?.attached}$detached '
      'inTree=${_reachesRootElement(context)} '
      'chain=${_ancestorChain(context)}';
}

// Profile web builds print diagnostics as "Instance of ...", so list focus nodes field by field.
void _dumpFocusNodes() {
  final root = FocusManager.instance.rootScope;
  final nodes = [root, ...root.descendants];
  for (var i = 0; i < nodes.length; i++) {
    try {
      debugPrintSynchronously('[FOCUS NODE] $i ${_describeFocusNode(nodes[i])}');
    } catch (e) {
      debugPrintSynchronously('[FOCUS NODE] $i describe failed: $e');
    }
  }
}

bool _hasDetachedRenderObject(FocusNode node) {
  final context = node.context;
  if (context == null || !context.mounted) return false;
  final renderObject = context.findRenderObject();
  return renderObject != null && !renderObject.attached;
}

// Logs the browser focus event that makes the framework re-sort focus nodes.
class ViewFocusLogger with WidgetsBindingObserver {
  @override
  void didChangeViewFocus(ViewFocusEvent event) {
    try {
      final detached = FocusManager.instance.rootScope.descendants
          .where(_hasDetachedRenderObject)
          .toList();
      debugPrintSynchronously('[VIEW FOCUS] view=${event.viewId} '
          'state=${event.state.name} direction=${event.direction.name} '
          'phase=${SchedulerBinding.instance.schedulerPhase.name} detached=${detached.length} dom=${describeDomActiveElement()}');
      // These are the nodes the View's own handler is about to sort.
      for (final node in detached) {
        debugPrintSynchronously('[VIEW FOCUS DETACHED] ${_describeFocusNode(node)}');
      }
    } catch (e) {
      debugPrintSynchronously('[VIEW FOCUS] log failed: $e');
    }
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

// debugPrint, not dart:developer log: the latter is not written to Android logcat.
void dumpFailureState(PatrolIntegrationTester $) {
  try {
    final views = WidgetsBinding.instance.platformDispatcher.views;
    final keyboardInset = views.isEmpty ? 'n/a' : '${views.first.viewInsets.bottom}';
    final summary = '[FAILURE STATE] route=${Get.currentRoute} '
        'focus=${FocusManager.instance.primaryFocus?.runtimeType} keyboardInset=$keyboardInset';
    $.log(summary);
    debugPrintSynchronously(summary);
    _dumpFocusNodes();
    _printLines(FocusManager.instance.toStringDeep());
    _printLines(
      WidgetsBinding.instance.rootElement?.toStringDeep() ?? 'no root element',
      maxLines: _maxTreeLines,
    );
  } catch (e) {
    debugPrintSynchronously('[FAILURE STATE] dump failed: $e');
  }
}
