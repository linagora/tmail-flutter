import 'package:core/core.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/base/base_bindings.dart';
import 'package:tmail_ui_user/features/caching/recent_search_cache_client.dart';
import 'package:tmail_ui_user/features/caching/state_cache_client.dart';
import 'package:tmail_ui_user/features/email/data/datasource/email_datasource.dart';
import 'package:tmail_ui_user/features/email/data/datasource/html_datasource.dart';
import 'package:tmail_ui_user/features/email/data/datasource_impl/email_datasource_impl.dart';
import 'package:tmail_ui_user/features/email/data/datasource_impl/html_datasource_impl.dart';
import 'package:tmail_ui_user/features/email/data/local/html_analyzer.dart';
import 'package:tmail_ui_user/features/email/data/network/email_api.dart';
import 'package:tmail_ui_user/features/email/data/repository/email_repository_impl.dart';
import 'package:tmail_ui_user/features/email/domain/repository/email_repository.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/delete_email_permanently_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/move_to_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/email/presentation/email_bindings.dart';
import 'package:tmail_ui_user/features/login/domain/repository/credential_repository.dart';
import 'package:tmail_ui_user/features/mailbox/data/datasource/state_datasource.dart';
import 'package:tmail_ui_user/features/mailbox/data/datasource_impl/state_datasource_impl.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/mailbox_bindings.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/data/datasource/search_datasource.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/data/datasource_impl/search_datasource_impl.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/data/repository/search_repository_impl.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/repository/search_repository.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/usecases/get_all_recent_search_latest_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/usecases/get_user_profile_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/usecases/quick_search_email_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/usecases/remove_email_drafts_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/usecases/save_recent_search_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/mailbox_dashboard_controller.dart';
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
    Get.put(MailboxDashBoardController(
      Get.find<MoveToMailboxInteractor>(),
      Get.find<DeleteEmailPermanentlyInteractor>(),
      Get.find<SaveRecentSearchInteractor>(),
      Get.find<GetAllRecentSearchLatestInteractor>(),
      Get.find<QuickSearchEmailInteractor>(),
    ));
  }

  @override
  void bindingsDataSource() {
    Get.lazyPut<EmailDataSource>(() => Get.find<EmailDataSourceImpl>());
    Get.lazyPut<HtmlDataSource>(() => Get.find<HtmlDataSourceImpl>());
    Get.lazyPut<SearchDataSource>(() => Get.find<SearchDataSourceImpl>());
    Get.lazyPut<ThreadDataSource>(() => Get.find<ThreadDataSourceImpl>());
    Get.lazyPut<StateDataSource>(() => Get.find<StateDataSourceImpl>());
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
  }

  @override
  void bindingsInteractor() {
    Get.lazyPut(() => GetUserProfileInteractor(Get.find<CredentialRepository>()));
    Get.lazyPut(() => RemoveEmailDraftsInteractor(Get.find<EmailRepository>()));
    Get.lazyPut(() => MoveToMailboxInteractor(Get.find<EmailRepository>()));
    Get.lazyPut(() => DeleteEmailPermanentlyInteractor(Get.find<EmailRepository>()));
    Get.lazyPut(() => SaveRecentSearchInteractor(Get.find<SearchRepository>()));
    Get.lazyPut(() => GetAllRecentSearchLatestInteractor(Get.find<SearchRepository>()));
    Get.lazyPut(() => QuickSearchEmailInteractor(Get.find<ThreadRepository>()));
  }

  @override
  void bindingsRepository() {
    Get.lazyPut<EmailRepository>(() => Get.find<EmailRepositoryImpl>());
    Get.lazyPut<SearchRepository>(() => Get.find<SearchRepositoryImpl>());
    Get.lazyPut<ThreadRepository>(() => Get.find<ThreadRepositoryImpl>());
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
  }
}