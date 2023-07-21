import 'package:get/get.dart';
import 'package:tmail_ui_user/features/base/interactors_bindings.dart';
import 'package:tmail_ui_user/features/email/data/datasource/calendar_event_datasource.dart';
import 'package:tmail_ui_user/features/email/data/datasource_impl/calendar_event_datasource_impl.dart';
import 'package:tmail_ui_user/features/email/data/network/calendar_event_api.dart';
import 'package:tmail_ui_user/features/email/data/repository/calendar_event_repository_impl.dart';
import 'package:tmail_ui_user/features/email/domain/repository/calendar_event_repository.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/parse_calendar_event_interactor.dart';
import 'package:tmail_ui_user/main/exceptions/remote_exception_thrower.dart';

class CalendarEventInteractorBindings extends InteractorsBindings {

  @override
  void bindingsDataSource() {
    Get.lazyPut<CalendarEventDataSource>(() => Get.find<CalendarEventDataSourceImpl>());
  }

  @override
  void bindingsDataSourceImpl() {
    Get.lazyPut(() => CalendarEventDataSourceImpl(
      Get.find<CalendarEventAPI>(),
      Get.find<RemoteExceptionThrower>()));
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
    Get.lazyPut(() => CalendarEventRepositoryImpl(Get.find<CalendarEventDataSource>()));
  }
}