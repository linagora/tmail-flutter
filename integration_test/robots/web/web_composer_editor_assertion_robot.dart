import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as html_parser;
import 'package:patrol/patrol.dart';

import '../../base/core_robot.dart';
import '../../utils/wait_for_condition.dart';
import '../abstract/abstract_composer_editor_assertion_robot.dart';
import 'web_composer_controller_finder.dart';

class WebComposerEditorAssertionRobot extends CoreRobot
    implements AbstractComposerEditorAssertionRobot {
  WebComposerEditorAssertionRobot(PatrolIntegrationTester $) : super($);

  @override
  Future<void> expectEditorListSkeleton(String skeleton) async {
    try {
      await waitForCondition(() => _editorListSkeleton() == skeleton);
    } on TimeoutException {
      // Fall through: the exact comparison below reports what the editor holds.
    }
    expect(_editorListSkeleton(), skeleton);
  }

  String _editorListSkeleton() => _describeNodes(
        html_parser
            .parseFragment(findWebComposerController($)?.textEditorWeb ?? '')
            .nodes,
      );

  String _describeNodes(List<dom.Node> nodes) =>
      nodes.map(_describeNode).where((part) => part.isNotEmpty).join(' ');

  String _describeNode(dom.Node node) {
    if (node is dom.Text) return node.text.trim();
    if (node is! dom.Element) return '';
    final children = _describeNodes(node.nodes);
    return switch (node.localName) {
      'ul' || 'ol' || 'li' => '${node.localName}[$children]',
      _ => children,
    };
  }
}
