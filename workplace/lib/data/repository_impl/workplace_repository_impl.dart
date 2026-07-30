import '../datasource/workplace_datasource.dart';
import '../../domain/entity/workplace_action_config.dart';
import '../../domain/entity/workplace_intent.dart';
import '../../domain/entity/workplace_theme.dart';
import '../../domain/repository/workplace_repository.dart';

class WorkplaceRepositoryImpl implements WorkplaceRepository {
  final WorkplaceDataSource _dataSource;

  WorkplaceRepositoryImpl(this._dataSource);

  @override
  Future<WorkplaceIntent> createIntent({
    required Uri platformUrl,
    required String accessToken,
    required WorkplaceActionConfig addAsLink,
    WorkplaceActionConfig? addAsAttachment,
    required WorkplaceTheme theme,
  }) => _dataSource.createIntent(
    platformUrl: platformUrl,
    accessToken: accessToken,
    addAsLink: addAsLink,
    addAsAttachment: addAsAttachment,
    theme: theme,
  );

  @override
  Future<String> exchangeToken(Uri platformUrl, String oidcIdToken) =>
      _dataSource.exchangeToken(platformUrl, oidcIdToken);
}
