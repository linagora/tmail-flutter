import 'package:core/data/model/source_type/data_source_type.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/http/http_client.dart';
import 'package:tmail_ui_user/features/base/interactors_bindings.dart';
import 'package:tmail_ui_user/features/email/data/datasource/calendar_event_datasource.dart';
import 'package:tmail_ui_user/features/email/data/datasource_impl/calendar_event_datasource_impl.dart';
import 'package:tmail_ui_user/features/email/data/datasource_impl/local_calendar_event_datasource_impl.dart';
import 'package:tmail_ui_user/features/email/data/local/html_analyzer.dart';
import 'package:tmail_ui_user/features/email/data/network/calendar_event_api.dart';
import 'package:tmail_ui_user/features/email/data/repository/calendar_event_repository_impl.dart';
import 'package:tmail_ui_user/features/email/domain/repository/calendar_event_repository.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/parse_calendar_event_interactor.dart';
import 'package:tmail_ui_user/main/exceptions/cache_exception_thrower.dart';
import 'package:tmail_ui_user/main/exceptions/remote_exception_thrower.dart';

class CalendarEventInteractorBindings extends InteractorsBindings {

  @override
  void bindingsDataSource() {
    Get.lazyPut<CalendarEventDataSource>(() => Get.find<CalendarEventDataSourceImpl>());
  }

  @override
  void bindingsDataSourceImpl() {
    Get.lazyPut(() => CalendarEventAPI(Get.find<HttpClient>()));
    Get.lazyPut(() => CalendarEventDataSourceImpl(
      Get.find<CalendarEventAPI>(),
      Get.find<RemoteExceptionThrower>()));
    Get.lazyPut(() => LocalCalendarEventDataSourceImpl(
      Get.find<HtmlAnalyzer>(),
      Get.find<CacheExceptionThrower>()));
  }

  @override
  void bindingsInteractor() {
    Get.lazyPut(() => ParseCalendarEventInteractor(Get.find<CalendarEventRepository>()));
  }

  @override
  void bindingsRepository() {
    Get.lazyPut<CalendarEventRepository>(() => Get.find<CalendarEventRepositoryImpl>());
  }

  @override
  void bindingsRepositoryImpl() {
    Get.lazyPut(() => CalendarEventRepositoryImpl(
      {
        DataSourceType.network: Get.find<CalendarEventDataSource>(),
        DataSourceType.local: Get.find<LocalCalendarEventDataSourceImpl>(),
      }
    ));
  }
}