import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/thread/data/datasource/thread_datasource.dart';
import 'package:tmail_ui_user/features/thread/data/datasource_impl/thread_datasource_impl.dart';
import 'package:tmail_ui_user/features/thread/data/network/thread_api.dart';
import 'package:tmail_ui_user/features/thread/data/repository/thread_repository_impl.dart';
import 'package:tmail_ui_user/features/thread/domain/repository/thread_repository.dart';
import 'package:tmail_ui_user/features/thread/domain/usecases/get_emails_in_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/thread/presentation/thread_controller.dart';

class ThreadBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ThreadDataSourceImpl(Get.find<ThreadAPI>()));
    Get.lazyPut<ThreadDataSource>(() => Get.find<ThreadDataSourceImpl>());
    Get.lazyPut(() => ThreadRepositoryImpl(Get.find<ThreadDataSource>()));
    Get.lazyPut<ThreadRepository>(() => Get.find<ThreadRepositoryImpl>());
    Get.lazyPut(() => GetEmailsInMailboxInteractor(Get.find<ThreadRepository>()));
    Get.put(ThreadController(
      Get.find<ResponsiveUtils>(),
      Get.find<GetEmailsInMailboxInteractor>(),
    ));
  }
}