import 'package:get/get.dart';
import 'package:tmail_ui_user/features/base/interactors_bindings.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/data/network/linagora_ecosystem_api.dart';
import 'package:tmail_ui_user/features/paywall/data/datasource/paywall_datasource.dart';
import 'package:tmail_ui_user/features/paywall/data/datasource_impl/paywall_datasource_impl.dart';
import 'package:tmail_ui_user/features/paywall/data/repository/paywall_repository_impl.dart';
import 'package:tmail_ui_user/features/paywall/domain/repository/paywall_repository.dart';
import 'package:tmail_ui_user/features/paywall/domain/usecases/get_paywall_url_interactor.dart';
import 'package:tmail_ui_user/main/exceptions/remote_exception_thrower.dart';

class PaywallBindings extends InteractorsBindings {
  @override
  void bindingsDataSource() {
    Get.lazyPut<PaywallDatasource>(() => Get.find<PaywallDatasourceImpl>());
  }

  @override
  void bindingsDataSourceImpl() {
    Get.lazyPut(
      () => PaywallDatasourceImpl(
        Get.find<LinagoraEcosystemApi>(),
        Get.find<RemoteExceptionThrower>(),
      ),
    );
  }

  @override
  void bindingsInteractor() {
    Get.lazyPut(() => GetPaywallUrlInteractor(Get.find<PaywallRepository>()));
  }

  @override
  void bindingsRepository() {
    Get.lazyPut<PaywallRepository>(() => Get.find<PaywallRepositoryImpl>());
  }

  @override
  void bindingsRepositoryImpl() {
    Get.lazyPut(() => PaywallRepositoryImpl(Get.find<PaywallDatasource>()));
  }
}
