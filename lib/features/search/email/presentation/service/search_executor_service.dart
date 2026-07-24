import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tmail_ui_user/features/base/handle_urgent_exception.dart';
import 'package:tmail_ui_user/features/search/email/domain/execution/search_execution_intent.dart';
import 'package:tmail_ui_user/features/search/email/domain/execution/search_execution_result.dart';
import 'package:tmail_ui_user/features/search/email/domain/model/search_email_result.dart';
import 'package:tmail_ui_user/features/search/email/domain/notifier/search_email_notifier.dart';
import 'package:tmail_ui_user/features/search/email/presentation/service/search_dispatch_context.dart';
import 'package:tmail_ui_user/features/search/email/presentation/service/search_execution_observer.dart';

/// Single owner of the search executor: dispatches intents and fans each
/// [searchEmailProvider] result out to registered observers. Holds no view
/// state and does not know how many observers exist. See ADR-0092/0093.
class SearchExecutorService {
  SearchExecutorService(this._container);

  final ProviderContainer _container;
  final Set<SearchExecutionObserver> _observers = <SearchExecutionObserver>{};
  ProviderSubscription<AsyncValue<SearchEmailResult>>? _subscription;
  bool _hasDispatchedSearch = false;
  SearchExecutionIntent? _lastDispatchedIntent;
  bool _disposed = false;

  SearchEmailNotifier get _notifier =>
      _container.read(searchEmailProvider.notifier);

  /// Registers [observer], opens the executor subscription on the first one,
  /// and replays the current state when a search has already been dispatched.
  void register(SearchExecutionObserver observer) {
    if (_disposed) return;
    final isNewObserver = _observers.add(observer);
    _ensureSubscription();
    if (isNewObserver && _hasDispatchedSearch) {
      _notifyCurrentState(observer);
    }
  }

  /// Unregisters [observer]; closes the subscription once none remain.
  void unregister(SearchExecutionObserver observer) {
    if (_disposed) return;
    _observers.remove(observer);
    if (_observers.isEmpty) _closeSubscription();
  }

  /// Replays the executor's current state to every registered observer.
  ///
  /// Used when responsive layouts hand an active search between presentation
  /// stores without executing the search again.
  void replayCurrentStateToOwners() {
    if (_disposed || !_hasDispatchedSearch) return;
    _notifyObservers(_notifyCurrentState);
  }

  /// Runs [intent] via the executor; a new search first resets its observers.
  /// The returned future completes when the executor finishes (awaited by the
  /// websocket-refresh path to order message-dedup after the refresh).
  Future<SearchExecutionResult> dispatch(
    SearchExecutionIntent intent,
    SearchDispatchContext context,
  ) {
    if (_disposed) return Future.value(SearchExecutionResult.superseded);
    _ensureSubscription();
    _hasDispatchedSearch = true;
    _lastDispatchedIntent = intent;
    if (intent is NewSearchIntent) {
      _notifyObservers((observer) => observer.onNewSearchStarted());
    }
    return _notifier.execute(
      intent,
      session: context.session,
      accountId: context.accountId,
      properties: context.properties,
      collapseThreads: context.collapseThreads,
      trashSpamMailboxIds: context.trashSpamMailboxIds,
    );
  }

  void dispose() {
    if (_disposed) return;
    _disposed = true;
    _closeSubscription();
    _observers.clear();
  }

  /// Clears the replay marker when the dashboard session ends.
  void resetSession() {
    if (_disposed) return;
    _closeSubscription();
    _hasDispatchedSearch = false;
    _lastDispatchedIntent = null;
  }

  void _ensureSubscription() {
    if (_observers.isEmpty) return;
    _subscription ??=
        _container.listen(searchEmailProvider, _onExecutorStateChanged);
  }

  void _onExecutorStateChanged(
    AsyncValue<SearchEmailResult>? previous,
    AsyncValue<SearchEmailResult> next,
  ) {
    if (next.isLoading) {
      _notifyObservers((observer) => observer.onSearchLoading());
    } else if (next.hasError) {
      final error = next.error!;
      // Urgent failures were already routed by the executor's consume seam
      // (ADR-0103); no observer reacts to them, so don't fan them out.
      if (isUrgentException(error)) return;
      _notifyObservers((observer) => observer.onSearchFailure(error));
    } else {
      final result = next.value;
      if (result == null) return;
      final isFreshResult =
          _lastDispatchedIntent is NewSearchIntent && previous?.isLoading == true;
      _notifyObservers(
        (observer) => observer.onSearchResult(result, isFreshResult: isFreshResult),
      );
    }
  }

  // Copies the set so an observer that (un)registers mid-callback is safe.
  void _notifyObservers(void Function(SearchExecutionObserver) action) {
    for (final observer in _observers.toList()) {
      action(observer);
    }
  }

  void _notifyCurrentState(SearchExecutionObserver observer) {
    final current = _container.read(searchEmailProvider);
    if (current.isLoading) {
      observer.onSearchLoading();
    } else if (current.hasError) {
      // Urgent failures were already routed by the consume seam (ADR-0103).
      if (isUrgentException(current.error!)) return;
      observer.onSearchFailure(current.error!, isReplay: true);
    } else if (current.value != null) {
      observer.onSearchResult(current.value!, isFreshResult: false);
    }
  }

  void _closeSubscription() {
    _subscription?.close();
    _subscription = null;
  }
}
