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
import 'package:tmail_ui_user/features/labels/domain/usecases/delete_a_label_interactor.dart';
import 'package:tmail_ui_user/features/labels/domain/usecases/get_all_label_interactor.dart';
import 'package:tmail_ui_user/features/labels/domain/usecases/get_label_changes_interactor.dart';
import 'package:tmail_ui_user/main/exceptions/thrower/remote_exception_thrower.dart';
import 'package:uuid/uuid.dart';

class LabelInteractorBindings extends InteractorsBindings {
  @override
  void bindingsDataSource() {
    Get.lazyPut<LabelDatasource>(() => Get.find<LabelDatasourceImpl>(), fenix: true);
  }

  @override
  void bindingsDataSourceImpl() {
    Get.lazyPut(() => LabelApi(Get.find<HttpClient>(), Get.find<Uuid>()), fenix: true);
    Get.lazyPut(
      () => LabelDatasourceImpl(
        Get.find<LabelApi>(),
        Get.find<RemoteExceptionThrower>(),
      ),
      fenix: true,
    );
  }

  @override
  void bindingsInteractor() {
    Get.lazyPut(() => GetAllLabelInteractor(Get.find<LabelRepository>()));
    // Use `fenix: true` to avoid GetX dispose or SmartManagement cleanup when using it in dialogs.
    Get.lazyPut(() => CreateNewLabelInteractor(Get.find<LabelRepository>()), fenix: true);
    Get.lazyPut(() => EditLabelInteractor(Get.find<LabelRepository>()), fenix: true);
    Get.lazyPut(() => DeleteALabelInteractor(Get.find<LabelRepository>()));
    Get.lazyPut(() => GetLabelChangesInteractor(Get.find<LabelRepository>()));
  }

  @override
  void bindingsRepository() {
    // fenix: the fenix dialog interactors rebuild from this chain after a route disposes it.
    Get.lazyPut<LabelRepository>(() => Get.find<LabelRepositoryImpl>(), fenix: true);
  }

  @override
  void bindingsRepositoryImpl() {
    Get.lazyPut(() => LabelRepositoryImpl(Get.find<LabelDatasource>()), fenix: true);
  }
}
