import 'package:get/get.dart';
import 'package:tmail_ui_user/features/delegation/presentation/bridge/active_account_bridge.dart';
import 'package:tmail_ui_user/main/providers/app_provider_container.dart';

class DelegationBindings extends Bindings {
  @override
  void dependencies() {
    // Lives as long as activeAccountProvider, so a reader never outlives it. The only GetX
    // access to the shown account (ADR-0092).
    Get.put(ActiveAccountBridge(appProviderContainer), permanent: true);
  }
}
