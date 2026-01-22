import 'package:get/get.dart';
import 'package:tmail_ui_user/features/base/interactors_bindings.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/data/datasource/linagora_ecosystem_datasource.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/data/datasource_impl/linagora_ecosystem_datasource_impl.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/data/network/linagora_ecosystem_api.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/data/repository/linagora_ecosystem_repository_impl.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/repository/linagora_ecosystem_repository.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/usecases/get_linagora_ecosystem_interactor.dart';
import 'package:tmail_ui_user/main/exceptions/remote_exception_thrower.dart';

class LinagoraEcosystemInteractorBindings extends InteractorsBindings {
  @override
  void bindingsDataSource() {
    Get.lazyPut<LinagoraEcosystemDatasource>(
      () => Get.find<LinagoraEcosystemDatasourceImpl>(),
    );
  }

  @override
  void bindingsDataSourceImpl() {
    Get.lazyPut(
      () => LinagoraEcosystemDatasourceImpl(
        Get.find<LinagoraEcosystemApi>(),
        Get.find<RemoteExceptionThrower>(),
      ),
    );
  }

  @override
  void bindingsInteractor() {
    Get.lazyPut(
      () => GetLinagoraEcosystemInteractor(
        Get.find<LinagoraEcosystemRepository>(),
      ),
    );
  }

  @override
  void bindingsRepository() {
    Get.lazyPut<LinagoraEcosystemRepository>(
      () => Get.find<LinagoraEcosystemRepositoryImpl>(),
    );
  }

  @override
  void bindingsRepositoryImpl() {
    Get.lazyPut(
      () => LinagoraEcosystemRepositoryImpl(
        Get.find<LinagoraEcosystemDatasource>(),
      ),
    );
  }
}
