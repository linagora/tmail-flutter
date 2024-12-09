
import 'package:core/data/model/source_type/data_source_type.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/data/datasource/app_grid_datasource.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/app_dashboard/linagora_applications.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/linagora_ecosystem/linagora_ecosystem.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/repository/app_grid_repository.dart';

class AppGridRepositoryImpl extends AppGridRepository {

  final Map<DataSourceType, AppGridDatasource> _mapDataSource;

  AppGridRepositoryImpl(this._mapDataSource);

  @override
  Future<LinagoraApplications> getLinagoraApplications(String path) {
    return _mapDataSource[DataSourceType.local]!.getLinagoraApplications(path);
  }

  @override
  Future<LinagoraEcosystem> getLinagoraEcosystem(String baseUrl) {
   return _mapDataSource[DataSourceType.network]!.getLinagoraEcosystem(baseUrl);
  }
}