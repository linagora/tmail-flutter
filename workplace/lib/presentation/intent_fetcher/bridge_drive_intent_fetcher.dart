import 'package:workplace/data/datasource_impl/workplace_bridge_datasource_impl.dart';
import 'package:workplace/data/repository_impl/workplace_bridge_repository_impl.dart';
import 'package:workplace/domain/entity/workplace_intent.dart';
import 'package:workplace/domain/entity/workplace_intent_config.dart';
import 'package:workplace/domain/exceptions/workplace_exceptions.dart';
import 'package:workplace/domain/repository/workplace_bridge_repository.dart';
import 'package:workplace/domain/state/workplace_intent_state.dart';
import 'package:workplace/domain/usecase/create_drive_intent_via_bridge_interactor.dart';
import 'package:workplace/presentation/intent_fetcher/drive_intent_fetcher.dart';
import 'package:workplace/presentation/intent_fetcher/interactor_result_extension.dart';

/// Web inside the container app: the bridge already holds the stack session,
/// so no token is needed.
class BridgeDriveIntentFetcher implements DriveIntentFetcher {
  final WorkplaceBridgeRepository _repository;
  late final _createIntentInteractor =
      CreateDriveIntentViaBridgeInteractor(_repository);

  BridgeDriveIntentFetcher({WorkplaceBridgeRepository? repository})
      : _repository = repository ??
            WorkplaceBridgeRepositoryImpl(WorkplaceBridgeDataSourceImpl());

  @override
  bool get isAvailable => _repository.isAvailable;

  @override
  Future<WorkplaceIntent> fetchIntent(
    Uri platformUrl,
    WorkplaceIntentConfig config,
  ) async {
    final success = await _createIntentInteractor
        .execute(config)
        .firstSuccess<CreateWorkplaceIntentSuccess>(
          orElse: WorkplaceCreateIntentException.new,
        );
    return success.intent;
  }
}
