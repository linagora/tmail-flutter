import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tmail_ui_user/features/login/data/network/interceptors/authorization_interceptors.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';
import 'package:workplace/data/datasource_impl/workplace_datasource_impl.dart';
import 'package:workplace/data/datasource_impl/workplace_drive_datasource_impl.dart';
import 'package:workplace/data/repository_impl/workplace_repository_impl.dart';
import 'package:workplace/domain/usecase/exchange_drive_token_interactor.dart';
import 'package:workplace/domain/usecase/upload_drive_file_interactor.dart';
import 'package:workplace/data/transport/workplace_access_mode_runner.dart';

part 'drive_oversize_uploader_provider.g.dart';

typedef DriveOversizeUploader = ({
  WorkplaceAccessModeRunner runner,
  UploadDriveFileInteractor interactor,
});

@Riverpod(keepAlive: true)
DriveOversizeUploader driveOversizeUploader(Ref ref) {
  final repository = WorkplaceRepositoryImpl(
    WorkplaceDataSourceImpl(),
    WorkplaceDriveDataSourceImpl(),
  );
  return (
    runner: WorkplaceAccessModeRunner(
      exchangeTokenInteractor: ExchangeDriveTokenInteractor(repository),
      oidcTokenGetter: () =>
          getBinding<AuthorizationInterceptors>()?.currentOidcIdToken,
      oidcRefreshTrigger: _refreshWorkplaceOidcToken,
    ),
    interactor: UploadDriveFileInteractor(repository),
  );
}

/// Same body as `_refreshWorkplaceOidcToken` in the extension registry provider.
Future<String?> _refreshWorkplaceOidcToken() async {
  final interceptor = getBinding<AuthorizationInterceptors>();
  if (interceptor == null) return null;
  final newToken = await interceptor.requestTokenRefresh();
  return newToken.tokenId.uuid;
}
