import 'package:core/data/network/dio_client.dart';
import 'package:get/get.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tmail_ui_user/features/upload/data/datasource/upload_from_url_datasource.dart';
import 'package:tmail_ui_user/features/upload/data/datasource_impl/upload_from_url_datasource_impl.dart';
import 'package:tmail_ui_user/features/upload/data/network/upload_from_url_api.dart';
import 'package:tmail_ui_user/features/upload/data/repository/upload_from_url_repository_impl.dart';
import 'package:tmail_ui_user/features/upload/domain/repository/upload_from_url_repository.dart';
import 'package:tmail_ui_user/features/upload/domain/usecases/upload_drive_document_from_url_interactor.dart';
import 'package:tmail_ui_user/main/exceptions/thrower/remote_exception_thrower.dart';

part 'upload_from_url_providers.g.dart';

@riverpod
UploadFromUrlApi uploadFromUrlApi(Ref ref) =>
    UploadFromUrlApi(Get.find<DioClient>());

@riverpod
UploadFromUrlDataSource uploadFromUrlDataSource(Ref ref) =>
    UploadFromUrlDataSourceImpl(
      ref.watch(uploadFromUrlApiProvider),
      Get.find<RemoteExceptionThrower>(),
    );

@riverpod
UploadFromUrlRepository uploadFromUrlRepository(Ref ref) =>
    UploadFromUrlRepositoryImpl(ref.watch(uploadFromUrlDataSourceProvider));

@riverpod
UploadDriveDocumentFromUrlInteractor uploadDriveDocumentFromUrlInteractor(Ref ref) =>
    UploadDriveDocumentFromUrlInteractor(ref.watch(uploadFromUrlRepositoryProvider));
