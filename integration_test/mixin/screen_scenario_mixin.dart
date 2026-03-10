import 'package:core/presentation/resources/image_paths.dart';
import 'package:flutter_test/flutter_test.dart';

import '../robots/composer_robot.dart';
import '../robots/email_robot.dart';

mixin ScreenScenarioMixin {
  Future<void> closeEmailDetailedView({required EmailRobot emailRobot}) async {
    await emailRobot.onTapBackButton();
  }

  Future<void> closeComposer({
    required ComposerRobot composerRobot,
    required ImagePaths imagePaths,
  }) async {
    await composerRobot.tapCloseComposer(imagePaths);
    await composerRobot.tapDiscardChanges();
  }
}
