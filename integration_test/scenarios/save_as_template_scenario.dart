import 'package:core/presentation/resources/image_paths.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

import '../base/base_test_scenario.dart';
import '../robots/composer_robot.dart';
import '../robots/mailbox_menu_robot.dart';
import '../robots/thread_robot.dart';

class SaveAsTemplateScenario extends BaseTestScenario {
  const SaveAsTemplateScenario(super.$);

  @override
  Future<void> runTestLogic() async {
    final imagePaths = ImagePaths();
    final appLocalizations = AppLocalizations();
    final mailboxMenuRobot = MailboxMenuRobot($);
    final threadRobot = ThreadRobot($);
    final composerRobot = ComposerRobot($);

    await threadRobot.openMailbox();
    await mailboxMenuRobot.openFolderByName(
      appLocalizations.templatesMailboxDisplayName,
    );
    
    await threadRobot.openComposer();
    await composerRobot.grantContactPermission();
    
    await composerRobot.addSubject('test subject');
    await composerRobot.saveAsTemplate();
    await $.pumpAndTrySettle();
    await composerRobot.tapCloseComposer(imagePaths);
    await composerRobot.tapDiscardChanges();
    await _expectTemplateVisible('test subject');

    await threadRobot.openEmailWithSubject('test subject');
    await composerRobot.addSubject('test subject updated');
    hideKeyboard();
    await $.pumpAndTrySettle(duration: const Duration(seconds: 1));
    await composerRobot.saveAsTemplate();
    await $.pumpAndTrySettle();
    await composerRobot.tapCloseComposer(imagePaths);
    await composerRobot.tapDiscardChanges();
    await _expectTemplateVisible('test subject updated');
  }
  
  Future<void> _expectTemplateVisible(String subject) async {
    await $(subject).waitUntilVisible();
    expect($(subject).visible, isTrue);
  }
} 