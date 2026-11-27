import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/app_toast.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/network_connection/presentation/web_network_connection_controller.dart' as web;

void main() {
  group('web NetworkConnectionController.onInternetRestored', () {
    late web.NetworkConnectionController controller;
    late int restoredCount;

    setUp(() {
      Get.put(ImagePaths());
      Get.put(AppToast());
      controller = web.NetworkConnectionController(Connectivity());
      restoredCount = 0;
      controller.onInternetRestored.listen((_) => restoredCount++);
    });

    tearDown(Get.deleteAll);

    test('Should emit WHEN the browser goes from offline to online', () async {
      controller.setNetworkConnectivityState(ConnectivityResult.none);
      controller.setNetworkConnectivityState(ConnectivityResult.wifi);
      await pumpEventQueue();

      expect(restoredCount, 1);
    });

    test('Should not emit WHEN the browser is offline', () async {
      controller.setNetworkConnectivityState(ConnectivityResult.none);
      await pumpEventQueue();

      expect(restoredCount, 0);
    });
  });
}
