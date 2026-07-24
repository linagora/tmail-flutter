import 'package:core/utils/app_logger.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/search/email/presentation/search_email_bindings.dart';
import 'package:tmail_ui_user/features/search/email/presentation/search_email_controller.dart';
import 'package:tmail_ui_user/features/search/email/presentation/coordinator/search_email_layout_owner_registry.dart';

class GetSearchEmailLayoutOwnerRegistry
    implements SearchEmailLayoutOwnerRegistry {
  const GetSearchEmailLayoutOwnerRegistry();

  @override
  bool tryPrepareForSearchHandoff() {
    try {
      if (!Get.isRegistered<SearchEmailController>()) {
        SearchEmailBindings().dependencies();
      }
      if (!Get.isRegistered<SearchEmailController>()) {
        return false;
      }
      Get.find<SearchEmailController>().prepareForSearchHandoff();
      return true;
    } catch (error, stackTrace) {
      logWarning(
        'GetSearchEmailLayoutOwnerRegistry::tryPrepareForSearchHandoff: '
        '$error\n$stackTrace',
      );
      return false;
    }
  }
}
