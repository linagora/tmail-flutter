import 'package:core/core.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/base/interactors_bindings.dart';
import 'package:tmail_ui_user/features/caching/utils/local_storage_manager.dart';
import 'package:tmail_ui_user/features/caching/utils/session_storage_manager.dart';
import 'package:tmail_ui_user/features/email/data/datasource/email_datasource.dart';
import 'package:tmail_ui_user/features/email/data/datasource/html_datasource.dart';
import 'package:tmail_ui_user/features/email/data/datasource_impl/email_datasource_impl.dart';
import 'package:tmail_ui_user/features/email/data/datasource_impl/email_local_storage_datasource_impl.dart';
import 'package:tmail_ui_user/features/email/data/datasource_impl/email_session_storage_datasource_impl.dart';
import 'package:tmail_ui_user/features/email/data/datasource_impl/html_datasource_impl.dart';
import 'package:tmail_ui_user/features/email/data/local/html_analyzer.dart';
import 'package:tmail_ui_user/features/email/data/network/email_api.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/download_all_attachments_for_web_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/download_attachment_for_web_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/get_html_content_from_attachment_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/get_preview_email_eml_content_shared_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/get_preview_eml_content_in_memory_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/move_preview_eml_content_from_persistent_to_memory_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/parse_email_by_blob_id_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/preview_email_from_eml_file_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/remove_preview_email_eml_content_shared_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/repository/account_repository.dart';
import 'package:tmail_ui_user/features/login/domain/repository/authentication_oidc_repository.dart';
import 'package:tmail_ui_user/features/login/domain/repository/credential_repository.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/data/datasource/download_datasource.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/data/datasource_impl/download_datasource_impl.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/data/repository/download_repository_impl.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/repository/download_repository.dart';
import 'package:tmail_ui_user/main/exceptions/cache_exception_thrower.dart';
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
    Get.lazyPut(
      () => EmailDataSourceImpl(
        Get.find<EmailAPI>(),
        Get.find<RemoteExceptionThrower>(),
      ),
    );
    Get.lazyPut(
      () => HtmlDataSourceImpl(
        Get.find<HtmlAnalyzer>(),
        Get.find<CacheExceptionThrower>(),
      ),
    );
    Get.lazyPut(
      () => EmailSessionStorageDatasourceImpl(
        Get.find<SessionStorageManager>(),
        Get.find<CacheExceptionThrower>(),
      ),
    );
    Get.lazyPut(
      () => EmailLocalStorageDataSourceImpl(
        Get.find<LocalStorageManager>(),
        Get.find<PreviewEmlFileUtils>(),
        Get.find<CacheExceptionThrower>(),
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
    Get.lazyPut(
      () => ParseEmailByBlobIdInteractor(Get.find<DownloadRepository>()),
    );
    Get.lazyPut(
      () => PreviewEmailFromEmlFileInteractor(Get.find<DownloadRepository>()),
    );
    Get.lazyPut(
      () => GetHtmlContentFromAttachmentInteractor(
        Get.find<DownloadAttachmentForWebInteractor>(),
      ),
    );
    Get.lazyPut(
      () => MovePreviewEmlContentFromPersistentToMemoryInteractor(
        Get.find<DownloadRepository>(),
      ),
    );
    Get.lazyPut(
      () => RemovePreviewEmailEmlContentSharedInteractor(
        Get.find<DownloadRepository>(),
      ),
    );

    Get.lazyPut(
      () => GetPreviewEmailEMLContentSharedInteractor(
        Get.find<DownloadRepository>(),
      ),
    );
    Get.lazyPut(
      () => GetPreviewEmlContentInMemoryInteractor(
        Get.find<DownloadRepository>(),
      ),
    );
  }

  @override
  void bindingsRepository() {
    Get.lazyPut<DownloadRepository>(() => Get.find<DownloadRepositoryImpl>());
  }

  @override
  void bindingsRepositoryImpl() {
    Get.lazyPut(
      () => DownloadRepositoryImpl(
        Get.find<DownloadDatasource>(),
        {
          DataSourceType.session: Get.find<EmailSessionStorageDatasourceImpl>(),
          DataSourceType.local: Get.find<EmailLocalStorageDataSourceImpl>(),
          DataSourceType.network: Get.find<EmailDataSource>(),
        },
        Get.find<HtmlDataSource>(),
      ),
    );
  }

  @override
  void bindingsDataSource() {
    Get.lazyPut<DownloadDatasource>(() => Get.find<DownloadDatasourceImpl>());
    Get.lazyPut<EmailDataSource>(() => Get.find<EmailDataSourceImpl>());
    Get.lazyPut<HtmlDataSource>(() => Get.find<HtmlDataSourceImpl>());
  }
}
