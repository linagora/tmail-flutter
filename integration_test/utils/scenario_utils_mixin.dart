import 'package:patrol/patrol.dart';

mixin ScenarioUtilsMixin {
  Future<void> grantNotificationPermission(NativeAutomator nativeAutomator) async {
    if (await nativeAutomator.isPermissionDialogVisible(timeout: const Duration(seconds: 5))) {
      await nativeAutomator.grantPermissionWhenInUse();
    }
  }
}