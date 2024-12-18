
import 'dart:collection';
import 'package:core/utils/app_logger.dart';
import 'package:jmap_dart_client/jmap/core/state.dart' as jmap;

class MailboxStateManager {
  final Queue<jmap.State> _stateQueue = Queue<jmap.State>();
  bool _isProcessing = false;

  void addState(jmap.State newState) {
    _stateQueue.add(newState);
  }

  Queue<jmap.State> get stateQueue => _stateQueue;

  bool get isProcessing => _isProcessing;

  void startProcessing() => _isProcessing = true;

  void stopProcessing() => _isProcessing = false;

  bool isQueueNotEmpty() => _stateQueue.isNotEmpty;

  jmap.State getFirstState() => _stateQueue.removeFirst();

  void removeStatesUpToCurrent(jmap.State currentState) {
    if (!stateQueue.contains(currentState)) {
      log('MailboxStateManager::removeStatesUpToCurrent:Current state $currentState not found in the queue.');
      return;
    }
    while (stateQueue.isNotEmpty) {
      final removedState = stateQueue.removeFirst();
      if (removedState == currentState) {
        break;
      }
    }
    log('MailboxStateManager::removeStatesUpToCurrent:Updated Queue: $stateQueue');
  }

  void dispose() {
    _isProcessing = false;
    _stateQueue.clear();
  }
}