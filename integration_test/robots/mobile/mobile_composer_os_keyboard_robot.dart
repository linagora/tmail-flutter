import 'package:flutter_test/flutter_test.dart';
import 'package:rich_text_composer/rich_text_composer.dart';
import 'package:tmail_ui_user/features/composer/presentation/composer_controller.dart';
import 'package:tmail_ui_user/features/composer/presentation/composer_view.dart';
import 'package:tmail_ui_user/features/composer/presentation/view/mobile/mobile_editor_view.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/subject_composer_widget.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

import '../../base/core_robot.dart';
import '../../utils/wait_for_condition.dart';
import '../abstract/abstract_composer_os_keyboard_robot.dart';
import '../abstract/composer_os_key_injector.dart';

class MobileComposerOsKeyboardRobot extends CoreRobot
    implements AbstractComposerOsKeyboardRobot {
  MobileComposerOsKeyboardRobot(super.$, {required this.injector});

  final ComposerOsKeyInjector injector;

  @override
  Future<void> focusSubject() async {
    await $(SubjectComposerWidget).tap();
    await $.pumpAndTrySettle();
  }

  @override
  Future<void> focusBody() async {
    await $(ComposerView)
        .$(MobileEditorView)
        .$(HtmlEditor)
        .$(InAppWebView)
        .tap();
    await $.pumpAndTrySettle();
    await $.pump(const Duration(milliseconds: 400));
  }

  @override
  Future<void> typeText(String text) => injector.typeText(text);

  @override
  Future<void> pressKey(String key) => injector.pressKey(key);

  @override
  Future<String> readSubject() async {
    return _controller()?.subjectEmailInputController.text ?? '';
  }

  @override
  Future<String> readBodyHtml() async {
    return await _controller()?.htmlEditorApi?.getText() ?? '';
  }

  @override
  Future<void> waitForSubject(String expected) => waitForCondition(
        () async => (await readSubject()).contains(expected),
      );

  @override
  Future<void> waitForBodyContaining(String expected) => waitForCondition(
        () async => (await readBodyHtml()).contains(expected),
      );

  ComposerController? _controller() => getBinding<ComposerController>();
}
