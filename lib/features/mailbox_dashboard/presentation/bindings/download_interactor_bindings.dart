import 'package:get/get.dart';
import 'package:tmail_ui_user/features/base/interactors_bindings.dart';
import 'package:tmail_ui_user/features/email/data/network/email_api.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/download_all_attachments_for_web_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/download_attachment_for_web_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/repository/account_repository.dart';
import 'package:tmail_ui_user/features/login/domain/repository/authentication_oidc_repository.dart';
import 'package:tmail_ui_user/features/login/domain/repository/credential_repository.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/data/datasource/download_datasource.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/data/datasource_impl/download_datasource_impl.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/data/repository/download_repository_impl.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/repository/download_repository.dart';
import 'package:tmail_ui_user/main/exceptions/remote_exception_thrower.dart';

class DownloadInteractorBindings extends InteractorsBindings {
  @override
  void bindingsDataSourceImpl() {
    Get.lazyPut(
      () => DownloadDatasourceImpl(
        Get.find<EmailAPI>(),
        Get.find<RemoteExceptionThrower>(),
      ),
    );
  }

  @override
  void bindingsInteractor() {
    Get.lazyPut(
      () => DownloadAttachmentForWebInteractor(
        Get.find<DownloadRepository>(),
        Get.find<CredentialRepository>(),
        Get.find<AccountRepository>(),
        Get.find<AuthenticationOIDCRepository>(),
      ),
    );
    Get.lazyPut(
      () => DownloadAllAttachmentsForWebInteractor(
        Get.find<DownloadRepository>(),
        Get.find<AccountRepository>(),
        Get.find<AuthenticationOIDCRepository>(),
        Get.find<CredentialRepository>(),
      ),
    );
  }

  @override
  void bindingsRepository() {
    Get.lazyPut<DownloadRepository>(() => Get.find<DownloadRepositoryImpl>());
  }

  @override
  void bindingsRepositoryImpl() {
    Get.lazyPut(() => DownloadRepositoryImpl(Get.find<DownloadDatasource>()));
  }

  @override
  void bindingsDataSource() {
    Get.lazyPut<DownloadDatasource>(() => Get.find<DownloadDatasourceImpl>());
  }
}
