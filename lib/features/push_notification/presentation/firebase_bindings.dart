import 'package:get/get.dart';
import 'package:tmail_ui_user/features/base/base_bindings.dart';
import 'package:tmail_ui_user/features/push_notification/data/datasource/firebase_datasource.dart';
import 'package:tmail_ui_user/features/push_notification/data/datasource_impl/hive_account_datasource_impl.dart';
import 'package:tmail_ui_user/features/push_notification/data/local/firebase_cache_manager.dart';
import 'package:tmail_ui_user/features/push_notification/data/repository/firebase_repository_impl.dart';
import 'package:tmail_ui_user/features/push_notification/domain/repository/firebase_repository.dart';
import 'package:tmail_ui_user/features/push_notification/domain/usecases/delete_firebase_cache_interactor.dart';
import 'package:tmail_ui_user/features/push_notification/domain/usecases/get_firebase_cache_interactor.dart';
import 'package:tmail_ui_user/features/push_notification/domain/usecases/save_firebase_cache_interactor.dart';
import 'package:tmail_ui_user/main/exceptions/cache_exception_thrower.dart';

class FireBaseBindings extends BaseBindings {
  @override
  void bindingsController() {}

  @override
  void bindingsDataSource() {
    Get.put<FirebaseDatasource>(Get.find<HiveFirebaseDatasourceImpl>());
  }

  @override
  void bindingsDataSourceImpl() {
    Get.put(HiveFirebaseDatasourceImpl(
      Get.find<FirebaseCacheManager>(),
      Get.find<CacheExceptionThrower>(),
    ));
  }

  @override
  void bindingsInteractor() {
    Get.put(DeleteFirebaseCacheInteractor(Get.find<FirebaseRepositoryImpl>()));
    Get.put(SaveFirebaseCacheInteractor(Get.find<FirebaseRepositoryImpl>()));
    Get.put(GetFirebaseCacheInteractor(Get.find<FirebaseRepositoryImpl>()));
  }

  @override
  void bindingsRepository() {
    Get.put<FirebaseRepository>(Get.find<FirebaseRepositoryImpl>());
  }

  @override
  void bindingsRepositoryImpl() {
    Get.put(FirebaseRepositoryImpl(Get.find<FirebaseDatasource>()));
  }
}
