import 'package:flutter_test/flutter_test.dart';
import 'package:workplace/domain/entity/bridge_policy.dart';
import 'package:workplace/domain/entity/workplace_access_mode.dart';
import 'package:workplace/domain/entity/workplace_action_config.dart';
import 'package:workplace/domain/entity/workplace_intent.dart';
import 'package:workplace/domain/entity/workplace_intent_config.dart';
import 'package:workplace/domain/entity/workplace_theme.dart';
import 'package:workplace/domain/repository/workplace_repository.dart';
import 'package:workplace/domain/usecase/create_drive_intent_call.dart';
import 'package:workplace/domain/usecase/create_drive_intent_interactor.dart';

class _FakeRepository extends Fake implements WorkplaceRepository {
  final Object result;
  Uri? receivedUrl;
  WorkplaceAccessMode? receivedMode;
  WorkplaceIntentConfig? receivedConfig;

  _FakeRepository(this.result);

  @override
  Future<WorkplaceIntent> createIntent({
    required Uri platformUrl,
    required WorkplaceAccessMode accessMode,
    required WorkplaceIntentConfig config,
  }) async {
    receivedUrl = platformUrl;
    receivedMode = accessMode;
    receivedConfig = config;
    if (result is WorkplaceIntent) return result as WorkplaceIntent;
    throw result;
  }
}

void main() {
  final platformUrl = Uri.parse('https://platform.example.com');
  const config = WorkplaceIntentConfig(
    addAsLink: WorkplaceActionConfig(label: 'Link'),
    theme: WorkplaceTheme.light,
  );
  final intent = WorkplaceIntent(
    intentId: 'intent-1',
    intentUrl: Uri.parse('https://drive.example.com/pick'),
  );

  CreateDriveIntentCall makeCall(_FakeRepository repository) =>
      CreateDriveIntentCall(CreateDriveIntentInteractor(repository), platformUrl, config);

  group('CreateDriveIntentCall::', () {
    test('replays over bearer token after a bridge failure', () {
      expect(makeCall(_FakeRepository(intent)).bridgePolicy, BridgePolicy.bearerReplay);
    });

    test('returns the created intent and forwards the access mode and config', () async {
      final repository = _FakeRepository(intent);

      final result = await makeCall(repository).call(const BridgeAccessMode());

      expect(result, equals(intent));
      expect(repository.receivedUrl, equals(platformUrl));
      expect(repository.receivedMode, isA<BridgeAccessMode>());
      expect(repository.receivedConfig, equals(config));
    });

    test('rethrows the repository failure unchanged', () async {
      final error = StateError('boom');

      await expectLater(
        makeCall(_FakeRepository(error)).call(const BridgeAccessMode()),
        throwsA(same(error)),
      );
    });
  });
}
