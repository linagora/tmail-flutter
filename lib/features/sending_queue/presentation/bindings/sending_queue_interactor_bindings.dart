
import 'package:core/utils/file_utils.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/base/interactors_bindings.dart';
import 'package:tmail_ui_user/features/email/data/datasource_impl/email_hive_cache_datasource_impl.dart';
import 'package:tmail_ui_user/features/sending_queue/data/repository/sending_queue_repository_impl.dart';
import 'package:tmail_ui_user/features/sending_queue/domain/repository/sending_queue_repository.dart';
import 'package:tmail_ui_user/features/sending_queue/domain/usecases/get_all_sending_email_interactor.dart';
import 'package:tmail_ui_user/features/offline_mode/manager/detailed_email_cache_manager.dart';
import 'package:tmail_ui_user/features/offline_mode/manager/detailed_email_cache_worker_queue.dart';
import 'package:tmail_ui_user/features/offline_mode/manager/opened_email_cache_manager.dart';
import 'package:tmail_ui_user/features/offline_mode/manager/opened_email_cache_worker_queue.dart';
import 'package:tmail_ui_user/features/offline_mode/manager/sending_email_cache_manager.dart';
import 'package:tmail_ui_user/features/thread/data/local/email_cache_manager.dart';
import 'package:tmail_ui_user/main/exceptions/cache_exception_thrower.dart';

class SendingQueueInteractorBindings extends InteractorsBindings {

  @override
  void bindingsDataSource() {}

  @override
  void bindingsDataSourceImpl() {
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
    Get.lazyPut(() => GetAllSendingEmailInteractor(Get.find<SendingQueueRepository>()));
  }

  @override
  void bindingsRepository() {
    Get.lazyPut<SendingQueueRepository>(() => Get.find<SendingQueueRepositoryImpl>());
  }

  @override
  void bindingsRepositoryImpl() {
    Get.lazyPut(() => SendingQueueRepositoryImpl(Get.find<EmailHiveCacheDataSourceImpl>()));
  }
}