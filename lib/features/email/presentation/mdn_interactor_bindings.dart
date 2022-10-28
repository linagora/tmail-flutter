import 'package:get/get.dart';
import 'package:tmail_ui_user/features/base/interactors_bindings.dart';
import 'package:tmail_ui_user/features/email/data/datasource/mdn_datasource.dart';
import 'package:tmail_ui_user/features/email/data/datasource_impl/mdn_datasource_impl.dart';
import 'package:tmail_ui_user/features/email/data/network/mdn_api.dart';
import 'package:tmail_ui_user/features/email/data/repository/mdn_repository_impl.dart';
import 'package:tmail_ui_user/features/email/domain/repository/mdn_repository.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/send_receipt_to_sender_interactor.dart';
import 'package:tmail_ui_user/main/exceptions/remote_exception_thrower.dart';

class MdnInteractorBindings extends InteractorsBindings {

  @override
  void bindingsDataSource() {
    Get.lazyPut<MdnDataSource>(() => Get.find<MdnDataSourceImpl>());
  }

  @override
  void bindingsDataSourceImpl() {
    Get.lazyPut(() => MdnDataSourceImpl(Get.find<MdnAPI>(), Get.find<RemoteExceptionThrower>()));
  }

  @override
  void bindingsInteractor() {
    Get.lazyPut(() => SendReceiptToSenderInteractor(Get.find<MdnRepository>()));
  }

  @override
  void bindingsRepository() {
    Get.lazyPut<MdnRepository>(() => Get.find<MdnRepositoryImpl>());
  }

  @override
  void bindingsRepositoryImpl() {
    Get.lazyPut(() => MdnRepositoryImpl(Get.find<MdnDataSource>()));
  }
}