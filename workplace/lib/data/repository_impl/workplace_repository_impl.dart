import '../datasource/workplace_datasource.dart';
import '../../domain/entity/workplace_intent.dart';
import '../../domain/repository/workplace_repository.dart';

class WorkplaceRepositoryImpl implements WorkplaceRepository {
  final WorkplaceDataSource _dataSource;

  WorkplaceRepositoryImpl(this._dataSource);

  @override
  Future<WorkplaceIntent> createIntent(
    Uri platformUrl,
    String accessToken, {
    required String addAsLink,
    required String addAsAttachment,
  }) => _dataSource.createIntent(
    platformUrl,
    accessToken,
    addAsLink: addAsLink,
    addAsAttachment: addAsAttachment,
  );

  @override
  Future<String> exchangeToken(Uri platformUrl, String oidcIdToken) =>
      _dataSource.exchangeToken(platformUrl, oidcIdToken);
}
