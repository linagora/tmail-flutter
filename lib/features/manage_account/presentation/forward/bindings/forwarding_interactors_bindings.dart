import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/get_instance.dart';
import 'package:tmail_ui_user/features/base/interactors_bindings.dart';
import 'package:tmail_ui_user/features/manage_account/data/datasource/forwarding_datasource.dart';
import 'package:tmail_ui_user/features/manage_account/data/datasource_impl/forwarding_data_source_impl.dart';
import 'package:tmail_ui_user/features/manage_account/data/network/forwarding_api.dart';
import 'package:tmail_ui_user/features/manage_account/data/repository/forwarding_repository_impl.dart';
import 'package:tmail_ui_user/features/manage_account/domain/repository/forwarding_repository.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/add_recipients_in_forwarding_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/delete_recipient_in_forwarding_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/edit_local_copy_in_forwarding_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/get_forward_interactor.dart';
import 'package:tmail_ui_user/main/exceptions/remote_exception_thrower.dart';

class ForwardingInteractorsBindings extends InteractorsBindings {

  @override
  void bindingsDataSource() {
    Get.lazyPut<ForwardingDataSource>(() => Get.find<ForwardingDataSourceImpl>());
  }

  @override
  void bindingsDataSourceImpl() {
    Get.lazyPut(() => ForwardingDataSourceImpl(
      Get.find<ForwardingAPI>(),
      Get.find<RemoteExceptionThrower>()));
  }

  @override
  void bindingsInteractor() {
    Get.lazyPut(() => GetForwardInteractor(Get.find<ForwardingRepository>()));
    Get.lazyPut(() => DeleteRecipientInForwardingInteractor(Get.find<ForwardingRepository>()));
    Get.lazyPut(() => AddRecipientsInForwardingInteractor(Get.find<ForwardingRepository>()));
    Get.lazyPut(() => EditLocalCopyInForwardingInteractor(Get.find<ForwardingRepository>()));
  }

  @override
  void bindingsRepository() {
    Get.lazyPut<ForwardingRepository>(() => Get.find<ForwardingRepositoryImpl>());
  }

  @override
  void bindingsRepositoryImpl() {
    Get.lazyPut(() => ForwardingRepositoryImpl(Get.find<ForwardingDataSource>()));
  }
}