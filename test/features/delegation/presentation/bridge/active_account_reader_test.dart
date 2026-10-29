import 'dart:async';

import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/base/base_controller.dart';
import 'package:tmail_ui_user/features/delegation/presentation/bridge/active_account_reader.dart';
import 'package:tmail_ui_user/features/delegation/presentation/notifier/active_account_notifier.dart';
import 'package:tmail_ui_user/main/exceptions/remote/authentication_exception.dart';
import 'package:tmail_ui_user/main/exceptions/remote/network_exception.dart';

import '../../../../fixtures/active_account_source_fixtures.dart';
import '../../../../fixtures/base_controller_fixtures.dart';
import '../../../../fixtures/delegation_fixtures.dart';

class _Reader extends BaseController with ActiveAccountReader, ShownAccountStateConsumer {
  final results = <Either<Failure, Success>>[];
  final errors = <Object>[];
  final urgentErrors = <Object?>[];
  int doneCount = 0;

  @override
  void onData(Either<Failure, Success> newState) => results.add(newState);

  @override
  void handleErrorViewState(Object error, StackTrace stackTrace) => errors.add(error);

  @override
  void handleUrgentException({Failure? failure, Exception? exception}) => urgentErrors.add(exception);

  @override
  void onDone() => doneCount++;

  /// Runs [pending] the way a controller awaits a load: an error goes to [onError].
  Future<Either<Failure, Success>?> awaitLoad(Future<Either<Failure, Success>> pending) async {
    try {
      return await pending;
    } catch (error, stackTrace) {
      onError(error, stackTrace);
      return null;
    }
  }
}

class _Loaded extends UIState {}

class _LoadFailure extends FeatureFailure {
  _LoadFailure(dynamic exception) : super(exception: exception);
}

typedef _StaleArrival = ({
  String arrival,
  void Function(StreamController<Either<Failure, Success>> viewResults) arrive,
  List<Object> urgentErrors,
});

const _badCredentials = BadCredentialsException();
final _refreshTokenFailed = RefreshTokenFailedException();

final _staleResult = (
  arrival: 'a result',
  arrive: (StreamController<Either<Failure, Success>> viewResults) => viewResults.add(Right(_Loaded())),
  urgentErrors: <Object>[],
);

final List<_StaleArrival> _staleArrivals = [
  (
    arrival: 'an error',
    arrive: (viewResults) => viewResults.addError(StateError('late failure')),
    urgentErrors: [],
  ),
  (
    arrival: 'a connection error',
    arrive: (viewResults) => viewResults.addError(const ConnectionError()),
    urgentErrors: [],
  ),
  (
    arrival: 'a session failure',
    arrive: (viewResults) => viewResults.add(Left(_LoadFailure(_badCredentials))),
    urgentErrors: [_badCredentials],
  ),
  (
    arrival: 'a session error',
    arrive: (viewResults) => viewResults.addError(_refreshTokenFailed),
    urgentErrors: [_refreshTokenFailed],
  ),
];

String _staleOutcome(List<Object> urgentErrors) => urgentErrors.isEmpty ? 'is dropped' : 'still ends the session';

void main() {
  setUp(BaseControllerFixtures.registerDependencies);
  tearDown(Get.reset);

  group('shown account:', () {
    test('reads the shown account of the registered source', () {
      ActiveAccountSourceFixtures.put(
        DelegationFixtures.session(),
        shownAccountId: DelegationFixtures.bobAccountId,
      );

      expect(_Reader().activeAccountId, DelegationFixtures.bobAccountId);
    });

    test('follows a switch made after the reader was created', () {
      final reader = _Reader();
      final container = ActiveAccountSourceFixtures.newContainer();
      ActiveAccountSourceFixtures.put(DelegationFixtures.session(), container: container);
      expect(reader.activeAccountId, DelegationFixtures.aliceAccountId);

      container.read(activeAccountProvider.notifier).select(DelegationFixtures.carolAccountId);

      expect(reader.activeAccountId, DelegationFixtures.carolAccountId);
    });

    test('reads the source registered at the time of the read', () {
      final reader = _Reader();
      ActiveAccountSourceFixtures.put(DelegationFixtures.session());

      ActiveAccountSourceFixtures.putShowing(DelegationFixtures.bobAccountId);

      expect(reader.activeAccountId, DelegationFixtures.bobAccountId);
    });
  });

  group('isDelegatedAccountShown', () {
    test('is true while a delegated account is shown', () {
      ActiveAccountSourceFixtures.put(
        DelegationFixtures.session(),
        shownAccountId: DelegationFixtures.bobAccountId,
      );

      expect(_Reader().isDelegatedAccountShown, isTrue);
    });

    test('is false while my own account is shown', () {
      ActiveAccountSourceFixtures.put(DelegationFixtures.session());

      expect(_Reader().isDelegatedAccountShown, isFalse);
    });

    test('is false while no account is shown yet', () {
      ActiveAccountSourceFixtures.putEmpty();

      expect(_Reader().isDelegatedAccountShown, isFalse);
    });
  });

  group('consumeShownAccountState:', () {
    late FakeActiveAccountSource source;
    late StreamController<Either<Failure, Success>> viewResults;
    late _Reader reader;

    setUp(() {
      source = ActiveAccountSourceFixtures.putShowing(DelegationFixtures.aliceAccountId);
      viewResults = StreamController<Either<Failure, Success>>();
      reader = _Reader();
    });

    test('forwards every result and the end while its attempt is current', () async {
      reader.consumeShownAccountState(viewResults.stream);
      final first = Right<Failure, Success>(_Loaded());
      final second = Right<Failure, Success>(_Loaded());

      viewResults
        ..add(first)
        ..add(second);
      await viewResults.close();

      expect(reader.results, [first, second]);
      expect(reader.doneCount, 1);
    });

    test('forwards an error while its attempt is current', () async {
      reader.consumeShownAccountState(viewResults.stream);
      final error = StateError('stream failed');

      viewResults.addError(error);
      await pumpEventQueue();

      expect(reader.errors, [error]);
    });

    test('drops every result once another account is shown and stops listening', () async {
      reader.consumeShownAccountState(viewResults.stream);
      source.show(DelegationFixtures.bobAccountId);

      viewResults.add(Right(_Loaded()));
      await pumpEventQueue();

      expect(reader.results, isEmpty);
      expect(viewResults.hasListener, isFalse);
    });

    test('drops an error that arrives once another account is shown', () async {
      reader.consumeShownAccountState(viewResults.stream);
      source.show(DelegationFixtures.bobAccountId);

      viewResults.addError(StateError('late failure'));
      await pumpEventQueue();

      expect(reader.errors, isEmpty);
      expect(viewResults.hasListener, isFalse);
    });

    test('drops the end of a load that arrives once another account is shown', () async {
      reader.consumeShownAccountState(viewResults.stream);
      source.show(DelegationFixtures.bobAccountId);

      await viewResults.close();

      expect(reader.doneCount, 0);
    });

    for (final (:arrival, :arrive, :urgentErrors) in _staleArrivals) {
      test('$arrival that arrives once another account is shown ${_staleOutcome(urgentErrors)}', () async {
        reader.consumeShownAccountState(viewResults.stream);
        source.show(DelegationFixtures.bobAccountId);

        arrive(viewResults);
        await pumpEventQueue();

        expect(reader.results, isEmpty);
        expect(reader.errors, isEmpty);
        expect(reader.urgentErrors, urgentErrors);
      });
    }

    test('a closed reader gets no more results', () async {
      reader.consumeShownAccountState(viewResults.stream);

      reader.onClose();
      viewResults.add(Right(_Loaded()));
      await pumpEventQueue();

      expect(reader.results, isEmpty);
      expect(viewResults.hasListener, isFalse);
    });
  });

  group('awaitShownAccountState:', () {
    late FakeActiveAccountSource source;
    late StreamController<Either<Failure, Success>> viewResults;
    late _Reader reader;

    setUp(() {
      source = ActiveAccountSourceFixtures.putShowing(DelegationFixtures.aliceAccountId);
      viewResults = StreamController<Either<Failure, Success>>();
      reader = _Reader();
    });

    test('returns the last result while its attempt is current', () async {
      final pending = reader.awaitLoad(reader.awaitShownAccountState(viewResults.stream));
      final last = Right<Failure, Success>(_Loaded());

      viewResults
        ..add(Right(_Loaded()))
        ..add(last);
      await viewResults.close();

      expect(await pending, last);
      expect(reader.errors, isEmpty);
    });

    test('throws an error to the caller while its attempt is current', () async {
      final pending = reader.awaitLoad(reader.awaitShownAccountState(viewResults.stream));
      final error = StateError('load failed');

      viewResults.addError(error);
      await viewResults.close();

      expect(await pending, isNull);
      expect(reader.errors, [error]);
    });

    for (final (:arrival, :arrive, :urgentErrors) in [..._staleArrivals, _staleResult]) {
      test('$arrival that arrives once another account is shown stops the caller and ${_staleOutcome(urgentErrors)}',
          () async {
        final pending = reader.awaitLoad(reader.awaitShownAccountState(viewResults.stream));
        source.show(DelegationFixtures.bobAccountId);

        arrive(viewResults);
        await viewResults.close();

        expect(await pending, isNull);
        expect(reader.errors, isEmpty);
        expect(reader.urgentErrors, urgentErrors);
      });
    }
  });

  group('retryActionOf:', () {
    late FakeActiveAccountSource source;
    late StreamController<Either<Failure, Success>> retry;
    late _Reader reader;

    setUp(() {
      source = ActiveAccountSourceFixtures.putShowing(DelegationFixtures.aliceAccountId);
      retry = StreamController<Either<Failure, Success>>();
      reader = _Reader();
    });

    test('a retry tapped while its attempt is current loads the shown account again', () async {
      final retryAction = reader.retryActionOf(retry.stream);
      final loaded = Right<Failure, Success>(_Loaded());

      retryAction();
      retry.add(loaded);
      await pumpEventQueue();

      expect(reader.results, [loaded]);
    });

    test('a retry tapped once another account is shown never runs', () {
      final retryAction = reader.retryActionOf(retry.stream);
      source.show(DelegationFixtures.bobAccountId);

      retryAction();

      expect(retry.hasListener, isFalse);
    });

    test('a retry built once another account is shown runs on a tap', () {
      source.show(DelegationFixtures.bobAccountId);
      final retryAction = reader.retryActionOf(retry.stream);

      retryAction();

      expect(retry.hasListener, isTrue);
    });

    test('a retry that resolves once another account is shown is dropped', () async {
      final retryAction = reader.retryActionOf(retry.stream);
      retryAction();

      source.show(DelegationFixtures.bobAccountId);
      retry.add(Right(_Loaded()));
      await pumpEventQueue();

      expect(reader.results, isEmpty);
    });
  });
}
