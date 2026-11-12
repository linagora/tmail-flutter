import 'package:core/presentation/views/button/multi_click_widget.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/preferences/preferences_view.dart';

import '../base/core_robot.dart';
import 'abstract/abstract_preferences_robot.dart';

abstract class PreferencesRobot extends CoreRobot implements AbstractPreferencesRobot {
  PreferencesRobot(super.$);

  static const _revealTapCount = 7;

  @override
  Future<void> ensureDelegationPreferenceReady() async {
    // MultiClickWidget resets after 2s — no settle between taps.
    for (var tap = 0; tap < _revealTapCount; tap++) {
      await $(MultiClickWidget).tap(settlePolicy: SettlePolicy.noSettle);
    }
    await $.pumpAndSettle();
  }

  @override
  Future<void> togglePreferenceOption(String title) async {
    await _bringPreferenceOnScreen(title);
    await $(ValueKey(title)).tap();
  }

  @override
  Future<void> expectPreferenceOption(
    String title, {
    required bool switchedOn,
  }) async {
    final key = switchedOn
        ? 'setting_option_switch_on'
        : 'setting_option_switch_off';
    await _bringPreferenceOnScreen(title);
    await $(ValueKey(title)).$(ValueKey(key)).waitUntilVisible();
  }

  // Without a view, scrollTo drives the first Scrollable on screen (the settings menu).
  Future<void> _bringPreferenceOnScreen(String title) async {
    await $(ValueKey(title)).scrollTo(
      view: find
          .descendant(
            of: find.byType(PreferencesView),
            matching: find.byType(Scrollable),
          )
          .first,
    );
  }
}
