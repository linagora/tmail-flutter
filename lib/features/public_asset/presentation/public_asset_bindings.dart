import 'package:core/data/network/dio_client.dart';
import 'package:core/data/network/download/download_client.dart';
import 'package:core/utils/application_manager.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/http/http_client.dart';
import 'package:tmail_ui_user/features/base/base_bindings.dart';
import 'package:tmail_ui_user/features/composer/data/datasource/composer_datasource.dart';
import 'package:tmail_ui_user/features/composer/data/datasource_impl/composer_datasource_impl.dart';
import 'package:tmail_ui_user/features/composer/data/repository/composer_repository_impl.dart';
import 'package:tmail_ui_user/features/composer/domain/repository/composer_repository.dart';
import 'package:tmail_ui_user/features/composer/domain/usecases/upload_attachment_interactor.dart';
import 'package:tmail_ui_user/features/email/data/datasource/html_datasource.dart';
import 'package:tmail_ui_user/features/email/data/datasource_impl/html_datasource_impl.dart';
import 'package:tmail_ui_user/features/email/data/local/html_analyzer.dart';
import 'package:tmail_ui_user/features/public_asset/domain/usecase/create_public_asset_interactor.dart';
import 'package:tmail_ui_user/features/public_asset/data/datasource/public_asset_datasource.dart';
import 'package:tmail_ui_user/features/public_asset/data/datasource_impl/remote_public_asset_datasource_impl.dart';
import 'package:tmail_ui_user/features/public_asset/data/network/public_asset_api.dart';
import 'package:tmail_ui_user/features/public_asset/data/repository/public_asset_repository_impl.dart';
import 'package:tmail_ui_user/features/public_asset/domain/repository/public_asset_repository.dart';
import 'package:tmail_ui_user/features/public_asset/presentation/model/public_asset_arguments.dart';
import 'package:tmail_ui_user/features/public_asset/presentation/public_asset_controller.dart';
import 'package:tmail_ui_user/features/upload/data/datasource/attachment_upload_datasource.dart';
import 'package:tmail_ui_user/features/upload/data/datasource_impl/attachment_upload_datasource_impl.dart';
import 'package:tmail_ui_user/features/upload/data/network/file_uploader.dart';
import 'package:tmail_ui_user/main/exceptions/exception_thrower.dart';
import 'package:tmail_ui_user/main/exceptions/remote_exception_thrower.dart';
import 'package:uuid/uuid.dart';
import 'package:worker_manager/worker_manager.dart';

class PublicAssetBindings extends BaseBindings {
  PublicAssetBindings(this._publicAssetArguments);

  final PublicAssetArguments _publicAssetArguments;

  @override
  void dependencies() {
    Get.lazyPut(() => FileUploader(Get.find<DioClient>(), Get.find<Executor>()));
    Get.lazyPut<ExceptionThrower>(() => Get.find<RemoteExceptionThrower>());
    Get.lazyPut(() => PublicAssetApi(Get.find<HttpClient>(), Get.find<Uuid>()));

    super.dependencies();
  }

  @override
  void bindingsController() {
    Get.create(() => PublicAssetController(
      Get.find<UploadAttachmentInteractor>(),
      Get.find<CreatePublicAssetInteractor>(),
      arguments: _publicAssetArguments,
    ));
  }

  @override
  void bindingsDataSource() {
    Get.lazyPut<AttachmentUploadDataSource>(
      () => Get.find<AttachmentUploadDataSourceImpl>());
    Get.lazyPut<ComposerDataSource>(() => Get.find<ComposerDataSourceImpl>());
    Get.lazyPut<HtmlDataSource>(() => Get.find<HtmlDataSourceImpl>());
    Get.lazyPut<PublicAssetDatasource>(
      () => Get.find<RemotePublicAssetDatasourceImpl>());
  }

  @override
  void bindingsDataSourceImpl() {
    Get.lazyPut(() => AttachmentUploadDataSourceImpl(
      Get.find<FileUploader>(),
      Get.find<Uuid>(),
      Get.find<ExceptionThrower>()));
    Get.lazyPut(() => ComposerDataSourceImpl(
      Get.find<DownloadClient>(),
      Get.find<ExceptionThrower>()));
    Get.lazyPut(() => HtmlDataSourceImpl(
      Get.find<HtmlAnalyzer>(),
      Get.find<ExceptionThrower>()));
    Get.lazyPut(() => RemotePublicAssetDatasourceImpl(
      Get.find<PublicAssetApi>(),
      Get.find<ExceptionThrower>()));
  }

  @override
  void bindingsInteractor() {
    Get.lazyPut(
      () => UploadAttachmentInteractor(Get.find<ComposerRepository>()));
    Get.lazyPut(
      () => CreatePublicAssetInteractor(Get.find<PublicAssetRepository>()));
  }

  @override
  void bindingsRepository() {
    Get.lazyPut<ComposerRepository>(() => Get.find<ComposerRepositoryImpl>());
    Get.lazyPut<PublicAssetRepository>(
      () => Get.find<PublicAssetRepositoryImpl>());
  }

  @override
  void bindingsRepositoryImpl() {
    Get.lazyPut(() => ComposerRepositoryImpl(
      Get.find<AttachmentUploadDataSource>(),
      Get.find<ComposerDataSource>(),
      Get.find<HtmlDataSource>(),
      Get.find<ApplicationManager>(),
      Get.find<Uuid>()));
    Get.lazyPut(() => PublicAssetRepositoryImpl(
      Get.find<PublicAssetDatasource>()));
  }
}