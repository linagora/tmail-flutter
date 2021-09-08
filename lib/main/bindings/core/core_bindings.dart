import 'package:core/core.dart';
import 'package:core/presentation/utils/app_toast.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CoreBindings extends Bindings {

  @override
  Future dependencies() async {
    await _bindingSharePreference();
    _bindingAppImagePaths();
    _bindingResponsiveManager();
    _bindingKeyboardManager();
    _bindingValidator();
    _bindingToast();
  }

  void _bindingAppImagePaths() {
    Get.put(ImagePaths());
  }

  void _bindingResponsiveManager() {
    Get.put(ResponsiveUtils());
  }

  Future _bindingSharePreference() async {
    await Get.putAsync(() async => await SharedPreferences.getInstance(), permanent: true);
  }

  void _bindingKeyboardManager() {
    Get.put(KeyboardUtils());
  }

  void _bindingValidator() {
    Get.put(HtmlMessagePurifier());
  }

  void _bindingToast() {
    Get.put(AppToast());
  }
}