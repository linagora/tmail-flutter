import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:workplace/domain/entity/bridge_policy.dart';
import 'package:workplace/domain/entity/drive_uploaded_file.dart';
import 'package:workplace/domain/entity/workplace_access_mode.dart';
import 'package:workplace/domain/entity/workplace_intent.dart';
import 'package:workplace/domain/entity/workplace_intent_config.dart';
import 'package:workplace/domain/entity/workplace_request_context.dart';
import 'package:workplace/domain/entity/workplace_upload_transfer.dart';
import 'package:workplace/domain/entity/workplace_upload_file_spec.dart';
import 'package:workplace/domain/repository/workplace_repository.dart';
import 'package:workplace/domain/state/workplace_intent_state.dart';
import 'package:workplace/domain/usecase/exchange_drive_token_interactor.dart';
import 'package:workplace/domain/usecase/workplace_access_mode_runner.dart';
import 'package:workplace/domain/usecase/workplace_call.dart';

// Queued items in order: a String succeeds, anything else is thrown.
class _FakeWorkplaceRepository implements WorkplaceRepository {
  final List<dynamic> _tokenQueue;

  /// Fired with each call's index before its response is served.
  final void Function(int index)? onCall;
  int exchangeCallCount = 0;
  final List<String> exchangedIdTokens = [];

  _FakeWorkplaceRepository(this._tokenQueue, {this.onCall});

  @override
  Future<String> exchangeToken(Uri platformUrl, String oidcIdToken) async {
    final index = exchangeCallCount++;
    exchangedIdTokens.add(oidcIdToken);
    onCall?.call(index);
    final item = _tokenQueue.removeAt(0);
    if (item is String) return item;
    throw item as Object;
  }

  @override
  Future<WorkplaceIntent> createIntent({
    required Uri platformUrl,
    required WorkplaceAccessMode accessMode,
    required WorkplaceIntentConfig config,
  }) => throw UnimplementedError();

  @override
  Future<DriveUploadedFile> uploadFile({
    required WorkplaceRequestContext context,
    required WorkplaceUploadFileSpec spec,
    WorkplaceUploadTransfer transfer = const WorkplaceUploadTransfer(),
  }) => throw UnimplementedError();

  @override
  Future<Uri> createShareLink({
    required WorkplaceRequestContext context,
    required String fileId,
  }) => throw UnimplementedError();
}

// Ends after the loading state without ever yielding a token.
class _TokenlessExchangeInteractor extends ExchangeDriveTokenInteractor {
  _TokenlessExchangeInteractor() : super(_FakeWorkplaceRepository([]));

  @override
  Stream<Either<Failure, Success>> execute(Uri platformUrl, String oidcIdToken) async* {
    yield Right(ExchangingWorkplaceToken());
  }
}

class _RecordingCall extends WorkplaceCall<String> {
  final BridgePolicy _bridgePolicy;
  final Future<String> Function(WorkplaceAccessMode accessMode) _onCall;
  final List<WorkplaceAccessMode> calls = [];

  _RecordingCall({
    BridgePolicy bridgePolicy = BridgePolicy.noBearerReplay,
    required Future<String> Function(WorkplaceAccessMode accessMode) onCall,
  })  : _bridgePolicy = bridgePolicy,
        _onCall = onCall;

  @override
  BridgePolicy get bridgePolicy => _bridgePolicy;

  @override
  Future<String> call(WorkplaceAccessMode accessMode) {
    calls.add(accessMode);
    return _onCall(accessMode);
  }
}

void main() {
  final platformUrl = Uri.parse('https://platform.example.com');

  DioException statusError(int code) => DioException(
        requestOptions: RequestOptions(path: ''),
        response: Response(statusCode: code, requestOptions: RequestOptions(path: '')),
        type: DioExceptionType.badResponse,
      );

  WorkplaceAccessModeRunner makeRunner({
    required _FakeWorkplaceRepository repository,
    String? Function()? oidcTokenGetter,
    OidcRefreshTrigger? oidcRefreshTrigger,
  }) =>
      WorkplaceAccessModeRunner(
        exchangeTokenInteractor: ExchangeDriveTokenInteractor(repository),
        oidcTokenGetter: oidcTokenGetter ?? () => 'oidc-token',
        oidcRefreshTrigger: oidcRefreshTrigger ?? () async => null,
      );

  _RecordingCall bearerEchoCall({
    BridgePolicy bridgePolicy = BridgePolicy.noBearerReplay,
  }) => _RecordingCall(
        bridgePolicy: bridgePolicy,
        onCall: (mode) async => (mode as BearerTokenAccessMode).accessToken,
      );

  ({OidcRefreshTrigger trigger, int Function() callCount}) countingTrigger(
    String returns,
  ) {
    var count = 0;
    return (
      trigger: () async {
        count++;
        return returns;
      },
      callCount: () => count,
    );
  }

  group('WorkplaceAccessModeRunner::run::', () {
    test('throws StateError when oidcTokenGetter returns null', () async {
      final runner = makeRunner(
        repository: _FakeWorkplaceRepository([]),
        oidcTokenGetter: () => null,
      );

      await expectLater(
        runner.run(platformUrl, bearerEchoCall()),
        throwsA(isA<StateError>().having(
          (e) => e.message, 'message', contains('OIDC token'),
        )),
      );
    });

    test('throws StateError without calling the action when the exchange yields no token', () async {
      final runner = WorkplaceAccessModeRunner(
        exchangeTokenInteractor: _TokenlessExchangeInteractor(),
        oidcTokenGetter: () => 'oidc-token',
        oidcRefreshTrigger: () async => null,
      );
      final action = bearerEchoCall();

      await expectLater(
        runner.run(platformUrl, action),
        throwsA(isA<StateError>().having(
          (e) => e.message, 'message', contains('exchange failed'),
        )),
      );
      expect(action.calls, isEmpty);
    });

    test('resolves BearerTokenAccessMode and calls the action when exchange succeeds', () async {
      final repository = _FakeWorkplaceRepository(['drive-token']);
      final runner = makeRunner(repository: repository);

      final result = await runner.run(platformUrl, bearerEchoCall());

      expect(result, equals('drive-token'));
    });

    for (final code in [400, 401]) {
      test('retries once via oidcRefreshTrigger after a $code, then succeeds', () async {
        final repository = _FakeWorkplaceRepository([statusError(code), 'drive-token']);
        final refresh = countingTrigger('refreshed-oidc-token');
        final runner = makeRunner(repository: repository, oidcRefreshTrigger: refresh.trigger);

        final result = await runner.run(platformUrl, bearerEchoCall());

        expect(refresh.callCount(), equals(1));
        expect(result, equals('drive-token'));
        expect(repository.exchangedIdTokens, equals(['oidc-token', 'refreshed-oidc-token']));
      });
    }

    test('does not retry twice when the refreshed token also gets a 401', () async {
      final repository = _FakeWorkplaceRepository([statusError(401), statusError(401)]);
      final refresh = countingTrigger('refreshed-oidc-token');
      final runner = makeRunner(repository: repository, oidcRefreshTrigger: refresh.trigger);

      await expectLater(
        runner.run(platformUrl, bearerEchoCall()),
        throwsA(isA<DioException>()),
      );
      expect(refresh.callCount(), equals(1));
    });

    test('does not retry when the refresh keeps the id token that just 401ed', () async {
      final repository = _FakeWorkplaceRepository([statusError(401)]);
      final refresh = countingTrigger('oidc-token');
      final runner = makeRunner(
        repository: repository,
        oidcTokenGetter: () => 'oidc-token',
        oidcRefreshTrigger: refresh.trigger,
      );

      await expectLater(
        runner.run(platformUrl, bearerEchoCall()),
        throwsA(isA<DioException>()),
      );
      expect(refresh.callCount(), equals(1));
      expect(repository.exchangeCallCount, equals(1));
    });

    test('propagates the oidcRefreshTrigger failure after a 401 with no second exchange', () async {
      final repository = _FakeWorkplaceRepository([statusError(401)]);
      final rejection = StateError('refresh rejected by the server');
      final runner = makeRunner(
        repository: repository,
        oidcRefreshTrigger: () async => throw rejection,
      );

      await expectLater(
        runner.run(platformUrl, bearerEchoCall()),
        throwsA(same(rejection)),
      );
      expect(repository.exchangeCallCount, equals(1));
    });

    test('reuses the already-refreshed token when a second 401 arrives late, with one refresh', () async {
      const staleToken = 'old-oidc-token';
      const refreshedToken = 'refreshed-oidc-token';
      var isStale = true;
      var refreshCount = 0;
      Future<String?> refresh() async {
        refreshCount++;
        isStale = false;
        return refreshedToken;
      }

      final repository = _FakeWorkplaceRepository(
        [
          statusError(401), // A: stale token
          'drive-token', // A: retry with refreshed token
          statusError(401), // B: was already in flight with the stale token
          'drive-token', // B: retry reuses A's refreshed token, no new refresh
        ],
        // Simulates A's refresh landing before B's stale response arrives.
        onCall: (index) {
          if (index == 2) isStale = false;
        },
      );
      final runner = makeRunner(
        repository: repository,
        oidcTokenGetter: () => isStale ? staleToken : refreshedToken,
        oidcRefreshTrigger: refresh,
      );

      final resultA = await runner.run(platformUrl, bearerEchoCall());
      isStale = true; // B started before A's refresh landed.
      final resultB = await runner.run(platformUrl, bearerEchoCall());

      expect(refreshCount, equals(1));
      expect(resultA, equals('drive-token'));
      expect(resultB, equals('drive-token'));
      expect(
        repository.exchangedIdTokens,
        equals([staleToken, refreshedToken, staleToken, refreshedToken]),
      );
    });

    test('never triggers a refresh when the exchange fails without a 4xx response', () async {
      final repository = _FakeWorkplaceRepository([
        DioException(requestOptions: RequestOptions(path: ''), type: DioExceptionType.connectionError),
      ]);
      final refresh = countingTrigger('refreshed-oidc-token');
      final runner = makeRunner(repository: repository, oidcRefreshTrigger: refresh.trigger);

      await expectLater(
        runner.run(platformUrl, bearerEchoCall()),
        throwsA(isA<DioException>()),
      );
      // A network error is not a stale token; refreshing would be pointless.
      expect(refresh.callCount(), equals(0));
      expect(repository.exchangeCallCount, equals(1));
    });

    test('throws the original 401 when the refresh trigger yields no token', () async {
      final repository = _FakeWorkplaceRepository([statusError(401)]);
      final runner = makeRunner(repository: repository, oidcRefreshTrigger: () async => null);

      await expectLater(
        runner.run(platformUrl, bearerEchoCall()),
        // Not a StateError from a null access token: the 401 is the real cause.
        throwsA(isA<DioException>().having(
          (e) => e.response?.statusCode, 'statusCode', 401,
        )),
      );
      expect(repository.exchangeCallCount, equals(1));
    });

    test('BridgePolicy.never never invokes the bridge and runs the exchange once', () async {
      final repository = _FakeWorkplaceRepository(['drive-token']);
      final runner = makeRunner(repository: repository);
      final action = bearerEchoCall(bridgePolicy: BridgePolicy.never);

      final result = await runner.run(platformUrl, action);

      expect(result, equals('drive-token'));
      expect(repository.exchangeCallCount, equals(1));
      expect(action.calls.single, isA<BearerTokenAccessMode>());
    });
  });
}
