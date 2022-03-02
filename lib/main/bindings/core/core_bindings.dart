import 'package:core/core.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tmail_ui_user/features/email/data/local/html_analyzer.dart';
import 'package:tmail_ui_user/main.dart';
import 'package:tmail_ui_user/main/notification/firebase_push_notification.dart';

class CoreBindings extends Bindings {

  @override
  Future dependencies() async {
    await _bindingSharePreference();
    _bindingAppImagePaths();
    _bindingResponsiveManager();
    _bindingKeyboardManager();
    _bindingTransformer();
    _bindingToast();
    _bindingDeviceManager();
    _bindingNotification();
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

  void _bindingTransformer() {
    Get.put(HtmlAnalyzer());
  }

  void _bindingToast() {
    Get.put(FToast());
    Get.put(AppToast());
  }

  void _bindingDeviceManager() {
    Get.put(DeviceInfoPlugin());
    Get.put(DeviceManager(Get.find<DeviceInfoPlugin>()));
  }

  void _bindingNotification() {
    Get.put(FirebasePushNotification(firebaseMessaging));
  }
}