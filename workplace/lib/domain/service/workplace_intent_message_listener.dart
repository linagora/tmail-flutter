import 'dart:async';

import 'package:universal_html/html.dart' as html;
import 'package:workplace/domain/message/workplace_intent_message.dart';

class WorkplaceIntentMessageListener {
  final String intentId;

  StreamSubscription<html.MessageEvent>? _subscription;
  final StreamController<WorkplaceIntentMessage> _controller =
      StreamController<WorkplaceIntentMessage>.broadcast();

  WorkplaceIntentMessageListener({required this.intentId});

  Stream<WorkplaceIntentMessage> get messages {
    _subscription ??= html.window.onMessage.listen(_onMessage);
    return _controller.stream;
  }

  void _onMessage(html.MessageEvent event) {
    final data = event.data;
    if (data is! String) return;
    try {
      final message = WorkplaceIntentMessage.parse(intentId, data);
      _controller.add(message);
    } catch (_) {
      // Ignore unparseable messages
    }
  }

  void dispose() {
    _subscription?.cancel();
    _subscription = null;
    _controller.close();
  }
}
