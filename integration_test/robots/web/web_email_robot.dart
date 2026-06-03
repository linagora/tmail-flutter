import 'package:flutter_test/flutter_test.dart';

import '../mobile/mobile_email_robot.dart';
import '../../utils/wait_for_condition.dart';

class WebEmailRobot extends MobileEmailRobot {
  WebEmailRobot(super.$);

  @override
  Future<void> expectDownloadSaveDialogVisible() async {
    await waitForCondition(() async {
      final downloads = await $.platformAutomator.web.verifyFileDownloads();
      return downloads.any((name) => name.startsWith('TwakeMail-'));
    });
  }
}