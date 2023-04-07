import 'package:core/data/utils/compress_file_utils.dart';
import 'package:core/data/utils/device_manager.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/app_toast.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/utils/config/app_config_loader.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tmail_ui_user/features/email/data/local/html_analyzer.dart';
import 'package:tmail_ui_user/main/utils/email_receive_manager.dart';
import 'package:uuid/uuid.dart';

class CoreBindings extends Bindings {

  @override
  Future dependencies() async {
    await _bindingSharePreference();
    _bindingAppImagePaths();
    _bindingResponsiveManager();
    _bindingTransformer();
    _bindingToast();
    _bindingDeviceManager();
    _bindingReceivingSharingStream();
    _bindingUtils();
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

  void _bindingTransformer() {
    Get.put(HtmlAnalyzer());
  }

  void _bindingToast() {
    Get.put(AppToast());
  }

  void _bindingDeviceManager() {
    Get.put(DeviceInfoPlugin());
    Get.put(DeviceManager(Get.find<DeviceInfoPlugin>()));
  }

  void _bindingReceivingSharingStream() {
    Get.put(EmailReceiveManager());
  }

  void _bindingUtils() {
    Get.put(const Uuid());
    Get.put(CompressFileUtils());
    Get.put(AppConfigLoader());
  }
}