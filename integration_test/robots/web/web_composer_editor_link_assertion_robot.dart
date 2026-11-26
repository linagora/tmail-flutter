import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'package:web/web.dart' as web;

import '../../base/core_robot.dart';
import '../../utils/wait_for_condition.dart';
import '../abstract/abstract_composer_editor_link_assertion_robot.dart';
import 'web_composer_editor_dom.dart';

/// Reads the links the user sees in the Summernote editor iframe.
class WebComposerEditorLinkAssertionRobot extends CoreRobot
    implements AbstractComposerEditorLinkAssertionRobot {
  WebComposerEditorLinkAssertionRobot(PatrolIntegrationTester $) : super($);

  @override
  Future<void> expectLinkHref(String text, String? href) async {
    try {
      await waitForCondition(() => _linkState(text) == _expectedState(href));
    } on TimeoutException {
      // Fall through: the exact comparison below reports what the editor holds.
    }
    expect(_linkState(text), _expectedState(href), reason: 'link "$text"');
  }

  String _expectedState(String? href) => href == null ? 'no href' : 'href=$href';

  String _linkState(String text) {
    final anchors = findNoteEditable()?.querySelectorAll('a');
    if (anchors == null) return 'editor not loaded';
    for (var i = 0; i < anchors.length; i++) {
      final anchor = anchors.item(i) as web.Element;
      if (anchor.textContent?.trim() != text) continue;
      final href = anchor.getAttribute('href');
      return href == null ? 'no href' : 'href=$href';
    }
    return 'no link';
  }
}
