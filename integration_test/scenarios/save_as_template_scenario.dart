import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

import '../base/base_test_scenario.dart';
import '../robots/composer_robot.dart';
import '../robots/thread_robot.dart';

class SaveAsTemplateScenario extends BaseTestScenario {
  const SaveAsTemplateScenario(super.$);

  @override
  Future<void> runTestLogic() async {
    final threadRobot = ThreadRobot($);
    final composerRobot = ComposerRobot($);
    
    await threadRobot.openComposer();
    await composerRobot.grantContactPermission();
    
    await composerRobot.saveAsTemplate();
    
    await _expectSaveToastSuccessVisible();

    await composerRobot.addSubject('test subject');
    
    await composerRobot.saveAsTemplate();

    await _expectUpdateToastSuccessVisible();
  }
  
  Future<void> _expectSaveToastSuccessVisible() async {
    await $(AppLocalizations().saveMessageToTemplateSuccess).waitUntilVisible();
    expect(
      $(AppLocalizations().saveMessageToTemplateSuccess).visible, 
      isTrue,
    );
  }
  
  Future<void> _expectUpdateToastSuccessVisible() async {
    await $(AppLocalizations().updateMessageToTemplateSuccess).waitUntilVisible();
    expect(
      $(AppLocalizations().updateMessageToTemplateSuccess).visible, 
      isTrue,
    );
  }
} 