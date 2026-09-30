import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'package:tmail_ui_user/features/composer/presentation/composer_controller.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/recipient_collapsed_item_widget.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/subject_composer_widget.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:universal_html/html.dart' as html;

import '../../base/core_robot.dart';
import '../../models/composer_reload_test_context.dart';
import '../../utils/wait_for_condition.dart';
import '../abstract/abstract_composer_reload_assertion_robot.dart';

class WebComposerReloadAssertionRobot extends CoreRobot
    implements AbstractComposerReloadAssertionRobot {
  final ComposerReloadTestContext Function() _context;

  WebComposerReloadAssertionRobot(PatrolIntegrationTester $, this._context)
    : super($);

  Finder get _composerFinder => find.byKey(Key(_context().composerId));

  ComposerController get _restoredController {
    final context = _context();
    return context.dashboard.composerManager
        .getComposerView(context.composerId)
        .controller;
  }

  String? get _snapshot => html.window.sessionStorage[_context().cacheKey];

  @override
  void expectSnapshotAbsent() => expect(_snapshot, isNull);

  @override
  void expectSnapshotPresent() => expect(_snapshot, isNotNull);

  @override
  Future<void> expectComposerAbsent() async {
    await $.pumpAndTrySettle();
    expect(_composerFinder, findsNothing);
  }

  @override
  Future<void> expectRestoredComposerVisible() =>
      $.waitUntilVisible($(_composerFinder));

  @override
  Future<void> expectRestoredContent(
    String subject,
    String recipient,
    String body,
  ) async {
    await _expectRestoredBody(body);
    _expectNewComposerController();
    _expectRestoredSubject(subject);
    _expectRestoredRecipient(recipient);
  }

  void _expectNewComposerController() {
    expect(_restoredController, isNot(same(_context().originalController)));
  }

  void _expectRestoredSubject(String subject) {
    final subjectFinder = find.descendant(
      of: _composerFinder,
      matching: find.byType(SubjectComposerWidget),
    );
    expect(
      $.tester.widget<SubjectComposerWidget>(subjectFinder).textController.text,
      subject,
    );
  }

  void _expectRestoredRecipient(String recipient) {
    expect(
      find.descendant(
        of: _composerFinder,
        matching: find.byWidgetPredicate(
          (widget) =>
              widget is RecipientCollapsedItemWidget &&
              widget.emailAddress.email == recipient,
        ),
      ),
      findsOneWidget,
    );
  }

  Future<void> _expectRestoredBody(String body) async {
    await waitForCondition(
      () => _restoredController.textEditorWeb?.contains(body) ?? false,
    );
    await $.platformAutomator.web.scrollTo(
      WebSelector(cssOrXpath: 'div.note-editable:has-text("$body")'),
      iframeSelector: WebSelector(cssOrXpath: 'iframe'),
    );
  }

  @override
  bool isDiscardConfirmationVisible() =>
      $(AppLocalizations().discardChanges).exists;

  @override
  Future<void> expectSnapshotRemoved() async {
    await waitForCondition(() => _snapshot == null);
    expectSnapshotAbsent();
  }
}
