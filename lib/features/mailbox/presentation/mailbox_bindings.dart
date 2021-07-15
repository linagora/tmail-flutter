import 'package:get/get.dart';
import 'package:tmail_ui_user/features/mailbox/data/datasource/mailbox_datasource.dart';
import 'package:tmail_ui_user/features/mailbox/data/datasource_impl/mailbox_datasource_impl.dart';
import 'package:tmail_ui_user/features/mailbox/data/network/mailbox_api.dart';
import 'package:tmail_ui_user/features/mailbox/data/repository/mailbox_repository_impl.dart';
import 'package:tmail_ui_user/features/mailbox/domain/repository/mailbox_repository.dart';
import 'package:tmail_ui_user/features/mailbox/domain/usecases/get_all_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/mailbox_controller.dart';

class MailboxBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => MailboxDataSourceImpl(Get.find<MailboxAPI>()));
    Get.lazyPut<MailboxDataSource>(() => Get.find<MailboxDataSourceImpl>());

    Get.lazyPut(() => MailboxRepositoryImpl(Get.find<MailboxDataSource>()));
    Get.lazyPut<MailboxRepository>(() => Get.find<MailboxRepositoryImpl>());

    Get.lazyPut(() => GetAllMailboxInteractor(Get.find<MailboxRepository>()));

    Get.lazyPut(() => MailboxController(Get.find<GetAllMailboxInteractor>()));
  }
}