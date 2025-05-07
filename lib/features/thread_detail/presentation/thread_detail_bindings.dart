import 'package:core/data/model/source_type/data_source_type.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/http/http_client.dart';
import 'package:tmail_ui_user/features/base/base_bindings.dart';
import 'package:tmail_ui_user/features/thread_detail/data/data_source/thread_detail_remote_data_source_impl.dart';
import 'package:tmail_ui_user/features/thread_detail/data/network/thread_detail_api.dart';
import 'package:tmail_ui_user/features/thread_detail/data/repository/thread_detail_repository_impl.dart';
import 'package:tmail_ui_user/features/thread_detail/domain/repository/thread_detail_repository.dart';
import 'package:tmail_ui_user/features/thread_detail/domain/usecases/get_emails_by_ids_interactor.dart';
import 'package:tmail_ui_user/features/thread_detail/domain/usecases/get_thread_by_id_interactor.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/model/thread_detail_arguments.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/thread_detail_controller.dart';
import 'package:tmail_ui_user/main/exceptions/remote_exception_thrower.dart';

class ThreadDetailBindings extends BaseBindings {
  final ThreadDetailArguments threadDetailArguments;

  ThreadDetailBindings({required this.threadDetailArguments});

  @override
  void dependencies() {
    Get.lazyPut(() => ThreadDetailApi(Get.find<HttpClient>()));

    super.dependencies();
  }

  @override
  void bindingsController() {
    Get.put(ThreadDetailController(
      threadDetailArguments,
      Get.find<GetThreadByIdInteractor>(),
      Get.find<GetEmailsByIdsInteractor>(),
    ));
  }

  @override
  void bindingsDataSourceImpl() {
    Get.lazyPut(() => ThreadDetailRemoteDataSourceImpl(
      Get.find<ThreadDetailApi>(),
      Get.find<RemoteExceptionThrower>(),
    ));
  }

  @override
  void bindingsDataSource() {}

  @override
  void bindingsRepositoryImpl() {
    Get.lazyPut(() => ThreadDetailRepositoryImpl({
      DataSourceType.network: Get.find<ThreadDetailRemoteDataSourceImpl>(),
    }));
  }

  @override
  void bindingsRepository() {
    Get.lazyPut<ThreadDetailRepository>(() => Get.find<ThreadDetailRepositoryImpl>());
  }

  @override
  void bindingsInteractor() {
    Get.lazyPut(() => GetThreadByIdInteractor(Get.find<ThreadDetailRepository>()));
    Get.lazyPut(() => GetEmailsByIdsInteractor(Get.find<ThreadDetailRepository>()));
  }
}
