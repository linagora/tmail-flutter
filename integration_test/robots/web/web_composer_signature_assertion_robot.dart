import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

import '../../base/core_robot.dart';
import '../../utils/test_timeouts.dart';
import '../../utils/wait_for_condition.dart';
import 'web_composer_editor_dom.dart';
import 'web_composer_controller_finder.dart';

/// Web-only checks for the identity signature inside the Summernote iframe.
class WebComposerSignatureAssertionRobot extends CoreRobot {
  WebComposerSignatureAssertionRobot(PatrolIntegrationTester $) : super($);

  /// Polls the live iframe DOM until a signature with [marker] is present and
  /// not `display: none`. Cached HTML alone is not enough: a hidden signature
  /// still contains the marker text.
  Future<void> expectSignatureVisible(String marker) async {
    await waitForCondition(
      () => _isVisibleSignatureWithMarker(marker),
      timeout: TestTimeouts.long,
      reason: 'visible signature containing $marker',
    );

    final signature = findSignatureElement(marker: marker);
    expect(
      signature,
      isNotNull,
      reason:
          'signature missing in iframe. cached=${_cachedHasMarker(marker)}',
    );
    expect(signature!.textContent, contains(marker));
    expect(
      signatureStyleIsHidden(signature),
      isFalse,
      reason: 'reopened draft must not hide the identity signature',
    );
  }

  bool _isVisibleSignatureWithMarker(String marker) {
    final signature = findSignatureElement(marker: marker);
    if (signature == null) return false;
    return !signatureStyleIsHidden(signature);
  }

  bool _cachedHasMarker(String marker) =>
      findWebComposerController($)?.textEditorWeb?.contains(marker) == true;
}
