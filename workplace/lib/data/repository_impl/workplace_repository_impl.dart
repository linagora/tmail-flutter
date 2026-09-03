import '../datasource/workplace_datasource.dart';
import '../../domain/entity/workplace_intent.dart';
import '../../domain/entity/workplace_intent_config.dart';
import '../../domain/repository/workplace_repository.dart';

class WorkplaceRepositoryImpl implements WorkplaceRepository {
  final WorkplaceDataSource _dataSource;

  WorkplaceRepositoryImpl(this._dataSource);

  @override
  Future<WorkplaceIntent> createIntent({
    required Uri platformUrl,
    String? accessToken,
    required WorkplaceIntentConfig config,
  }) => _dataSource.createIntent(
    platformUrl: platformUrl,
    accessToken: accessToken,
    config: config,
  );

  @override
  Future<String> exchangeToken(Uri platformUrl, String oidcIdToken) =>
      _dataSource.exchangeToken(platformUrl, oidcIdToken);
}
