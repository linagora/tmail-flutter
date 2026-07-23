import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/core/properties/properties.dart';
import 'package:jmap_dart_client/jmap/core/state.dart' as jmap;
import 'package:tmail_ui_user/features/search/email/domain/execution/search_execution_intent.dart';
import 'package:tmail_ui_user/features/search/email/domain/execution/search_execution_result.dart';
import 'package:tmail_ui_user/features/search/email/presentation/service/email_state_change_source.dart';
import 'package:tmail_ui_user/features/search/email/presentation/service/search_dispatch_context.dart';
import 'package:tmail_ui_user/features/search/email/presentation/service/search_executor_service.dart';
import 'package:tmail_ui_user/features/search/email/presentation/service/search_refresh_coordinator.dart';

import '../../../../../fixtures/account_fixtures.dart';
import '../../../../../fixtures/session_fixtures.dart';

class _FakeEmailStateChangeSource implements EmailStateChangeSource {
  final _controller = StreamController<jmap.State>.broadcast();

  @override
  jmap.State? currentAppliedState;

  @override
  Stream<jmap.State> get onEmailStateChanged => _controller.stream;

  void emit(jmap.State state) {
    _controller.add(state);
  }

  Future<void> close() => _controller.close();
}

class _FakeSearchExecutorService extends SearchExecutorService {
  _FakeSearchExecutorService(this._container) : super(_container);

  final ProviderContainer _container;

  int dispatchCount = 0;
  SearchExecutionIntent? lastIntent;
  Completer<void>? dispatchGate;
  Object? dispatchError;
  SearchExecutionResult dispatchResult = SearchExecutionResult.success;

  void disposeContainer() {
    dispose();
    _container.dispose();
  }

  @override
  Future<SearchExecutionResult> dispatch(
    SearchExecutionIntent intent,
    SearchDispatchContext context,
  ) async {
    dispatchCount++;
    lastIntent = intent;
    if (dispatchError != null) throw dispatchError!;
    await dispatchGate?.future;
    return dispatchResult;
  }
}

void main() {
  late _FakeEmailStateChangeSource source;
  late _FakeSearchExecutorService executor;
  late SearchRefreshCoordinator coordinator;
  var searchRunning = true;
  SearchDispatchContext? dispatchContext;
  final errors = <Object>[];

  final context = SearchDispatchContext(
    session: SessionFixtures.aliceSession,
    accountId: AccountFixtures.aliceAccountId,
    properties: Properties({'id'}),
    collapseThreads: false,
    trashSpamMailboxIds: null,
  );

  setUp(() {
    source = _FakeEmailStateChangeSource();
    executor = _FakeSearchExecutorService(ProviderContainer());
    searchRunning = true;
    dispatchContext = context;
    errors.clear();
    coordinator = SearchRefreshCoordinator(
      executor: executor,
      stateSource: source,
      callbacks: SearchRefreshCoordinatorCallbacks(
        resolveDispatchContext: () => dispatchContext,
        isSearchRunning: () => searchRunning,
        resolveResultCount: () => 7,
        onError: (error, _) => errors.add(error),
      ),
    );
  });

  tearDown(() async {
    coordinator.dispose();
    await source.close();
    executor.disposeContainer();
  });

  test('dispatches one refresh', () async {
    source.emit(jmap.State('state-1'));
    await pumpEventQueue();

    expect(executor.dispatchCount, 1);
    expect(
      (executor.lastIntent as RefreshChangesIntent).currentCount,
      7,
    );
  });

  test('skips a state the app is already synced to', () async {
    source.currentAppliedState = jmap.State('state-1');
    source.emit(jmap.State('state-1'));
    await pumpEventQueue();

    expect(executor.dispatchCount, 0);
  });

  test('ignores a repeated state', () async {
    source.emit(jmap.State('state-1'));
    source.emit(jmap.State('state-1'));
    await pumpEventQueue();
    source.emit(jmap.State('state-1'));
    await pumpEventQueue();

    expect(executor.dispatchCount, 1);
  });

  test('does not dispatch while search is not running', () async {
    searchRunning = false;
    source.emit(jmap.State('state-1'));
    await pumpEventQueue();

    expect(executor.dispatchCount, 0);
  });

  test('does not dispatch without a session context', () async {
    dispatchContext = null;
    source.emit(jmap.State('state-1'));
    await pumpEventQueue();

    expect(executor.dispatchCount, 0);
  });

  test('serializes multiple state changes', () async {
    final gate = Completer<void>();
    executor.dispatchGate = gate;

    source.emit(jmap.State('state-1'));
    source.emit(jmap.State('state-2'));
    await pumpEventQueue();

    expect(executor.dispatchCount, 1);
    gate.complete();
    await pumpEventQueue();

    expect(executor.dispatchCount, 2);
  });

  test('reports unexpected dispatch errors', () async {
    executor.dispatchError = StateError('boom');
    source.emit(jmap.State('state-1'));
    await pumpEventQueue();

    expect(errors.single, isA<StateError>());
  });

  test('reports a failed refresh and schedules a retry', () async {
    executor.dispatchResult = SearchExecutionResult.failure;
    source.emit(jmap.State('state-1'));
    await pumpEventQueue();

    expect(executor.dispatchCount, 1);
    expect(errors.single, isA<StateError>());
  });

  test('stops retrying after the retry limit', () async {
    executor.dispatchResult = SearchExecutionResult.failure;
    source.emit(jmap.State('state-1'));
    await Future<void>.delayed(const Duration(milliseconds: 750));

    expect(executor.dispatchCount, 4);
    expect(errors, hasLength(4));
  });

  test('cancels a pending retry on dispose', () async {
    executor.dispatchResult = SearchExecutionResult.failure;
    source.emit(jmap.State('state-1'));
    await pumpEventQueue();
    coordinator.dispose();
    await Future<void>.delayed(const Duration(milliseconds: 250));

    expect(executor.dispatchCount, 1);
  });

  test('does not dispatch after dispose', () async {
    coordinator.dispose();
    source.emit(jmap.State('state-1'));
    await pumpEventQueue();

    expect(executor.dispatchCount, 0);
  });
}
