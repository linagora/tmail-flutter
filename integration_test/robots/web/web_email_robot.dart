import 'package:flutter_test/flutter_test.dart';

import '../mobile/mobile_email_robot.dart';

class WebEmailRobot extends MobileEmailRobot {
  WebEmailRobot(super.$);

  @override
  Future<void> expectDownloadSaveDialogVisible() async {
    final downloads = await $.platformAutomator.web.verifyFileDownloads();
    expect(downloads.any((name) => name.startsWith('TwakeMail-')), isTrue);
  }
}