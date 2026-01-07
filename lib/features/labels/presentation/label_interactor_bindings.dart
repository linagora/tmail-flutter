import 'package:get/get.dart';
import 'package:jmap_dart_client/http/http_client.dart';
import 'package:tmail_ui_user/features/base/interactors_bindings.dart';
import 'package:tmail_ui_user/features/labels/data/datasource/label_datasource.dart';
import 'package:tmail_ui_user/features/labels/data/datasource_impl/label_datasource_impl.dart';
import 'package:tmail_ui_user/features/labels/data/network/label_api.dart';
import 'package:tmail_ui_user/features/labels/data/repository/label_repository_impl.dart';
import 'package:tmail_ui_user/features/labels/domain/repository/label_repository.dart';
import 'package:tmail_ui_user/features/labels/domain/usecases/create_new_label_interactor.dart';
import 'package:tmail_ui_user/features/labels/domain/usecases/edit_label_interactor.dart';
import 'package:tmail_ui_user/features/labels/domain/usecases/get_all_label_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_creator/domain/usecases/verify_name_interactor.dart';
import 'package:tmail_ui_user/main/exceptions/remote_exception_thrower.dart';
import 'package:uuid/uuid.dart';

class LabelInteractorBindings extends InteractorsBindings {
  @override
  void bindingsDataSource() {
    Get.lazyPut<LabelDatasource>(() => Get.find<LabelDatasourceImpl>());
  }

  @override
  void bindingsDataSourceImpl() {
    Get.lazyPut(() => LabelApi(Get.find<HttpClient>(), Get.find<Uuid>()));
    Get.lazyPut(
      () => LabelDatasourceImpl(
        Get.find<LabelApi>(),
        Get.find<RemoteExceptionThrower>(),
      ),
    );
  }

  @override
  void bindingsInteractor() {
    Get.lazyPut(() => GetAllLabelInteractor(Get.find<LabelRepository>()));
    Get.lazyPut(() => CreateNewLabelInteractor(Get.find<LabelRepository>()));
    Get.lazyPut(() => EditLabelInteractor(Get.find<LabelRepository>()));
    Get.lazyPut(() => VerifyNameInteractor());
  }

  @override
  void bindingsRepository() {
    Get.lazyPut<LabelRepository>(() => Get.find<LabelRepositoryImpl>());
  }

  @override
  void bindingsRepositoryImpl() {
    Get.lazyPut(() => LabelRepositoryImpl(Get.find<LabelDatasource>()));
  }
}
