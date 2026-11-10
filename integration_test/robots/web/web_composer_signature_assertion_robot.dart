import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

import '../../base/core_robot.dart';
import '../../utils/test_timeouts.dart';
import '../../utils/wait_for_condition.dart';
import '../abstract/abstract_composer_signature_robot.dart';
import 'web_composer_editor_dom.dart';
import 'web_composer_controller_finder.dart';

/// Web-only checks for the identity signature inside the Summernote iframe.
class WebComposerSignatureAssertionRobot extends CoreRobot
    implements AbstractComposerSignatureRobot {
  WebComposerSignatureAssertionRobot(PatrolIntegrationTester $) : super($);

  /// Requires the identity marker text so a quoted/foreign signature cannot
  /// satisfy the wait after reopening a draft.
  @override
  Future<void> waitForSignatureMarker(String marker) => waitForCondition(
        () => _isVisibleSignatureWithMarker(marker),
        timeout: TestTimeouts.long,
        reason: 'visible signature containing $marker in the web editor iframe',
      );

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

  /// A reopened draft must show the identity signature once: neither hidden
  /// nor applied a second time.
  @override
  Future<void> expectSingleVisibleSignature(String marker) async {
    await expectSignatureVisible(marker);
    final signatures = findAllSignatureElements(marker: marker);
    expect(
      signatures,
      hasLength(1),
      reason: 'identity signature must appear exactly once after reopening',
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
