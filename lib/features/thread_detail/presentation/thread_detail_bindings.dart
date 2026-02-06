import 'package:core/data/model/source_type/data_source_type.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/http/http_client.dart';
import 'package:tmail_ui_user/features/base/base_bindings.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/add_a_label_to_a_thread_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/get_email_content_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/labels/remove_a_label_from_a_thread_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/mark_as_email_read_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/mark_as_star_email_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/print_email_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/data/local/preferences_setting_manager.dart';
import 'package:tmail_ui_user/features/thread/domain/usecases/mark_as_multiple_email_read_interactor.dart';
import 'package:tmail_ui_user/features/thread/domain/usecases/mark_as_star_multiple_email_interactor.dart';
import 'package:tmail_ui_user/features/thread_detail/data/data_source/thread_detail_data_source.dart';
import 'package:tmail_ui_user/features/thread_detail/data/data_source/thread_detail_local_data_source_impl.dart';
import 'package:tmail_ui_user/features/thread_detail/data/data_source/thread_detail_remote_data_source_impl.dart';
import 'package:tmail_ui_user/features/thread_detail/data/network/thread_detail_api.dart';
import 'package:tmail_ui_user/features/thread_detail/data/repository/thread_detail_repository_impl.dart';
import 'package:tmail_ui_user/features/thread_detail/domain/repository/thread_detail_repository.dart';
import 'package:tmail_ui_user/features/thread_detail/domain/usecases/get_emails_by_ids_interactor.dart';
import 'package:tmail_ui_user/features/thread_detail/domain/usecases/get_thread_by_id_interactor.dart';
import 'package:tmail_ui_user/features/thread_detail/domain/usecases/get_thread_detail_status_interactor.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/thread_detail_controller.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/thread_detail_manager.dart';
import 'package:tmail_ui_user/main/exceptions/cache_exception_thrower.dart';
import 'package:tmail_ui_user/main/exceptions/remote_exception_thrower.dart';

class ThreadDetailBindings extends BaseBindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ThreadDetailApi(Get.find<HttpClient>()));

    super.dependencies();
  }

  @override
  void bindingsController() {
    Get.put(ThreadDetailManager(
      Get.find<GetThreadDetailStatusInteractor>(),
    ));
    Get.put(ThreadDetailController(
      Get.find<GetThreadByIdInteractor>(),
      Get.find<GetEmailsByIdsInteractor>(),
      Get.find<MarkAsEmailReadInteractor>(),
      Get.find<MarkAsStarEmailInteractor>(),
      Get.find<PrintEmailInteractor>(),
      Get.find<GetEmailContentInteractor>(),
      Get.find<MarkAsStarMultipleEmailInteractor>(),
      Get.find<MarkAsMultipleEmailReadInteractor>(),
      Get.find<AddALabelToAThreadInteractor>(),
      Get.find<RemoveALabelFromAThreadInteractor>(),
    ));
  }

  @override
  void bindingsDataSourceImpl() {
    Get.lazyPut(() => ThreadDetailRemoteDataSourceImpl(
      Get.find<ThreadDetailApi>(),
      Get.find<RemoteExceptionThrower>(),
    ));
    Get.lazyPut(() => ThreadDetailLocalDataSourceImpl(
      Get.find<PreferencesSettingManager>(),
      Get.find<CacheExceptionThrower>(),
    ));
  }

  @override
  void bindingsDataSource() {
    Get.lazyPut<ThreadDetailDataSource>(() => Get.find<ThreadDetailRemoteDataSourceImpl>());
  }

  @override
  void bindingsRepositoryImpl() {
    Get.lazyPut(() => ThreadDetailRepositoryImpl({
      DataSourceType.network: Get.find<ThreadDetailDataSource>(),
      DataSourceType.local: Get.find<ThreadDetailLocalDataSourceImpl>(),
    }));
  }

  @override
  void bindingsRepository() {
    Get.lazyPut<ThreadDetailRepository>(() => Get.find<ThreadDetailRepositoryImpl>());
  }

  @override
  void bindingsInteractor() {
    Get.lazyPut(() => GetThreadDetailStatusInteractor(Get.find<ThreadDetailRepository>()));
    Get.lazyPut(() => GetThreadByIdInteractor(Get.find<ThreadDetailRepository>()));
    Get.lazyPut(() => GetEmailsByIdsInteractor(Get.find<ThreadDetailRepository>()));
  }
}
