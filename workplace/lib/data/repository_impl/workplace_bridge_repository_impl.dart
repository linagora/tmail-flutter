import '../datasource/workplace_bridge_datasource.dart';
import '../../domain/entity/workplace_intent.dart';
import '../../domain/entity/workplace_intent_config.dart';
import '../../domain/repository/workplace_bridge_repository.dart';

class WorkplaceBridgeRepositoryImpl implements WorkplaceBridgeRepository {
  final WorkplaceBridgeDataSource _dataSource;

  WorkplaceBridgeRepositoryImpl(this._dataSource);

  @override
  bool get isAvailable => _dataSource.isAvailable;

  @override
  Future<WorkplaceIntent> createIntent(WorkplaceIntentConfig config) =>
      _dataSource.createIntent(config);
}
