import 'package:core/core.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/base/base_bindings.dart';
import 'package:tmail_ui_user/features/caching/recent_search_cache_client.dart';
import 'package:tmail_ui_user/features/caching/state_cache_client.dart';
import 'package:tmail_ui_user/features/composer/data/repository/auto_complete_repository_impl.dart';
import 'package:tmail_ui_user/features/composer/data/repository/contact_repository_impl.dart';
import 'package:tmail_ui_user/features/composer/domain/repository/auto_complete_repository.dart';
import 'package:tmail_ui_user/features/composer/domain/repository/contact_repository.dart';
import 'package:tmail_ui_user/features/composer/domain/usecases/get_autocomplete_interactor.dart';
import 'package:tmail_ui_user/features/composer/domain/usecases/get_autocomplete_with_device_contact_interactor.dart';
import 'package:tmail_ui_user/features/composer/domain/usecases/get_device_contact_suggestions_interactor.dart';
import 'package:tmail_ui_user/features/email/data/datasource/email_datasource.dart';
import 'package:tmail_ui_user/features/email/data/datasource/html_datasource.dart';
import 'package:tmail_ui_user/features/email/data/datasource_impl/email_datasource_impl.dart';
import 'package:tmail_ui_user/features/email/data/datasource_impl/html_datasource_impl.dart';
import 'package:tmail_ui_user/features/email/data/local/html_analyzer.dart';
import 'package:tmail_ui_user/features/email/data/network/email_api.dart';
import 'package:tmail_ui_user/features/email/data/repository/email_repository_impl.dart';
import 'package:tmail_ui_user/features/email/domain/repository/email_repository.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/delete_email_permanently_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/data/datasource/composer_cache_datasource.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/data/datasource_impl/composer_cache_datasoure_impl.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/data/repository/composer_cache_repository_impl.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/repository/composer_cache_repository.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/usecases/get_composer_cache_on_web_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/move_to_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/email/presentation/email_bindings.dart';
import 'package:tmail_ui_user/features/login/data/datasource/account_datasource.dart';
import 'package:tmail_ui_user/features/login/data/datasource/authentication_oidc_datasource.dart';
import 'package:tmail_ui_user/features/login/data/datasource_impl/authentication_oidc_datasource_impl.dart';
import 'package:tmail_ui_user/features/login/data/datasource_impl/hive_account_datasource_impl.dart';
import 'package:tmail_ui_user/features/login/data/local/account_cache_manager.dart';
import 'package:tmail_ui_user/features/login/data/local/oidc_configuration_cache_manager.dart';
import 'package:tmail_ui_user/features/login/data/local/token_oidc_cache_manager.dart';
import 'package:tmail_ui_user/features/login/data/network/authentication_client/authentication_client_base.dart';
import 'package:tmail_ui_user/features/login/data/network/oidc_http_client.dart';
import 'package:tmail_ui_user/features/login/data/repository/account_repository_impl.dart';
import 'package:tmail_ui_user/features/login/data/repository/authentication_oidc_repository_impl.dart';
import 'package:tmail_ui_user/features/login/domain/repository/account_repository.dart';
import 'package:tmail_ui_user/features/login/domain/repository/authentication_oidc_repository.dart';
import 'package:tmail_ui_user/features/login/domain/repository/credential_repository.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/delete_authority_oidc_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/get_authenticated_account_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/get_credential_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/get_stored_token_oidc_interactor.dart';
import 'package:tmail_ui_user/features/mailbox/data/datasource/mailbox_datasource.dart';
import 'package:tmail_ui_user/features/mailbox/data/datasource/state_datasource.dart';
import 'package:tmail_ui_user/features/mailbox/data/datasource_impl/mailbox_cache_datasource_impl.dart';
import 'package:tmail_ui_user/features/mailbox/data/datasource_impl/mailbox_datasource_impl.dart';
import 'package:tmail_ui_user/features/mailbox/data/datasource_impl/state_datasource_impl.dart';
import 'package:tmail_ui_user/features/mailbox/data/local/mailbox_cache_manager.dart';
import 'package:tmail_ui_user/features/mailbox/data/network/mailbox_api.dart';
import 'package:tmail_ui_user/features/mailbox/data/network/mailbox_isolate_worker.dart';
import 'package:tmail_ui_user/features/mailbox/data/repository/mailbox_repository_impl.dart';
import 'package:tmail_ui_user/features/mailbox/domain/repository/mailbox_repository.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/mailbox_bindings.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/data/datasource/search_datasource.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/data/datasource_impl/search_datasource_impl.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/data/repository/search_repository_impl.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/repository/search_repository.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/usecases/get_all_recent_search_latest_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/usecases/get_user_profile_interactor.dart';
import 'package:tmail_ui_user/features/mailbox/domain/usecases/mark_as_mailbox_read_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/usecases/quick_search_email_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/usecases/remove_composer_cache_on_web_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/usecases/remove_email_drafts_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/usecases/save_composer_cache_on_web_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/usecases/save_recent_search_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/advanced_filter_controller.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/search_controller.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/log_out_oidc_interactor.dart';
import 'package:tmail_ui_user/features/thread/data/datasource/thread_datasource.dart';
import 'package:tmail_ui_user/features/thread/data/datasource_impl/local_thread_datasource_impl.dart';
import 'package:tmail_ui_user/features/thread/data/datasource_impl/thread_datasource_impl.dart';
import 'package:tmail_ui_user/features/thread/data/local/email_cache_manager.dart';
import 'package:tmail_ui_user/features/thread/data/network/thread_api.dart';
import 'package:tmail_ui_user/features/thread/data/repository/thread_repository_impl.dart';
import 'package:tmail_ui_user/features/thread/domain/repository/thread_repository.dart';
import 'package:tmail_ui_user/features/thread/presentation/thread_bindings.dart';

class MailboxDashBoardBindings extends BaseBindings {

  @override
  void dependencies() {
    super.dependencies();
    MailboxBindings().dependencies();
    ThreadBindings().dependencies();
    EmailBindings().dependencies();
  }

  @override
  void bindingsController() {
    Get.put(SearchController(
      Get.find<QuickSearchEmailInteractor>(),
      Get.find<SaveRecentSearchInteractor>(),
      Get.find<GetAllRecentSearchLatestInteractor>(),
    ));
    Get.put(MailboxDashBoardController(
      Get.find<LogoutOidcInteractor>(),
      Get.find<DeleteAuthorityOidcInteractor>(),
      Get.find<GetAuthenticatedAccountInteractor>(),
      Get.find<MoveToMailboxInteractor>(),
      Get.find<DeleteEmailPermanentlyInteractor>(),
      Get.find<MarkAsMailboxReadInteractor>(),
      Get.find<GetComposerCacheOnWebInteractor>(),
    ));
    Get.put(AdvancedFilterController());
  }

  @override
  void bindingsDataSource() {
    Get.lazyPut<EmailDataSource>(() => Get.find<EmailDataSourceImpl>());
    Get.lazyPut<HtmlDataSource>(() => Get.find<HtmlDataSourceImpl>());
    Get.lazyPut<SearchDataSource>(() => Get.find<SearchDataSourceImpl>());
    Get.lazyPut<ThreadDataSource>(() => Get.find<ThreadDataSourceImpl>());
    Get.lazyPut<StateDataSource>(() => Get.find<StateDataSourceImpl>());
    Get.lazyPut<MailboxDataSource>(() => Get.find<MailboxDataSourceImpl>());
    Get.lazyPut<AccountDatasource>(() => Get.find<HiveAccountDatasourceImpl>());
    Get.lazyPut<AuthenticationOIDCDataSource>(() => Get.find<AuthenticationOIDCDataSourceImpl>());
    Get.lazyPut<ComposerCacheDataSource>(() => Get.find<ComposerCacheDataSourceImpl>());
  }

  @override
  void bindingsDataSourceImpl() {
    Get.lazyPut(() => EmailDataSourceImpl(Get.find<EmailAPI>()));
    Get.lazyPut(() => HtmlDataSourceImpl(
        Get.find<HtmlAnalyzer>(),
        Get.find<DioClient>()
    ));
    Get.lazyPut(() => SearchDataSourceImpl(Get.find<RecentSearchCacheClient>()));
    Get.lazyPut(() => ThreadDataSourceImpl(Get.find<ThreadAPI>()));
    Get.lazyPut(() => LocalThreadDataSourceImpl(Get.find<EmailCacheManager>()));
    Get.lazyPut(() => StateDataSourceImpl(Get.find<StateCacheClient>()));
    Get.lazyPut(() => MailboxDataSourceImpl(Get.find<MailboxAPI>(), Get.find<MailboxIsolateWorker>()));
    Get.lazyPut(() => MailboxCacheDataSourceImpl(Get.find<MailboxCacheManager>()));
    Get.lazyPut(() => HiveAccountDatasourceImpl(Get.find<AccountCacheManager>()));
    Get.lazyPut(() => AuthenticationOIDCDataSourceImpl(
        Get.find<OIDCHttpClient>(),
        Get.find<AuthenticationClientBase>(),
        Get.find<TokenOidcCacheManager>(),
        Get.find<OidcConfigurationCacheManager>()
    ));
    Get.lazyPut(() => ComposerCacheDataSourceImpl());
  }

  @override
  void bindingsInteractor() {
    Get.lazyPut(() => GetAutoCompleteInteractor(Get.find<AutoCompleteRepository>()));
    Get.lazyPut(() => GetDeviceContactSuggestionsInteractor(Get.find<ContactRepository>()));
    Get.lazyPut(() => GetAutoCompleteWithDeviceContactInteractor(
        Get.find<GetAutoCompleteInteractor>(),
        Get.find<GetDeviceContactSuggestionsInteractor>()
    ));
    Get.lazyPut(() => GetUserProfileInteractor(Get.find<CredentialRepository>()));
    Get.lazyPut(() => RemoveEmailDraftsInteractor(Get.find<EmailRepository>()));
    Get.lazyPut(() => MoveToMailboxInteractor(Get.find<EmailRepository>()));
    Get.lazyPut(() => DeleteEmailPermanentlyInteractor(Get.find<EmailRepository>()));
    Get.lazyPut(() => SaveRecentSearchInteractor(Get.find<SearchRepository>()));
    Get.lazyPut(() => GetAllRecentSearchLatestInteractor(Get.find<SearchRepository>()));
    Get.lazyPut(() => QuickSearchEmailInteractor(Get.find<ThreadRepository>()));
    Get.lazyPut(() => MarkAsMailboxReadInteractor(Get.find<MailboxRepository>()));
    Get.lazyPut(() => LogoutOidcInteractor(
      Get.find<AccountRepository>(),
      Get.find<AuthenticationOIDCRepository>(),
    ));
    Get.lazyPut(() => DeleteAuthorityOidcInteractor(Get.find<AuthenticationOIDCRepository>()));
    Get.lazyPut(() => GetCredentialInteractor(Get.find<CredentialRepository>()));
    Get.lazyPut(() => GetStoredTokenOidcInteractor(
        Get.find<AuthenticationOIDCRepository>(),
        Get.find<CredentialRepository>(),
    ));
    Get.lazyPut(() => GetAuthenticatedAccountInteractor(
        Get.find<AccountRepository>(),
        Get.find<GetCredentialInteractor>(),
        Get.find<GetStoredTokenOidcInteractor>(),
    ));
    Get.lazyPut(() => GetComposerCacheOnWebInteractor(Get.find<ComposerCacheRepository>()));
    Get.lazyPut(() => SaveComposerCacheOnWebInteractor(Get.find<ComposerCacheRepository>()));
    Get.lazyPut(() => RemoveComposerCacheOnWebInteractor(Get.find<ComposerCacheRepository>()));
  }

  @override
  void bindingsRepository() {
    Get.lazyPut<AutoCompleteRepository>(() => Get.find<AutoCompleteRepositoryImpl>());
    Get.lazyPut<ContactRepository>(() => Get.find<ContactRepositoryImpl>());
    Get.lazyPut<EmailRepository>(() => Get.find<EmailRepositoryImpl>());
    Get.lazyPut<SearchRepository>(() => Get.find<SearchRepositoryImpl>());
    Get.lazyPut<ThreadRepository>(() => Get.find<ThreadRepositoryImpl>());
    Get.lazyPut<MailboxRepository>(() => Get.find<MailboxRepositoryImpl>());
    Get.lazyPut<AccountRepository>(() => Get.find<AccountRepositoryImpl>());
    Get.lazyPut<AuthenticationOIDCRepository>(() => Get.find<AuthenticationOIDCRepositoryImpl>());
    Get.lazyPut<ComposerCacheRepository>(() => Get.find<ComposerCacheRepositoryImpl>());
  }

  @override
  void bindingsRepositoryImpl() {
    Get.lazyPut(() => EmailRepositoryImpl(
        Get.find<EmailDataSource>(),
        Get.find<HtmlDataSource>()
    ));
    Get.lazyPut(() => SearchRepositoryImpl(Get.find<SearchDataSource>()));
    Get.lazyPut(() => ThreadRepositoryImpl(
      {
        DataSourceType.network: Get.find<ThreadDataSource>(),
        DataSourceType.local: Get.find<LocalThreadDataSourceImpl>()
      },
      Get.find<StateDataSource>(),
      Get.find<EmailDataSource>(),
    ));
    Get.lazyPut(() => MailboxRepositoryImpl(
      {
        DataSourceType.network: Get.find<MailboxDataSource>(),
        DataSourceType.local: Get.find<MailboxCacheDataSourceImpl>()
      },
      Get.find<StateDataSource>(),
    ));
    Get.lazyPut(() => AccountRepositoryImpl(Get.find<AccountDatasource>()));
    Get.lazyPut(() => AuthenticationOIDCRepositoryImpl(Get.find<AuthenticationOIDCDataSource>()));
    Get.lazyPut(() => ComposerCacheRepositoryImpl(Get.find<ComposerCacheDataSource>()));
  }
}