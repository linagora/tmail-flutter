import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

const _maxEntries = 20;
const _maxAncestors = 24;

// Buffers primary focus changes; printed on failure to name a focus node that left the tree.
class PrimaryFocusLogger {
  PrimaryFocusLogger._();

  static final instance = PrimaryFocusLogger._();

  final _entries = <String>[];
  FocusNode? _last;

  void start() {
    _entries.clear();
    _last = null;
    FocusManager.instance.addListener(_onFocusChanged);
  }

  void stop() => FocusManager.instance.removeListener(_onFocusChanged);

  void _onFocusChanged() {
    final node = FocusManager.instance.primaryFocus;
    if (identical(node, _last)) return;
    _last = node;
    _entries.add('phase=${SchedulerBinding.instance.schedulerPhase.name} ${_describe(node)}');
    if (_entries.length > _maxEntries) _entries.removeAt(0);
  }

  void dump() {
    debugPrintSynchronously('[PRIMARY FOCUS] now ${_describe(FocusManager.instance.primaryFocus)}');
    for (var i = 0; i < _entries.length; i++) {
      debugPrintSynchronously('[PRIMARY FOCUS] history $i ${_entries[i]}');
    }
  }
}

String _describe(FocusNode? node) {
  if (node == null) return 'null';
  try {
    final context = node.context;
    return 'id=${identityHashCode(node)} ${node.runtimeType} label=${node.debugLabel} '
        'parent=${node.parent?.runtimeType} mounted=${context?.mounted} '
        'chain=${context is Element ? _chain(context) : 'no context'}';
  } catch (e) {
    return 'id=${identityHashCode(node)} describe failed: $e';
  }
}

// An unmounted element keeps its parent links but its widget getter throws.
String _widgetName(Element element) {
  try {
    return element.widget.runtimeType.toString();
  } catch (_) {
    return '${element.runtimeType}(unmounted)';
  }
}

String _chain(Element element) {
  final names = [_widgetName(element)];
  try {
    element.visitAncestorElements((ancestor) {
      names.add(_widgetName(ancestor));
      return names.length < _maxAncestors;
    });
  } catch (e) {
    names.add('walk failed: $e');
  }
  return names.join(' < ');
}
