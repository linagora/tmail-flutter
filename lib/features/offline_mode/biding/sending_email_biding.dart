import 'package:core/data/model/source_type/data_source_type.dart';
import 'package:core/data/network/dio_client.dart';
import 'package:core/utils/file_utils.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/base/interactors_bindings.dart';
import 'package:tmail_ui_user/features/caching/clients/state_cache_client.dart';
import 'package:tmail_ui_user/features/composer/domain/usecases/send_email_interactor.dart';
import 'package:tmail_ui_user/features/email/data/datasource/email_datasource.dart';
import 'package:tmail_ui_user/features/email/data/datasource/html_datasource.dart';
import 'package:tmail_ui_user/features/email/data/datasource_impl/email_datasource_impl.dart';
import 'package:tmail_ui_user/features/email/data/datasource_impl/email_hive_cache_datasource_impl.dart';
import 'package:tmail_ui_user/features/email/data/datasource_impl/html_datasource_impl.dart';
import 'package:tmail_ui_user/features/email/data/local/html_analyzer.dart';
import 'package:tmail_ui_user/features/email/data/network/email_api.dart';
import 'package:tmail_ui_user/features/email/data/repository/email_repository_impl.dart';
import 'package:tmail_ui_user/features/email/domain/repository/email_repository.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/delete_sending_email_interactor.dart';
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
import 'package:tmail_ui_user/features/offline_mode/manager/detailed_email_cache_manager.dart';
import 'package:tmail_ui_user/features/offline_mode/manager/detailed_email_cache_worker_queue.dart';
import 'package:tmail_ui_user/features/offline_mode/manager/opened_email_cache_manager.dart';
import 'package:tmail_ui_user/features/offline_mode/manager/opened_email_cache_worker_queue.dart';
import 'package:tmail_ui_user/features/offline_mode/manager/sending_email_cache_manager.dart';
import 'package:tmail_ui_user/features/thread/data/local/email_cache_manager.dart';
import 'package:tmail_ui_user/main/exceptions/cache_exception_thrower.dart';
import 'package:tmail_ui_user/main/exceptions/remote_exception_thrower.dart';

class SendingEmailBindings extends InteractorsBindings {

  @override
  void bindingsDataSource() {
    Get.lazyPut<EmailDataSource>(() => Get.find<EmailDataSourceImpl>());
    Get.lazyPut<MailboxDataSource>(() => Get.find<MailboxDataSourceImpl>());
    Get.lazyPut<HtmlDataSource>(() => Get.find<HtmlDataSourceImpl>());
    Get.lazyPut<StateDataSource>(() => Get.find<StateDataSourceImpl>());
  }

  @override
  void bindingsDataSourceImpl() {
    Get.lazyPut(() => EmailDataSourceImpl(
      Get.find<EmailAPI>(),
      Get.find<RemoteExceptionThrower>()));
    Get.lazyPut(() => MailboxDataSourceImpl(
      Get.find<MailboxAPI>(),
      Get.find<MailboxIsolateWorker>(),
      Get.find<RemoteExceptionThrower>()));
    Get.lazyPut(() => MailboxCacheDataSourceImpl(
      Get.find<MailboxCacheManager>(),
      Get.find<CacheExceptionThrower>()));
    Get.lazyPut(() => HtmlDataSourceImpl(
      Get.find<HtmlAnalyzer>(),
      Get.find<DioClient>(),
      Get.find<RemoteExceptionThrower>()));
    Get.lazyPut(() => StateDataSourceImpl(
      Get.find<StateCacheClient>(),
      Get.find<CacheExceptionThrower>()));
    Get.lazyPut(() => EmailHiveCacheDataSourceImpl(
      Get.find<DetailedEmailCacheManager>(),
      Get.find<OpenedEmailCacheManager>(),
      Get.find<DetailedEmailCacheWorkerQueue>(),
      Get.find<OpenedEmailCacheWorkerQueue>(),
      Get.find<EmailCacheManager>(),
      Get.find<SendingEmailCacheManager>(),
      Get.find<FileUtils>(),
      Get.find<CacheExceptionThrower>()));
  }

  @override
  void bindingsInteractor() {
    Get.lazyPut(() => SendEmailInteractor(
        Get.find<EmailRepository>(),
        Get.find<MailboxRepository>()
    ));
    Get.lazyPut(() => DeleteSendingEmailInteractor(Get.find<EmailRepository>()));
  }

  @override
  void bindingsRepository() {
    Get.lazyPut<EmailRepository>(() => Get.find<EmailRepositoryImpl>());
    Get.lazyPut<MailboxRepository>(() => Get.find<MailboxRepositoryImpl>());
  }

  @override
  void bindingsRepositoryImpl() {
    Get.lazyPut(() => EmailRepositoryImpl(
      {
        DataSourceType.network: Get.find<EmailDataSource>(),
        DataSourceType.hiveCache: Get.find<EmailHiveCacheDataSourceImpl>()
      },
      Get.find<HtmlDataSource>(),
      Get.find<StateDataSource>(),
    ));
    Get.lazyPut(() => MailboxRepositoryImpl(
      {
        DataSourceType.network: Get.find<MailboxDataSource>(),
        DataSourceType.local: Get.find<MailboxCacheDataSourceImpl>()
      },
      Get.find<StateDataSource>(),
    ));
  }

}