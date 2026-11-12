import 'dart:js_interop';

import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:web/web.dart' as web;

import 'stack_lines_printer.dart';

String _describe(web.EventTarget? target) {
  if (target == null) return 'null';
  if (!target.isA<web.Element>()) return 'non-element';
  final element = target as web.Element;
  final platformView = element.closest('flt-platform-view');
  return '${element.tagName} connected=${element.isConnected} '
      'pv=${platformView?.getAttribute('slot')}';
}

String describeDomActiveElement() {
  try {
    return _describe(web.document.activeElement);
  } catch (e) {
    return 'describe failed: $e';
  }
}

// Shows which browser focus move makes the engine report a view focus change mid-frame.
void Function() startDomFocusLogging() {
  void log(String type, web.FocusEvent event) {
    try {
      debugPrintSynchronously('[DOM FOCUS] $type '
          'phase=${SchedulerBinding.instance.schedulerPhase.name} '
          'target=${_describe(event.target)} related=${_describe(event.relatedTarget)} '
          'active=${_describe(web.document.activeElement)}');
      // A mid-frame focus move comes from framework code; its stack names the caller.
      if (SchedulerBinding.instance.schedulerPhase != SchedulerPhase.idle) {
        printStackLines('[DOM FOCUS STACK]');
      }
    } catch (e) {
      debugPrintSynchronously('[DOM FOCUS] log failed: $e');
    }
  }

  final onFocusIn = ((web.FocusEvent event) => log('focusin', event)).toJS;
  final onFocusOut = ((web.FocusEvent event) => log('focusout', event)).toJS;
  web.document.addEventListener('focusin', onFocusIn, true.toJS);
  web.document.addEventListener('focusout', onFocusOut, true.toJS);
  return () {
    web.document.removeEventListener('focusin', onFocusIn, true.toJS);
    web.document.removeEventListener('focusout', onFocusOut, true.toJS);
  };
}
