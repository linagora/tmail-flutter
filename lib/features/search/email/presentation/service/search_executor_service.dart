import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tmail_ui_user/features/search/email/domain/execution/search_execution_intent.dart';
import 'package:tmail_ui_user/features/search/email/domain/model/search_email_result.dart';
import 'package:tmail_ui_user/features/search/email/domain/notifier/search_email_notifier.dart';
import 'package:tmail_ui_user/features/search/email/presentation/service/search_dispatch_context.dart';
import 'package:tmail_ui_user/features/search/email/presentation/service/search_execution_observer.dart';
import 'package:tmail_ui_user/main/providers/app_provider_container.dart';

part 'search_executor_service.g.dart';

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

  SearchEmailNotifier get _notifier =>
      _container.read(searchEmailProvider.notifier);

  /// Registers [observer], opens the executor subscription on the first one,
  /// and replays the current state when a search has already been dispatched.
  void register(SearchExecutionObserver observer) {
    final isNewObserver = _observers.add(observer);
    _subscription ??=
        _container.listen(searchEmailProvider, _onExecutorStateChanged);
    if (isNewObserver && _hasDispatchedSearch) {
      _notifyCurrentState(observer);
    }
  }

  /// Unregisters [observer]; closes the subscription once none remain.
  void unregister(SearchExecutionObserver observer) {
    _observers.remove(observer);
    if (_observers.isEmpty) _closeSubscription();
  }

  /// Runs [intent] via the executor; a new search first resets its observers.
  /// The returned future completes when the executor finishes (awaited by the
  /// websocket-refresh path to order message-dedup after the refresh).
  Future<void> dispatch(
    SearchExecutionIntent intent,
    SearchDispatchContext context,
  ) {
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
    _closeSubscription();
    _observers.clear();
  }

  void _onExecutorStateChanged(
    AsyncValue<SearchEmailResult>? previous,
    AsyncValue<SearchEmailResult> next,
  ) {
    if (next.isLoading) {
      _notifyObservers((observer) => observer.onSearchLoading());
    } else if (next.hasError) {
      _notifyObservers((observer) => observer.onSearchFailure(next.error!));
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
      observer.onSearchFailure(current.error!);
    } else if (current.value != null) {
      observer.onSearchResult(current.value!, isFreshResult: false);
    }
  }

  void _closeSubscription() {
    _subscription?.close();
    _subscription = null;
  }
}

/// App-lifetime singleton bridging every search consumer to the executor.
@Riverpod(keepAlive: true)
SearchExecutorService searchExecutorService(Ref ref) {
  final service = SearchExecutorService(appProviderContainer);
  ref.onDispose(service.dispose);
  return service;
}
