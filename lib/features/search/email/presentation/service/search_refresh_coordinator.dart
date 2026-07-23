import 'dart:async';

import 'package:jmap_dart_client/jmap/core/state.dart' as jmap;
import 'package:tmail_ui_user/features/push_notification/presentation/websocket/web_socket_message.dart';
import 'package:tmail_ui_user/features/push_notification/presentation/websocket/web_socket_queue_handler.dart';
import 'package:tmail_ui_user/features/search/email/domain/execution/search_execution_intent.dart';
import 'package:tmail_ui_user/features/search/email/domain/execution/search_execution_result.dart';
import 'package:tmail_ui_user/features/search/email/presentation/service/email_state_change_source.dart';
import 'package:tmail_ui_user/features/search/email/presentation/service/search_dispatch_context.dart';
import 'package:tmail_ui_user/features/search/email/presentation/service/search_executor_service.dart';

/// Resolves the current search dispatch context, if available.
typedef SearchDispatchContextResolver = SearchDispatchContext? Function();

/// Reports whether a search session is currently running (any platform/width),
/// so refresh results can be applied.
typedef SearchRunningPredicate = bool Function();

/// Returns the number of currently loaded search results.
typedef SearchResultCountResolver = int Function();

/// Handles unexpected refresh errors.
typedef SearchRefreshErrorHandler = void Function(
  dynamic error,
  StackTrace stackTrace,
);

/// Runtime callbacks used by [SearchRefreshCoordinator].
class SearchRefreshCoordinatorCallbacks {
  const SearchRefreshCoordinatorCallbacks({
    required this.resolveDispatchContext,
    required this.isSearchRunning,
    required this.resolveResultCount,
    this.onError,
  });

  final SearchDispatchContextResolver resolveDispatchContext;
  final SearchRunningPredicate isSearchRunning;
  final SearchResultCountResolver resolveResultCount;
  final SearchRefreshErrorHandler? onError;
}

/// Owns websocket-driven refreshes for the active search.
class SearchRefreshCoordinator {
  static const _maxRetryAttempts = 3;
  static const _retryDelay = Duration(milliseconds: 200);

  /// Subscribes to [stateSource] and serializes refresh dispatches.
  SearchRefreshCoordinator({
    required SearchExecutorService executor,
    required EmailStateChangeSource stateSource,
    required SearchRefreshCoordinatorCallbacks callbacks,
  })  : _executor = executor,
        _stateSource = stateSource,
        _callbacks = callbacks {
    _queue = WebSocketQueueHandler(
      processMessageCallback: _processMessage,
      onErrorCallback: callbacks.onError,
      retryMessageCallback: _retryMessage,
    );
    _subscription = _stateSource.onEmailStateChanged.listen(_enqueue);
  }

  final SearchExecutorService _executor;
  final EmailStateChangeSource _stateSource;
  final SearchRefreshCoordinatorCallbacks _callbacks;

  late final WebSocketQueueHandler _queue;
  StreamSubscription<jmap.State>? _subscription;
  final _inFlightStateIds = <String>{};
  final _retryAttempts = <String, int>{};
  final _retryTimers = <String, Timer>{};
  bool _disposed = false;

  /// Adds a state change to the serialized queue.
  void _enqueue(jmap.State state) {
    if (_disposed) return;
    if (state == _stateSource.currentAppliedState) return;
    final message = WebSocketMessage(newState: state);
    if (_isStateKnown(message.id)) return;
    _queue.enqueue(message);
  }

  bool _isStateKnown(String stateId) {
    if (_inFlightStateIds.contains(stateId)) return true;
    if (_retryTimers.containsKey(stateId)) return true;
    if (_queue.isMessageQueued(stateId)) return true;
    return _queue.isMessageProcessed(stateId);
  }

  /// Dispatches one refresh for a queued state change.
  Future<void> _processMessage(WebSocketMessage message) async {
    _inFlightStateIds.add(message.id);
    try {
      if (!_canProcessMessage()) return;
      final context = _callbacks.resolveDispatchContext();
      if (context == null) {
        throw StateError('Search dispatch context is unavailable');
      }

      final result = await _executor.dispatch(
        RefreshChangesIntent(currentCount: _callbacks.resolveResultCount()),
        context,
      );
      if (result == SearchExecutionResult.failure) {
        throw StateError('Search refresh failed');
      }
      _retryAttempts.remove(message.id);
    } finally {
      _inFlightStateIds.remove(message.id);
    }
  }

  bool _canProcessMessage() {
    if (_disposed) return false;
    return _callbacks.isSearchRunning();
  }

  bool _retryMessage(
    WebSocketMessage message,
    dynamic _,
    StackTrace __,
  ) {
    if (_disposed) return false;
    if (_retryTimers.containsKey(message.id)) return true;

    final attempts = (_retryAttempts[message.id] ?? 0) + 1;
    if (attempts > _maxRetryAttempts) {
      _retryAttempts.remove(message.id);
      return false;
    }

    _retryAttempts[message.id] = attempts;
    _retryTimers[message.id] = Timer(_retryDelay, () {
      _retryTimers.remove(message.id);
      if (!_canEnqueueRetry(message.id)) return;
      _queue.enqueue(message);
    });
    return true;
  }

  bool _canEnqueueRetry(String stateId) {
    if (_disposed) return false;
    if (_inFlightStateIds.contains(stateId)) return false;
    return !_queue.isMessageQueued(stateId);
  }

  /// Cancels the source subscription and releases the queue.
  void dispose() {
    if (_disposed) return;
    _disposed = true;
    _subscription?.cancel();
    _subscription = null;
    for (final timer in _retryTimers.values) {
      timer.cancel();
    }
    _retryTimers.clear();
    _retryAttempts.clear();
    _inFlightStateIds.clear();
    _queue.dispose();
  }
}
