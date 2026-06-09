import 'package:flutter/material.dart';
import 'package:labels/extensions/label_extension.dart';
import 'package:patrol/patrol.dart';
import 'package:tmail_ui_user/features/base/model/ui_keys.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/widgets/search_input_form_widget.dart';
import 'package:tmail_ui_user/features/thread/presentation/widgets/email_tile_web_builder.dart';

import '../abstract/abstract_thread_robot.dart';
import '../thread_robot.dart';

class WebThreadRobot extends ThreadRobot implements AbstractThreadRobot {
  WebThreadRobot(super.$);

  static const Duration _emailOpenPumpDuration = Duration(seconds: 2);

  @override
  Future<void> expectAppGridVisible() async {
    await $(const ValueKey(UiKeys.toggleAppGridButton)).waitUntilVisible();
  }

  @override
  Future<void> openAppGrid() async {
    await $(const ValueKey(UiKeys.toggleAppGridButton)).tap();
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

  @override
  Future<void> openMailbox() async {
    // Web desktop: mailbox sidebar is always visible — no hamburger menu to tap.
  }

  @override
  Future<void> tapOnSearchField() async {
    await $(SearchInputFormWidget).$(TextField).tap();
    // Give the dashboard's background sync (Email/changes, Mailbox/changes,
    // triggered by the test's email provisioning) time to finish before typing.
    //
    // Quick-search suggestions are held in a transient overlay widget. If a sync
    // response arrives while the suggestion request is in flight, the dashboard
    // rebuilds and disposes that overlay, so the returned suggestions are dropped
    // and no tiles ever render — the test then fails even though the search worked.
    //
    // This is a wall-clock wait on purpose: the dependency is real backend/network
    // time, which pumpAndSettle()/waitForCondition() cannot observe (the Flutter
    // frame scheduler goes idle between network responses, so they return too early).
    // Scoped to web only; it does not affect mobile or production code.
    await $.pump(const Duration(seconds: 3));
  }

  @override
  Future<void> openSearchSuggestion() async {
    await $(SearchInputFormWidget).$(TextField).tap();
  }

  @override
  Future<void> selectMailboxByName(String name) async {
    await tapOnMailboxWithName(name);
  }

  Future<void> _openEmailTile(PatrolFinder emailFinder) async {
    await $.waitUntilVisible(emailFinder);
    await emailFinder.tap();
    await $.pump(_emailOpenPumpDuration);
  }
}
