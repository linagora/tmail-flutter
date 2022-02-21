
import 'package:get/get_instance/src/bindings_interface.dart';

abstract class BaseBindings extends Bindings {

  @override
  void dependencies() {
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