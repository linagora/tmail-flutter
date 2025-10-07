import 'package:get/get.dart';
import 'package:tmail_ui_user/features/base/interactors_bindings.dart';
import 'package:tmail_ui_user/features/quotas/data/datasource/quotas_data_source.dart';
import 'package:tmail_ui_user/features/quotas/data/datasource_impl/quotas_data_source_impl.dart';
import 'package:tmail_ui_user/features/quotas/data/network/quotas_api.dart';
import 'package:tmail_ui_user/features/quotas/data/repository/quotas_repository_impl.dart';
import 'package:tmail_ui_user/features/quotas/domain/repository/quotas_repository.dart';
import 'package:tmail_ui_user/features/quotas/domain/use_case/get_quotas_interactor.dart';
import 'package:tmail_ui_user/main/exceptions/remote_exception_thrower.dart';

class QuotasInteractorBindings extends InteractorsBindings {

  @override
  void bindingsDataSource() {
    Get.lazyPut<QuotasDataSource>(() => (Get.find<QuotasDataSourceImpl>()));
  }

  @override
  void bindingsDataSourceImpl() {
    Get.lazyPut(() => QuotasDataSourceImpl(Get.find<QuotasAPI>(), Get.find<RemoteExceptionThrower>()));
  }

  @override
  void bindingsInteractor() {
    Get.lazyPut(() => GetQuotasInteractor(Get.find<QuotasRepository>()));
  }

  @override
  void bindingsRepository() {
    Get.lazyPut<QuotasRepository>(() => Get.find<QuotasRepositoryImpl>());
  }

  @override
  void bindingsRepositoryImpl() {
    Get.lazyPut(() => QuotasRepositoryImpl(Get.find<QuotasDataSource>()));
  }
}