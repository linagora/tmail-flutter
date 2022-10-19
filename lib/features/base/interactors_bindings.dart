
import 'package:get/get_instance/src/bindings_interface.dart';

abstract class InteractorsBindings extends Bindings {

  @override
  void dependencies() {
    bindingsDataSourceImpl();
    bindingsDataSource();
    bindingsRepositoryImpl();
    bindingsRepository();
    bindingsInteractor();
  }

  void bindingsDataSourceImpl();

  void bindingsDataSource();

  void bindingsRepositoryImpl();

  void bindingsRepository();

  void bindingsInteractor();
}