// Runs each focus scenario twice, with and without the FocusScope that
// lib/main.dart puts around FlutterSmartDialog.init(), and requires the same
// focus owner after every step. Which scope node owns focus after an unfocus()
// may differ; which field owns it, and every shortcut and traversal, may not.
// The scenarios cover what the e2e suite does not: Tab traversal, the browser
// handing focus back to the View, SmartDialog autofocus and unfocus() from
// contexts outside any route.
// Differential test: run the same scenarios with and without the FocusScope
// wrapper of lib/main.dart and compare focus behaviour step by step.
import 'dart:async';
import 'dart:ui' show ViewFocusDirection, ViewFocusEvent, ViewFocusState;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

typedef Trace = List<String>;
String norm(String s) =>
    s.replaceAll(RegExp(r'scope\(.*?\)(?=\s|$)|rootScope'), 'SCOPE');

String _d(FocusNode? n) {
  if (n == null) return 'null';
  if (n == FocusManager.instance.rootScope) return 'rootScope';
  if (n is FocusScopeNode) {
    return 'scope(${n.debugLabel ?? n.context?.widget.runtimeType})';
  }
  return n.debugLabel ?? 'node';
}

class Harness {
  Harness(this.wrap, this.tester);
  final bool wrap;
  final WidgetTester tester;
  final Trace trace = [];
  final smart = FlutterSmartDialog.init();
  late BuildContext pageCtx;
  BuildContext? dialogCtx;
  final f1 = FocusNode(debugLabel: 'f1');
  final f2 = FocusNode(debugLabel: 'f2');
  final f3 = FocusNode(debugLabel: 'f3');
  int shortcutHits = 0;

  void rec(String step) =>
      trace.add('$step -> ${_d(FocusManager.instance.primaryFocus)}');

  Widget field(FocusNode n, {bool autofocus = false}) =>
      TextField(focusNode: n, autofocus: autofocus);

  Widget page(String name, List<Widget> kids) => Shortcuts(
    shortcuts: {
      LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyK):
          const _Hit(),
    },
    child: Actions(
      actions: {
        _Hit: CallbackAction<_Hit>(
          onInvoke: (_) {
            shortcutHits++;
            return null;
          },
        ),
      },
      child: Scaffold(
        body: Builder(
          builder: (c) {
            pageCtx = c;
            return Column(children: kids);
          },
        ),
      ),
    ),
  );

  Future<void> pump() async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 400));
  }

  Future<void> start() async {
    await tester.pumpWidget(
      GetMaterialApp(
        navigatorObservers: [FlutterSmartDialog.observer],
        defaultTransition: Transition.noTransition,
        home: page('home', [field(f1), field(f2), field(f3)]),
        builder: wrap
            ? (c, child) =>
                  FocusScope(debugLabel: 'WRAP', child: smart(c, child))
            : smart,
      ),
    );
    await pump();
  }

  Future<void> key(
    LogicalKeyboardKey k, {
    bool ctrl = false,
    bool shift = false,
  }) async {
    if (ctrl) await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    if (shift) await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
    await tester.sendKeyEvent(k);
    if (shift) await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
    if (ctrl) await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    await pump();
  }
}

class _Hit extends Intent {
  const _Hit();
}

final Map<String, Future<void> Function(Harness h)> scenarios = {
  'tap field then Tab / Shift+Tab traversal': (h) async {
    await h.tester.tap(find.byType(TextField).first);
    await h.pump();
    h.rec('tap f1');
    await h.key(LogicalKeyboardKey.tab);
    h.rec('Tab');
    await h.key(LogicalKeyboardKey.tab);
    h.rec('Tab');
    await h.key(LogicalKeyboardKey.tab, shift: true);
    h.rec('Shift+Tab');
  },
  'route-level shortcut fires with focus in field and after unfocus':
      (h) async {
        await h.tester.tap(find.byType(TextField).first);
        await h.pump();
        await h.key(LogicalKeyboardKey.keyK, ctrl: true);
        h.trace.add('ctrl+K in field hits=${h.shortcutHits}');
        FocusManager.instance.primaryFocus?.unfocus();
        await h.pump();
        h.rec('unfocus()');
        await h.key(LogicalKeyboardKey.keyK, ctrl: true);
        h.trace.add('ctrl+K after unfocus hits=${h.shortcutHits}');
      },
  'FocusScope.of(ctx).unfocus() from page / Get.context / overlay ctx':
      (h) async {
        await h.tester.tap(find.byType(TextField).first);
        await h.pump();
        h.rec('tap f1');
        FocusScope.of(h.pageCtx).unfocus();
        await h.pump();
        h.rec('unfocus via page ctx');
        await h.tester.tap(find.byType(TextField).first);
        await h.pump();
        FocusScope.of(Get.context!).unfocus();
        await h.pump();
        h.rec('unfocus via Get.context');
        await h.tester.tap(find.byType(TextField).first);
        await h.pump();
        SmartDialog.show(
          builder: (c) {
            h.dialogCtx = c;
            return const SizedBox(width: 50, height: 50);
          },
        );
        await h.pump();
        FocusScope.of(h.dialogCtx!).unfocus();
        await h.pump();
        h.rec('unfocus via SmartDialog ctx');
        unawaited(SmartDialog.dismiss());
        await h.pump();
        await h.tester.tap(find.byType(TextField).first);
        await h.pump();
        h.rec('retap f1');
        await h.key(LogicalKeyboardKey.tab);
        h.rec('Tab after');
      },
  'push route then pop restores previous focus': (h) async {
    await h.tester.tap(find.byType(TextField).at(1));
    await h.pump();
    h.rec('tap f2');
    Get.to(
      () => h.page('second', [
        h.field(FocusNode(debugLabel: 's1'), autofocus: true),
      ]),
    );
    await h.pump();
    h.rec('pushed route w/ autofocus');
    Get.back();
    await h.pump();
    h.rec('popped');
    await h.key(LogicalKeyboardKey.tab);
    h.rec('Tab after pop');
  },
  'showDialog (route) with autofocus field then close': (h) async {
    await h.tester.tap(find.byType(TextField).at(2));
    await h.pump();
    h.rec('tap f3');
    Get.dialog(
      AlertDialog(
        content: h.field(FocusNode(debugLabel: 'd1'), autofocus: true),
      ),
    );
    await h.pump();
    h.rec('dialog open');
    Get.back();
    await h.pump();
    h.rec('dialog closed');
  },
  'SmartDialog with autofocus field while page field focused': (h) async {
    await h.tester.tap(find.byType(TextField).at(0));
    await h.pump();
    h.rec('tap f1');
    SmartDialog.show(
      builder: (c) => Material(
        child: SizedBox(
          width: 200,
          child: h.field(FocusNode(debugLabel: 'sd1'), autofocus: true),
        ),
      ),
    );
    await h.pump();
    h.rec('SmartDialog open (autofocus)');
    await h.tester.tap(find.byType(TextField).last);
    await h.pump();
    h.rec('tap sd field');
    await h.key(LogicalKeyboardKey.tab);
    h.rec('Tab in SmartDialog');
    unawaited(SmartDialog.dismiss());
    await h.pump();
    h.rec('SmartDialog dismissed');
  },
  'SmartDialog with autofocus field while NOTHING focused': (h) async {
    SmartDialog.show(
      builder: (c) => Material(
        child: SizedBox(
          width: 200,
          child: h.field(FocusNode(debugLabel: 'sd1'), autofocus: true),
        ),
      ),
    );
    await h.pump();
    h.rec('SmartDialog open (nothing focused before)');
    unawaited(SmartDialog.dismiss());
    await h.pump();
    h.rec('dismissed');
  },
  'toast / loading do not move focus': (h) async {
    await h.tester.tap(find.byType(TextField).at(1));
    await h.pump();
    h.rec('tap f2');
    SmartDialog.showToast('hi');
    await h.pump();
    h.rec('toast');
    SmartDialog.showLoading();
    await h.pump();
    h.rec('loading');
    unawaited(SmartDialog.dismiss());
    await h.pump();
    h.rec('loading dismissed');
    await h.tester.pump(const Duration(seconds: 4));
  },
  'browser tab regains view focus (forward / backward / undefined)': (h) async {
    final vid = h.tester.view.viewId;
    for (final dir in [
      ViewFocusDirection.forward,
      ViewFocusDirection.backward,
      ViewFocusDirection.undefined,
    ]) {
      FocusManager.instance.primaryFocus?.unfocus();
      await h.pump();
      WidgetsBinding.instance.handleViewFocusChanged(
        ViewFocusEvent(
          viewId: vid,
          state: ViewFocusState.focused,
          direction: dir,
        ),
      );
      await h.pump();
      h.rec('view focused $dir');
    }
    await h.tester.tap(find.byType(TextField).at(1));
    await h.pump();
    WidgetsBinding.instance.handleViewFocusChanged(
      ViewFocusEvent(
        viewId: vid,
        state: ViewFocusState.unfocused,
        direction: ViewFocusDirection.undefined,
      ),
    );
    await h.pump();
    h.rec('view unfocused');
    WidgetsBinding.instance.handleViewFocusChanged(
      ViewFocusEvent(
        viewId: vid,
        state: ViewFocusState.focused,
        direction: ViewFocusDirection.undefined,
      ),
    );
    await h.pump();
    h.rec('view refocused');
  },
  'Escape key with nothing focused reaches app-level handler': (h) async {
    await h.tester.pumpWidget(
      GetMaterialApp(
        navigatorObservers: [FlutterSmartDialog.observer],
        home: Scaffold(body: Center(child: h.field(h.f1))),
        builder: (c, child) {
          Widget out = h.smart(c, child);
          if (h.wrap) out = FocusScope(debugLabel: 'WRAP', child: out);
          return Shortcuts(
            shortcuts: {LogicalKeySet(LogicalKeyboardKey.escape): const _Hit()},
            child: Actions(
              actions: {
                _Hit: CallbackAction<_Hit>(
                  onInvoke: (_) {
                    h.shortcutHits++;
                    return null;
                  },
                ),
              },
              child: out,
            ),
          );
        },
      ),
    );
    await h.pump();
    await h.key(LogicalKeyboardKey.escape);
    h.trace.add('esc nothing focused hits=${h.shortcutHits}');
    await h.tester.tap(find.byType(TextField));
    await h.pump();
    await h.key(LogicalKeyboardKey.escape);
    h.trace.add('esc in field hits=${h.shortcutHits}');
  },
};

void main() {
  for (final e in scenarios.entries) {
    testWidgets(e.key, (tester) async {
      Get.reset();
      final a = Harness(false, tester);
      await a.start();
      await e.value(a);
      final withoutWrapper = List<String>.from(a.trace);
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 5));
      Get.reset();
      final b = Harness(true, tester);
      await b.start();
      await e.value(b);
      final diffs = <String>[];
      for (var i = 0; i < withoutWrapper.length || i < b.trace.length; i++) {
        final x = i < withoutWrapper.length ? withoutWrapper[i] : '<none>';
        final y = i < b.trace.length ? b.trace[i] : '<none>';
        if (x != y && norm(x) != norm(y)) diffs.add('$x  vs  $y');
      }
      expect(
        diffs,
        isEmpty,
        reason: 'behaviour differs with the FocusScope wrapper',
      );
    });
  }
}
