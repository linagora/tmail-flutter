
import 'package:core/core.dart';
import 'package:get/get.dart';

class LocalBindings extends Bindings {

  @override
  void dependencies() {
    _bindingDatabase();
  }

  void _bindingDatabase() {
    Get.put(DatabaseClient());
  }
}