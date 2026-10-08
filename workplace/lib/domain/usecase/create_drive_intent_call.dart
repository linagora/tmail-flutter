import 'package:core/presentation/state/failure.dart';

import '../entity/bridge_policy.dart';
import '../entity/workplace_access_mode.dart';
import '../entity/workplace_intent.dart';
import '../entity/workplace_intent_config.dart';
import '../exceptions/workplace_exceptions.dart';
import '../state/workplace_intent_state.dart';
import 'create_drive_intent_interactor.dart';
import 'workplace_call.dart';

/// cozy-stack `POST /intents`; a re-send only orphans an unopened intent.
class CreateDriveIntentCall extends WorkplaceCall<WorkplaceIntent> {
  final CreateDriveIntentInteractor _interactor;
  final Uri _platformUrl;
  final WorkplaceIntentConfig _config;

  const CreateDriveIntentCall(this._interactor, this._platformUrl, this._config);

  @override
  BridgePolicy get bridgePolicy => BridgePolicy.bearerReplay;

  @override
  Future<WorkplaceIntent> call(WorkplaceAccessMode accessMode) async {
    WorkplaceIntent? intent;
    await for (final either in _interactor.execute(_platformUrl, accessMode, config: _config)) {
      either.fold(
        (failure) {
          // reported by DriveIntentMessageHandlerMixin._failWith, the single funnel.
          throw failure is FeatureFailure ? failure.exception : WorkplaceCreateIntentException();
        },
        (success) {
          if (success is CreateWorkplaceIntentSuccess) intent = success.intent;
        },
      );
    }
    return intent ?? (throw WorkplaceCreateIntentException());
  }
}
