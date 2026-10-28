import 'dart:async';

import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/base/base_controller.dart';
import 'package:tmail_ui_user/features/delegation/presentation/bridge/active_account_reader.dart';
import 'package:tmail_ui_user/features/delegation/presentation/notifier/active_account_notifier.dart';

import '../../../../fixtures/active_account_source_fixtures.dart';
import '../../../../fixtures/base_controller_fixtures.dart';
import '../../../../fixtures/delegation_fixtures.dart';

class _Reader extends BaseController with ActiveAccountReader, ShownAccountStateConsumer {
  final results = <Either<Failure, Success>>[];
  final errors = <Object>[];
  int doneCount = 0;

  @override
  void onData(Either<Failure, Success> newState) => results.add(newState);

  @override
  void onError(dynamic error, StackTrace stackTrace) => errors.add(error);

  @override
  void onDone() => doneCount++;
}

class _Loaded extends UIState {}

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

    test('a closed reader gets no more results', () async {
      reader.consumeShownAccountState(viewResults.stream);

      reader.onClose();
      viewResults.add(Right(_Loaded()));
      await pumpEventQueue();

      expect(reader.results, isEmpty);
      expect(viewResults.hasListener, isFalse);
    });
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
