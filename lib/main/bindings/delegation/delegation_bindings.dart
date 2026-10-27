import 'package:get/get.dart';
import 'package:tmail_ui_user/features/delegation/presentation/bridge/active_account_source.dart';
import 'package:tmail_ui_user/features/delegation/presentation/bridge/riverpod_active_account_source.dart';
import 'package:tmail_ui_user/main/providers/app_provider_container.dart';

class DelegationBindings extends Bindings {
  @override
  void dependencies() {
    // Lives as long as activeAccountProvider, so a reader never outlives it. The only GetX
    // access to the shown account (ADR-0092).
    final source = RiverpodActiveAccountSource(appProviderContainer);
    Get.put<ActiveAccountSource>(source, permanent: true);
    Get.put<ActiveAccountWriter>(source, permanent: true);
  }
}
