import 'package:core/core.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/base/base_bindings.dart';
import 'package:tmail_ui_user/features/caching/state_cache_client.dart';
import 'package:tmail_ui_user/features/email/data/datasource/email_datasource.dart';
import 'package:tmail_ui_user/features/email/data/datasource/html_datasource.dart';
import 'package:tmail_ui_user/features/email/data/datasource_impl/email_datasource_impl.dart';
import 'package:tmail_ui_user/features/email/data/datasource_impl/html_datasource_impl.dart';
import 'package:tmail_ui_user/features/email/data/local/html_analyzer.dart';
import 'package:tmail_ui_user/features/email/data/network/email_api.dart';
import 'package:tmail_ui_user/features/email/data/repository/email_repository_impl.dart';
import 'package:tmail_ui_user/features/email/domain/repository/email_repository.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/delete_multiple_emails_permanently_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/mark_as_email_read_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/mark_as_star_email_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/move_to_mailbox_interactor.dart';
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
import 'package:tmail_ui_user/features/thread/data/datasource/thread_datasource.dart';
import 'package:tmail_ui_user/features/thread/data/datasource_impl/local_thread_datasource_impl.dart';
import 'package:tmail_ui_user/features/thread/data/datasource_impl/thread_datasource_impl.dart';
import 'package:tmail_ui_user/features/thread/data/local/email_cache_manager.dart';
import 'package:tmail_ui_user/features/thread/data/network/thread_api.dart';
import 'package:tmail_ui_user/features/thread/data/network/thread_isolate_worker.dart';
import 'package:tmail_ui_user/features/thread/data/repository/thread_repository_impl.dart';
import 'package:tmail_ui_user/features/thread/domain/repository/thread_repository.dart';
import 'package:tmail_ui_user/features/thread/domain/usecases/empty_trash_folder_interactor.dart';
import 'package:tmail_ui_user/features/thread/domain/usecases/get_emails_in_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/thread/domain/usecases/load_more_emails_in_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/thread/domain/usecases/mark_as_multiple_email_read_interactor.dart';
import 'package:tmail_ui_user/features/thread/domain/usecases/mark_as_star_multiple_email_interactor.dart';
import 'package:tmail_ui_user/features/thread/domain/usecases/move_multiple_email_to_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/thread/domain/usecases/refresh_changes_emails_in_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/thread/domain/usecases/resync_thread_interactor.dart';
import 'package:tmail_ui_user/features/thread/domain/usecases/search_email_interactor.dart';
import 'package:tmail_ui_user/features/thread/domain/usecases/search_more_email_interactor.dart';
import 'package:tmail_ui_user/features/thread/presentation/thread_controller.dart';

class ThreadBindings extends BaseBindings {

  @override
  void bindingsController() {
    Get.put(ThreadController(
      Get.find<GetEmailsInMailboxInteractor>(),
      Get.find<MarkAsMultipleEmailReadInteractor>(),
      Get.find<MoveMultipleEmailToMailboxInteractor>(),
      Get.find<MarkAsStarEmailInteractor>(),
      Get.find<MarkAsStarMultipleEmailInteractor>(),
      Get.find<RefreshChangesEmailsInMailboxInteractor>(),
      Get.find<LoadMoreEmailsInMailboxInteractor>(),
      Get.find<SearchEmailInteractor>(),
      Get.find<SearchMoreEmailInteractor>(),
      Get.find<DeleteMultipleEmailsPermanentlyInteractor>(),
      Get.find<EmptyTrashFolderInteractor>(),
      Get.find<MarkAsEmailReadInteractor>(),
      Get.find<MoveToMailboxInteractor>(),
      Get.find<ReSyncThreadInteractor>()
    ));
  }

  @override
  void bindingsDataSource() {
    Get.lazyPut<MailboxDataSource>(() => Get.find<MailboxDataSourceImpl>());
    Get.lazyPut<ThreadDataSource>(() => Get.find<ThreadDataSourceImpl>());
    Get.lazyPut<StateDataSource>(() => Get.find<StateDataSourceImpl>());
    Get.lazyPut<EmailDataSource>(() => Get.find<EmailDataSourceImpl>());
    Get.lazyPut<HtmlDataSource>(() => Get.find<HtmlDataSourceImpl>());
  }

  @override
  void bindingsDataSourceImpl() {
    Get.lazyPut(() => MailboxDataSourceImpl(Get.find<MailboxAPI>(), Get.find<MailboxIsolateWorker>()));
    Get.lazyPut(() => MailboxCacheDataSourceImpl(Get.find<MailboxCacheManager>()));
    Get.lazyPut(() => ThreadDataSourceImpl(Get.find<ThreadAPI>(), Get.find<ThreadIsolateWorker>()));
    Get.lazyPut(() => LocalThreadDataSourceImpl(Get.find<EmailCacheManager>()));
    Get.lazyPut(() => StateDataSourceImpl(Get.find<StateCacheClient>()));
    Get.lazyPut(() => EmailDataSourceImpl(Get.find<EmailAPI>()));
    Get.lazyPut(() => HtmlDataSourceImpl(
        Get.find<HtmlAnalyzer>(),
        Get.find<DioClient>(),
    ));
  }

  @override
  void bindingsInteractor() {
    Get.lazyPut(() => GetEmailsInMailboxInteractor(Get.find<ThreadRepository>()));
    Get.lazyPut(() => MarkAsEmailReadInteractor(
        Get.find<EmailRepository>(),
        Get.find<MailboxRepository>()));
    Get.lazyPut(() => MarkAsMultipleEmailReadInteractor(
        Get.find<EmailRepository>(),
        Get.find<MailboxRepository>()));
    Get.lazyPut(() => MoveToMailboxInteractor(
        Get.find<EmailRepository>(),
        Get.find<MailboxRepository>()));
    Get.lazyPut(() => MoveMultipleEmailToMailboxInteractor(
        Get.find<EmailRepository>(),
        Get.find<MailboxRepository>()));
    Get.lazyPut(() => MarkAsStarEmailInteractor(Get.find<EmailRepository>()));
    Get.lazyPut(() => MarkAsStarMultipleEmailInteractor(Get.find<EmailRepository>()));
    Get.lazyPut(() => RefreshChangesEmailsInMailboxInteractor(Get.find<ThreadRepository>()));
    Get.lazyPut(() => LoadMoreEmailsInMailboxInteractor(Get.find<ThreadRepository>()));
    Get.lazyPut(() => SearchEmailInteractor(Get.find<ThreadRepository>()));
    Get.lazyPut(() => SearchMoreEmailInteractor(Get.find<ThreadRepository>()));
    Get.lazyPut(() => DeleteMultipleEmailsPermanentlyInteractor(
        Get.find<EmailRepository>(),
        Get.find<MailboxRepository>()));
    Get.lazyPut(() => EmptyTrashFolderInteractor(
        Get.find<ThreadRepository>(),
        Get.find<MailboxRepository>(),
        Get.find<EmailRepository>()));
    Get.lazyPut(() => MarkAsEmailReadInteractor(
        Get.find<EmailRepository>(),
        Get.find<MailboxRepository>()));
    Get.lazyPut(() => MoveToMailboxInteractor(
        Get.find<EmailRepository>(),
        Get.find<MailboxRepository>()));
    Get.lazyPut(() => ReSyncThreadInteractor(
        Get.find<ThreadRepository>()
    ));
  }

  @override
  void bindingsRepository() {
    Get.lazyPut<MailboxRepository>(() => Get.find<MailboxRepositoryImpl>());
    Get.lazyPut<ThreadRepository>(() => Get.find<ThreadRepositoryImpl>());
    Get.lazyPut<EmailRepository>(() => Get.find<EmailRepositoryImpl>());
  }

  @override
  void bindingsRepositoryImpl() {
    Get.lazyPut(() => MailboxRepositoryImpl(
      {
        DataSourceType.network: Get.find<MailboxDataSource>(),
        DataSourceType.local: Get.find<MailboxCacheDataSourceImpl>()
      },
      Get.find<StateDataSource>(),
    ));
    Get.lazyPut(() => ThreadRepositoryImpl(
        {
          DataSourceType.network: Get.find<ThreadDataSource>(),
          DataSourceType.local: Get.find<LocalThreadDataSourceImpl>()
        },
        Get.find<StateDataSource>(),
        Get.find<EmailDataSource>(),
    ));
    Get.lazyPut(() => EmailRepositoryImpl(
        Get.find<EmailDataSource>(),
        Get.find<HtmlDataSource>(),
        Get.find<StateDataSource>()
    ));
  }
}