import 'package:core/presentation/resources/image_paths.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/widgets/thread_detail_collapsed_email.dart';

import '../../base/base_test_scenario.dart';
import '../../robots/composer_robot.dart';
import '../../robots/email_robot.dart';
import '../../robots/mailbox_menu_robot.dart';
import '../../robots/search_robot.dart';
import '../../robots/setting_robot.dart';
import '../../robots/thread_robot.dart';

class ThreadDetailReplyRealTimeUpdateScenario extends BaseTestScenario {
  ThreadDetailReplyRealTimeUpdateScenario(super.$);
  
  @override
  Future<void> runTestLogic() async {
    const subject = 'Reply thread';
    const replyContent = 'reply thread detail';

    final threadRobot = ThreadRobot($);
    final mailboxMenuRobot = MailboxMenuRobot($);
    final settingRobot = SettingRobot($);
    final searchRobot = SearchRobot($);
    final emailRobot = EmailRobot($);
    final composerRobot = ComposerRobot($);
    final imagePaths = ImagePaths();

    await threadRobot.openMailbox();
    await mailboxMenuRobot.openSetting();
    await settingRobot.openPreferencesMenuItem();
    await settingRobot.switchOnThreadSetting();
    await settingRobot.backToSettingsFromFirstLevel();
    await settingRobot.closeSettings();

    await threadRobot.openSearchView();
    await searchRobot.enterQueryString(subject);
    await searchRobot.tapOnShowAllResultsText();
    await searchRobot.openEmailWithSubject(subject);

    await emailRobot.onTapReplyEmail();
    await composerRobot.grantContactPermission();
    await composerRobot.addContent(replyContent);
    await composerRobot.sendEmail(imagePaths);

    await _expectNewCollapsedEmail(replyContent);
  }

  Future<void> _expectNewCollapsedEmail(String replyContent) async {
    final collapsedEmail = $(ThreadDetailCollapsedEmail)
        .which<ThreadDetailCollapsedEmail>((widget) {
      return widget.preview.contains(replyContent);
    });
    await expectViewVisible(collapsedEmail);
  }
}