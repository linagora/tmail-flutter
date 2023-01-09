import 'package:get/get_rx/get_rx.dart';
import 'package:tmail_ui_user/features/base/base_controller.dart';

class SpamReportController extends BaseController {

  final dismissedSpamReported = RxBool(false);

  @override
  void onDone() {}

  void dismissSpamReportAction() {
    dismissedSpamReported.value = true;
  }
}
