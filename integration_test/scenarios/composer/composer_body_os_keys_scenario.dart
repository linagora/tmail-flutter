import 'package:flutter_test/flutter_test.dart';

import '../../base/base_test_scenario.dart';

class ComposerBodyOsKeysScenario extends BaseTestScenario {
  const ComposerBodyOsKeysScenario(super.$, super.robots);

  static const _subject = 'Keys';
  static const _bodyText = 'Hello';
  static const _bodyLetter = 'a';

  @override
  Future<void> runTestLogic() async {
    final composer = robots.composerRobot();
    final osKeyboard = composer.osKeyboard;
    if (osKeyboard == null) {
      throw StateError('OS keyboard injection is not wired on this platform');
    }

    await robots.threadRobot().openComposer();
    await composer.expectComposerViewVisible();
    await composer.grantContactPermission();

    await osKeyboard.focusSubject();
    await osKeyboard.typeText(_subject);
    await osKeyboard.waitForSubject(_subject);

    await osKeyboard.focusBody();
    await osKeyboard.typeText(_bodyText);
    await osKeyboard.pressKey('Space');
    await osKeyboard.pressKey(_bodyLetter);
    await osKeyboard.waitForBodyContaining(_bodyText);

    final htmlAfter = await osKeyboard.readBodyHtml();
    expect(await osKeyboard.readSubject(), contains(_subject));
    expect(htmlAfter, contains(_bodyText));
    expect(
      htmlAfter.contains('$_bodyText $_bodyLetter') ||
          htmlAfter.contains('$_bodyText&nbsp;$_bodyLetter') ||
          RegExp('$_bodyText(\\s|&nbsp;|&#160;)$_bodyLetter')
              .hasMatch(htmlAfter),
      isTrue,
    );
  }
}
