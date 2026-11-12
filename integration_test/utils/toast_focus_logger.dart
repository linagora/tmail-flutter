import 'package:core/presentation/views/toast/tmail_toast.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

// Logs, per frame, when a toast focus node enters or leaves the focus tree, to line it up with view focus crashes.
class ToastFocusLogger {
  final _toastNodes = <FocusNode>{};
  final _isToastCache = Expando<bool>();
  bool _active = true;
  int _frame = 0;

  void start() => SchedulerBinding.instance.addPersistentFrameCallback(_onFrame);

  // Persistent callbacks cannot be removed.
  void stop() => _active = false;

  void _onFrame(Duration _) {
    if (!_active) return;
    _frame++;
    try {
      final current = FocusManager.instance.rootScope.descendants.where(_isToastNode).toSet();
      for (final node in current.difference(_toastNodes)) {
        debugPrintSynchronously('[TOAST FOCUS] added frame=$_frame text=${_toastText(node)}');
      }
      for (final _ in _toastNodes.difference(current)) {
        debugPrintSynchronously('[TOAST FOCUS] removed frame=$_frame');
      }
      _toastNodes
        ..clear()
        ..addAll(current);
    } catch (e) {
      debugPrintSynchronously('[TOAST FOCUS] log failed: $e');
    }
  }

  bool _isToastNode(FocusNode node) {
    final cached = _isToastCache[node];
    if (cached != null) return cached;
    // A node without a mounted context has no ancestors yet; check again next frame.
    final context = node.context;
    if (context == null || !context.mounted) return false;
    return _isToastCache[node] = _findToastCard(context) != null;
  }

  Element? _findToastCard(BuildContext context) {
    Element? card;
    context.visitAncestorElements((element) {
      if (element.widget is ToastCard) card = element;
      return card == null;
    });
    return card;
  }

  String _toastText(FocusNode node) {
    final context = node.context;
    final card = context == null ? null : _findToastCard(context);
    if (card == null) return 'n/a';
    final texts = <String>[];
    void visit(Element element) {
      final widget = element.widget;
      if (widget is Text) texts.add(widget.data ?? '');
      element.visitChildren(visit);
    }
    card.visitChildren(visit);
    return texts.join(' | ');
  }
}
