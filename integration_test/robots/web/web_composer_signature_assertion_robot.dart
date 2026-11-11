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

  @override
  Future<void> editSignature(String marker, String appendedText) async {
    final signature = findSignatureElement(marker: marker);
    if (signature == null) {
      throw StateError('No signature containing $marker in the editor');
    }
    splitSignatureWithText(signature, appendedText);
    await $.pumpAndTrySettle();
  }

  @override
  Future<void> switchIdentity(String identityName) async {
    final controller = findWebComposerController($);
    if (controller == null) throw StateError('No web composer controller');
    final identity = controller.listFromIdentities
        .firstWhere((item) => item.name == identityName);
    await controller.onChangeIdentity(identity);
    await $.pumpAndTrySettle();
  }

  /// Only the new identity signature may remain: no stale or edited text.
  @override
  Future<void> expectOnlySignature(
    String marker, {
    required List<String> absentText,
  }) async {
    await waitForSignatureMarker(marker);
    expect(
      findAllSignatureElements(),
      hasLength(1),
      reason: 'switching identity must leave exactly one signature',
    );
    final editorText = findNoteEditable()?.textContent ?? '';
    for (final text in absentText) {
      expect(
        editorText,
        isNot(contains(text)),
        reason: 'stale signature text "$text" survived the identity switch',
      );
    }
  }

  /// The cache is refreshed by the editor's own change event, which arrives
  /// after the switch returns, so it is polled rather than read once.
  @override
  Future<void> expectNoSignature({required List<String> absentText}) async {
    bool cacheIsClean() {
      final cached = findWebComposerController($)?.textEditorWeb ?? '';
      return !cached.contains('tmail-signature') &&
          absentText.every((text) => !cached.contains(text));
    }

    await waitForCondition(
      cacheIsClean,
      timeout: TestTimeouts.long,
      reason: 'cached composer body to drop the removed signature',
    );
    expect(
      findAllSignatureElements(),
      isEmpty,
      reason: 'an identity without signature must leave none in the editor',
    );
    final editorText = findNoteEditable()?.textContent ?? '';
    for (final text in absentText) {
      expect(editorText, isNot(contains(text)));
    }
  }

  bool _isVisibleSignatureWithMarker(String marker) {
    final signature = findSignatureElement(marker: marker);
    if (signature == null) return false;
    return !signatureStyleIsHidden(signature);
  }

  bool _cachedHasMarker(String marker) =>
      findWebComposerController($)?.textEditorWeb?.contains(marker) == true;
}
