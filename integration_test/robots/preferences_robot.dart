import 'package:core/presentation/views/button/multi_click_widget.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

import '../base/core_robot.dart';
import 'abstract/abstract_preferences_robot.dart';

abstract class PreferencesRobot extends CoreRobot implements AbstractPreferencesRobot {
  PreferencesRobot(super.$);

  static const _revealTapCount = 7;
  // e2e runs with --lang=en-US; Thread is always listed above experimental rows.
  static const _preferencesListAnchorTitle = 'Thread';

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

  Future<void> _bringPreferenceOnScreen(String title) async {
    final preferenceKey = ValueKey(title);
    if ($(preferenceKey).exists) {
      await $(preferenceKey).scrollTo();
      return;
    }
    // Lazy ListView: below-fold rows are not hit-testable until scrolled into view.
    await _scrollPreferencesListToEnd(shownTitle: _preferencesListAnchorTitle);
    await $(preferenceKey).scrollTo();
  }

  Future<void> _scrollPreferencesListToEnd({required String shownTitle}) async {
    await $(ValueKey(shownTitle)).waitUntilVisible();
    final preferencesList = find
        .ancestor(
          of: find.byKey(ValueKey(shownTitle)),
          matching: find.byType(Scrollable),
        )
        .first;
    await $.tester.drag(preferencesList, const Offset(0, -10000));
    await $.pumpAndSettle();
  }
}
