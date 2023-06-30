
import 'package:core/utils/app_logger.dart';
import 'package:get/get_instance/src/bindings_interface.dart';

abstract class BaseBindings extends Bindings {

  @override
  void dependencies() {
    log('BaseBindings::dependencies():');
    bindingsDataSourceImpl();
    bindingsDataSource();
    bindingsRepositoryImpl();
    bindingsRepository();
    bindingsInteractor();
    bindingsController();
  }

  void bindingsDataSourceImpl();

  void bindingsDataSource();

  void bindingsRepositoryImpl();

  void bindingsRepository();

  void bindingsInteractor();

  void bindingsController();
}