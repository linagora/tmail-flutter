import 'package:core/data/utils/compress_file_utils.dart';
import 'package:core/data/utils/device_manager.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/app_toast.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/utils/application_manager.dart';
import 'package:core/utils/config/app_config_loader.dart';
import 'package:core/utils/file_utils.dart';
import 'package:core/utils/platform_info.dart';
import 'package:core/utils/preview_eml_file_utils.dart';
import 'package:core/utils/print_utils.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tmail_ui_user/features/base/before_reconnect_manager.dart';
import 'package:tmail_ui_user/features/caching/utils/local_storage_manager.dart';
import 'package:tmail_ui_user/features/caching/utils/session_storage_manager.dart';
import 'package:tmail_ui_user/features/sending_queue/presentation/utils/sending_queue_isolate_manager.dart';
import 'package:tmail_ui_user/main/utils/app_config.dart';
import 'package:tmail_ui_user/main/utils/email_receive_manager.dart';
import 'package:tmail_ui_user/main/utils/ios_notification_manager.dart';
import 'package:tmail_ui_user/main/utils/toast_manager.dart';
import 'package:tmail_ui_user/main/utils/twake_app_manager.dart';
import 'package:uuid/uuid.dart';

class CoreBindings extends Bindings {

  @override
  Future dependencies() async {
    await _bindingSharePreference();
    _bindingAppImagePaths();
    _bindingResponsiveManager();
    _bindingToast();
    _bindingDeviceManager();
    _bindingReceivingSharingStream();
    _bindingUtils();
    _bindingIsolate();
    _bindingStorage();
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

  void _bindingToast() {
    Get.put(AppToast());
    Get.put(ToastManager(Get.find<AppToast>()));
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
    Get.put(FileUtils());
    Get.put(PrintUtils());
    Get.put(ApplicationManager(Get.find<DeviceInfoPlugin>()));
    Get.put(BeforeReconnectManager());
    if (PlatformInfo.isIOS) {
      Get.put(IOSNotificationManager());
    }
    Get.put(PreviewEmlFileUtils());
    Get.put(TwakeAppManager());
  }

  void _bindingIsolate() {
    if (PlatformInfo.isMobile) {
      Get.put(SendingQueueIsolateManager());
    }
  }

  void _bindingStorage() {
    Get.put(const FlutterSecureStorage(
      iOptions: IOSOptions(
        groupId: AppConfig.iOSKeychainSharingGroupId,
        accountName: AppConfig.iOSKeychainSharingService,
        accessibility: KeychainAccessibility.first_unlock_this_device
      )
    ));
    Get.put(LocalStorageManager());
    Get.put(SessionStorageManager());
  }
}