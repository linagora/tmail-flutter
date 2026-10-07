@TestOn('chrome')
library;

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:workplace/domain/entity/drive_uploaded_file.dart';
import 'package:workplace/domain/entity/workplace_access_mode.dart';
import 'package:workplace/domain/entity/workplace_request_context.dart';
import 'package:workplace/data/model/workplace_request_transfer.dart';
import 'package:workplace/domain/entity/workplace_upload_file_spec.dart';
import 'package:workplace/domain/repository/workplace_repository.dart';
import 'package:workplace/domain/usecase/exchange_drive_token_interactor.dart';
import 'package:workplace/domain/usecase/workplace_access_mode_runner.dart';
import 'package:workplace/domain/usecase/workplace_action.dart';
import 'package:workplace/domain/entity/workplace_intent.dart';
import 'package:workplace/domain/entity/workplace_intent_config.dart';

import '../../test_utils/cozy_bridge_test_helper.dart';

// Any call fails the test: the exchange must never run once the bridge answered.
class _UnreachableRepository implements WorkplaceRepository {
  @override
  Future<String> exchangeToken(Uri platformUrl, String oidcIdToken) =>
      throw StateError('ExchangeDriveTokenInteractor must not run');

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
    WorkplaceRequestTransfer transfer = const WorkplaceRequestTransfer(),
  }) => throw UnimplementedError();

  @override
  Future<Uri> createShareLink({
    required WorkplaceRequestContext context,
    required String fileId,
  }) => throw UnimplementedError();
}

class _BridgeOnlyAction extends WorkplaceAction<String> {
  const _BridgeOnlyAction();

  @override
  bool get supportsBridge => true;

  @override
  Future<String> call(WorkplaceAccessMode accessMode) => throw StateError('bridge rejected');
}

// Succeeds only over bearer token; a bridge attempt always throws first.
class _FallsBackToBearerAction extends WorkplaceAction<String> {
  final List<WorkplaceAccessMode> calls = [];

  @override
  bool get supportsBridge => true;

  @override
  bool get fallsBackToBearer => true;

  @override
  Future<String> call(WorkplaceAccessMode accessMode) {
    calls.add(accessMode);
    if (accessMode is BridgeAccessMode) throw StateError('bridge rejected');
    return Future.value('bearer-result');
  }
}

// A String succeeds; the exchange interactor is never expected to run here.
class _FakeWorkplaceRepository implements WorkplaceRepository {
  @override
  Future<String> exchangeToken(Uri platformUrl, String oidcIdToken) async => 'access-token';

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
    WorkplaceRequestTransfer transfer = const WorkplaceRequestTransfer(),
  }) => throw UnimplementedError();

  @override
  Future<Uri> createShareLink({
    required WorkplaceRequestContext context,
    required String fileId,
  }) => throw UnimplementedError();
}

// Records each access mode it runs on; a bridge call throws when [bridgeFails].
class _ScriptedAction extends WorkplaceAction<String> {
  @override
  final bool supportsBridge;
  @override
  final bool fallsBackToBearer;
  final bool bridgeFails;
  final List<WorkplaceAccessMode> calls = [];

  _ScriptedAction({
    this.supportsBridge = true,
    this.fallsBackToBearer = false,
    this.bridgeFails = false,
  });

  @override
  Future<String> call(WorkplaceAccessMode accessMode) async {
    calls.add(accessMode);
    if (accessMode is! BridgeAccessMode) return 'bearer-result';
    if (bridgeFails) throw StateError('bridge rejected');
    return 'bridge-result';
  }
}

// The token exchange fails with a non-refreshable server error.
class _FailingExchangeRepository extends Fake implements WorkplaceRepository {
  @override
  Future<String> exchangeToken(Uri platformUrl, String oidcIdToken) async {
    final requestOptions = RequestOptions(path: '/auth/token_exchange');
    throw DioException(
      requestOptions: requestOptions,
      response: Response(statusCode: 500, requestOptions: requestOptions),
      type: DioExceptionType.badResponse,
    );
  }
}

WorkplaceAccessModeRunner _runnerOver(WorkplaceRepository repository) => WorkplaceAccessModeRunner(
      exchangeTokenInteractor: ExchangeDriveTokenInteractor(repository),
      oidcTokenGetter: () => 'oidc-token',
      oidcRefreshTrigger: () async => null,
    );

void main() {
  tearDown(removeCozyBridge);

  test('supportsBridge: false skips an available bridge and runs over bearer token', () async {
    installCozyBridge((_) => null);
    final action = _ScriptedAction(supportsBridge: false);

    final result = await _runnerOver(_FakeWorkplaceRepository())
        .run(Uri.parse('https://platform.example.com'), action);

    expect(result, 'bearer-result');
    expect(action.calls, [isA<BearerTokenAccessMode>()]);
  });

  for (final fallsBackToBearer in [false, true]) {
    test('returns the bridge result without an exchange (fallsBackToBearer: $fallsBackToBearer)', () async {
      installCozyBridge((_) => null);
      final action = _ScriptedAction(fallsBackToBearer: fallsBackToBearer);

      final result = await _runnerOver(_UnreachableRepository())
          .run(Uri.parse('https://platform.example.com'), action);

      expect(result, 'bridge-result');
      expect(action.calls, [isA<BridgeAccessMode>()]);
    });
  }

  test('bridge supported + available + fetchJson throws propagates the error, exchange never called', () async {
    installCozyBridge((_) => throw StateError('bridge rejected'));
    final repository = _UnreachableRepository();
    final runner = WorkplaceAccessModeRunner(
      exchangeTokenInteractor: ExchangeDriveTokenInteractor(repository),
      oidcTokenGetter: () => 'oidc-token',
      oidcRefreshTrigger: () async => null,
    );

    await expectLater(
      runner.run(Uri.parse('https://platform.example.com'), const _BridgeOnlyAction()),
      throwsA(isA<StateError>().having((e) => e.message, 'message', 'bridge rejected')),
    );
  });

  test('fallsBackToBearer: true retries over bearer token when the bridge call throws', () async {
    installCozyBridge((_) => throw StateError('bridge rejected'));
    final repository = _FakeWorkplaceRepository();
    final runner = WorkplaceAccessModeRunner(
      exchangeTokenInteractor: ExchangeDriveTokenInteractor(repository),
      oidcTokenGetter: () => 'oidc-token',
      oidcRefreshTrigger: () async => null,
    );
    final action = _FallsBackToBearerAction();

    final result = await runner.run(Uri.parse('https://platform.example.com'), action);

    expect(result, 'bearer-result');
    expect(action.calls, [isA<BridgeAccessMode>(), isA<BearerTokenAccessMode>()]);
  });

  test('surfaces the bearer error when both the bridge and the bearer fallback fail', () async {
    installCozyBridge((_) => null);
    final action = _ScriptedAction(fallsBackToBearer: true, bridgeFails: true);

    await expectLater(
      _runnerOver(_FailingExchangeRepository())
          .run(Uri.parse('https://platform.example.com'), action),
      throwsA(isA<DioException>().having((e) => e.response?.statusCode, 'status', 500)),
    );
    expect(action.calls, [isA<BridgeAccessMode>()]);
  });
}
