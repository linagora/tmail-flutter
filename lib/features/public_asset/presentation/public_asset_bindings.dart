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
import 'package:tmail_ui_user/features/public_asset/domain/usecase/delete_public_assets_interactor.dart';
import 'package:tmail_ui_user/features/public_asset/presentation/model/public_asset_arguments.dart';
import 'package:tmail_ui_user/features/public_asset/presentation/public_asset_controller.dart';
import 'package:tmail_ui_user/features/upload/data/datasource/attachment_upload_datasource.dart';
import 'package:tmail_ui_user/features/upload/data/datasource_impl/attachment_upload_datasource_impl.dart';
import 'package:tmail_ui_user/features/upload/data/network/file_uploader.dart';
import 'package:tmail_ui_user/main/bindings/network/binding_tag.dart';
import 'package:tmail_ui_user/main/exceptions/cache_exception_thrower.dart';
import 'package:tmail_ui_user/main/exceptions/remote_exception_thrower.dart';
import 'package:uuid/uuid.dart';

class PublicAssetBindings extends BaseBindings {
  PublicAssetBindings(this._publicAssetArguments);

  final PublicAssetArguments _publicAssetArguments;

  @override
  void dependencies() {
    Get.lazyPut(
      () => PublicAssetApi(Get.find<HttpClient>(), Get.find<Uuid>()),
      tag: BindingTag.publicAssetBindingsTag);

    super.dependencies();
  }

  @override
  void bindingsController() {
    Get.create(
      () => PublicAssetController(
        Get.find<UploadAttachmentInteractor>(tag: BindingTag.publicAssetBindingsTag),
        Get.find<CreatePublicAssetInteractor>(tag: BindingTag.publicAssetBindingsTag),
        Get.find<DeletePublicAssetsInteractor>(tag: BindingTag.publicAssetBindingsTag),
        arguments: _publicAssetArguments),
      tag: BindingTag.publicAssetBindingsTag);
  }

  @override
  void bindingsDataSource() {
    Get.lazyPut<AttachmentUploadDataSource>(
      () => Get.find<AttachmentUploadDataSourceImpl>(tag: BindingTag.publicAssetBindingsTag),
      tag: BindingTag.publicAssetBindingsTag);
    Get.lazyPut<ComposerDataSource>(
      () => Get.find<ComposerDataSourceImpl>(tag: BindingTag.publicAssetBindingsTag),
      tag: BindingTag.publicAssetBindingsTag);
    Get.lazyPut<HtmlDataSource>(
      () => Get.find<HtmlDataSourceImpl>(tag: BindingTag.publicAssetBindingsTag),
      tag: BindingTag.publicAssetBindingsTag);
    Get.lazyPut<PublicAssetDatasource>(
      () => Get.find<RemotePublicAssetDatasourceImpl>(tag: BindingTag.publicAssetBindingsTag),
      tag: BindingTag.publicAssetBindingsTag);
  }

  @override
  void bindingsDataSourceImpl() {
    Get.lazyPut(
      () => AttachmentUploadDataSourceImpl(
        Get.find<FileUploader>(),
        Get.find<Uuid>(),
        Get.find<RemoteExceptionThrower>()),
      tag: BindingTag.publicAssetBindingsTag);
    Get.lazyPut(
      () => ComposerDataSourceImpl(
        Get.find<DownloadClient>(),
        Get.find<RemoteExceptionThrower>()),
      tag: BindingTag.publicAssetBindingsTag);
    Get.lazyPut(
      () => HtmlDataSourceImpl(
        Get.find<HtmlAnalyzer>(),
        Get.find<CacheExceptionThrower>()),
      tag: BindingTag.publicAssetBindingsTag);
    Get.lazyPut(
      () => RemotePublicAssetDatasourceImpl(
        Get.find<PublicAssetApi>(tag: BindingTag.publicAssetBindingsTag),
        Get.find<RemoteExceptionThrower>()),
      tag: BindingTag.publicAssetBindingsTag);
  }

  @override
  void bindingsInteractor() {
    Get.lazyPut(
      () => UploadAttachmentInteractor(Get.find<ComposerRepository>(tag: BindingTag.publicAssetBindingsTag)),
      tag: BindingTag.publicAssetBindingsTag);
    Get.lazyPut(
      () => CreatePublicAssetInteractor(Get.find<PublicAssetRepository>(tag: BindingTag.publicAssetBindingsTag)),
      tag: BindingTag.publicAssetBindingsTag);
    Get.lazyPut(
      () => DeletePublicAssetsInteractor(Get.find<PublicAssetRepository>(tag: BindingTag.publicAssetBindingsTag)),
      tag: BindingTag.publicAssetBindingsTag);
  }

  @override
  void bindingsRepository() {
    Get.lazyPut<ComposerRepository>(
      () => Get.find<ComposerRepositoryImpl>(tag: BindingTag.publicAssetBindingsTag),
      tag: BindingTag.publicAssetBindingsTag);
    Get.lazyPut<PublicAssetRepository>(
      () => Get.find<PublicAssetRepositoryImpl>(tag: BindingTag.publicAssetBindingsTag),
      tag: BindingTag.publicAssetBindingsTag);
  }

  @override
  void bindingsRepositoryImpl() {
    Get.lazyPut(
      () => ComposerRepositoryImpl(
        Get.find<AttachmentUploadDataSource>(tag: BindingTag.publicAssetBindingsTag),
        Get.find<ComposerDataSource>(tag: BindingTag.publicAssetBindingsTag),
        Get.find<HtmlDataSource>(tag: BindingTag.publicAssetBindingsTag),
        Get.find<ApplicationManager>(),
        Get.find<Uuid>()),
      tag: BindingTag.publicAssetBindingsTag);
    Get.lazyPut(
      () => PublicAssetRepositoryImpl(Get.find<PublicAssetDatasource>(tag: BindingTag.publicAssetBindingsTag)),
      tag: BindingTag.publicAssetBindingsTag);
  }
}