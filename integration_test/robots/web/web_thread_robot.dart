import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:labels/extensions/label_extension.dart';
import 'package:patrol/patrol.dart';
import 'package:tmail_ui_user/features/base/model/ui_keys.dart';
import 'package:tmail_ui_user/features/thread/presentation/widgets/email_tile_web_builder.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

import '../mobile/mobile_thread_robot.dart';

class WebThreadRobot extends MobileThreadRobot {
  WebThreadRobot(super.$);

  static const Duration _emailOpenPumpDuration = Duration(seconds: 2);

  @override
  Future<void> expectAppGridVisible() async {
    await $(const ValueKey(UiKeys.toggleAppGridButton)).waitUntilVisible();
  }

  @override
  Future<void> openEmailWithSubject(String subject) async {
    final email = $(EmailTileBuilder).which<EmailTileBuilder>(
      (view) =>
          view.presentationEmail.subject != null &&
          view.presentationEmail.subject == subject,
    );
    await _openEmailTile(email);
  }

  @override
  Future<void> openEmailWithLabel(String labelDisplayName) async {
    final email = $(EmailTileBuilder).which<EmailTileBuilder>(
      (view) =>
          view.labels
              ?.any((label) => label.safeDisplayName == labelDisplayName) ==
          true,
    );
    await _openEmailTile(email);
  }

  Future<void> _openEmailTile(PatrolFinder emailFinder) async {
    await $.waitUntilVisible(emailFinder);
    await emailFinder.tap();
    await $.pump(_emailOpenPumpDuration);
  }

  @override
  Future<void> openMailbox() async {}

    /// Runs the onTap handler for the [TextSpan] which matches the search-string.
  void fireOnTap(Finder finder, String text) {
    final Element element = finder.evaluate().single;
    final RenderParagraph paragraph = element.renderObject as RenderParagraph;
    // The children are the individual TextSpans which have GestureRecognizers
    paragraph.text.visitChildren((dynamic span) {
      if (span.text != text) return true; // continue iterating.

      (span.recognizer as TapGestureRecognizer).onTap?.call();
      return false; // stop iterating, we found the one.
    });
  }

  @override
  Future<void> tapEmptyTrashBanner() async {
    final textContainEmptyTrash = find.textContaining(AppLocalizations().empty_trash_now);
    await $.waitUntilVisible($(textContainEmptyTrash));
    fireOnTap(
      $(textContainEmptyTrash),
      AppLocalizations().empty_trash_now,
    );
  }
}
