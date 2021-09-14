import 'package:get/get.dart';
import 'package:tmail_ui_user/features/email/data/datasource/email_datasource.dart';
import 'package:tmail_ui_user/features/email/data/datasource_impl/email_datasource_impl.dart';
import 'package:tmail_ui_user/features/email/data/network/email_api.dart';
import 'package:tmail_ui_user/features/email/data/repository/email_repository_impl.dart';
import 'package:tmail_ui_user/features/email/domain/repository/email_repository.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/get_email_content_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/mark_as_email_read_interactor.dart';
import 'package:tmail_ui_user/features/email/presentation/email_controller.dart';

class EmailBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => EmailDataSourceImpl(Get.find<EmailAPI>()));
    Get.lazyPut<EmailDataSource>(() => Get.find<EmailDataSourceImpl>());
    Get.lazyPut(() => EmailRepositoryImpl(Get.find<EmailDataSource>()));
    Get.lazyPut<EmailRepository>(() => Get.find<EmailRepositoryImpl>());
    Get.lazyPut(() => GetEmailContentInteractor(Get.find<EmailRepository>()));
    Get.lazyPut(() => MarkAsEmailReadInteractor(Get.find<EmailRepository>()));
    Get.put(EmailController(
      Get.find<GetEmailContentInteractor>(),
      Get.find<MarkAsEmailReadInteractor>()));
  }
}