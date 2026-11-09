import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/preferences/delegation_config.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/preferences/preferences_setting.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/preferences/model/preference_options/delegation_preference_option.dart';

import '../../../../../../fixtures/delegation_fixtures.dart';
import '../../../../../../fixtures/preference_option_fixtures.dart';

void main() {
  late FakeUpdateLocalSettingsInteractor fakeLocal;
  late DelegationPreferenceOption option;

  setUp(() {
    fakeLocal = FakeUpdateLocalSettingsInteractor();
    option = DelegationPreferenceOption(fakeLocal);
  });

  test(
    'WHEN the preferences list is rendered\n'
    'THEN delegation stays hidden behind the 7-tap reveal',
    () {
      expect(option.isExperimental, isTrue);
    },
  );

  test(
    'WHEN no delegation config has been stored yet\n'
    'THEN the toggle reads as off',
    () {
      final context = preferencesContext(localSettings: PreferencesSetting.initial());

      expect(option.isEnabled(context), isFalse);
    },
  );

  test(
    'WHEN the user turned delegation on\n'
    'THEN the toggle reads as on',
    () {
      final context = preferencesContext(
        localSettings: PreferencesSetting([DelegationConfig(isEnabled: true)]),
      );

      expect(option.isEnabled(context), isTrue);
    },
  );

  test(
    'WHEN the toggle is switched on\n'
    'THEN an enabled delegation config is persisted',
    () {
      option.toggle(
        currentValue: false,
        context: preferencesContext(localSettings: PreferencesSetting.initial()),
      );

      expect(fakeLocal.captured, DelegationConfig(isEnabled: true));
    },
  );

  test(
    'WHEN the toggle is switched off\n'
    'THEN a disabled delegation config is persisted',
    () {
      option.toggle(
        currentValue: true,
        context: preferencesContext(
          localSettings: PreferencesSetting([DelegationConfig(isEnabled: true)]),
        ),
      );

      expect(fakeLocal.captured, DelegationConfig(isEnabled: false));
    },
  );

  group('availability', () {
    test(
      'WHEN the server has the delegation capability\n'
      'THEN the setting is listed',
      () {
        final context = preferencesContext(
          session: DelegationFixtures.session(),
          localSettings: PreferencesSetting.initial(),
        );

        expect(option.isAvailable(context), isTrue);
      },
    );

    test(
      'WHEN the server lacks the delegation capability\n'
      'THEN the setting is hidden',
      () {
        final context = preferencesContext(
          session: DelegationFixtures.sessionWithoutDelegationCapability(),
          localSettings: PreferencesSetting.initial(),
        );

        expect(option.isAvailable(context), isFalse);
      },
    );

    test(
      'WHEN no session is loaded\n'
      'THEN the setting is hidden',
      () {
        final context = preferencesContext(localSettings: PreferencesSetting.initial());

        expect(option.isAvailable(context), isFalse);
      },
    );

    test(
      'WHEN local settings have not loaded\n'
      'THEN the setting is hidden, even with the capability',
      () {
        final context = preferencesContext(session: DelegationFixtures.session());

        expect(option.isAvailable(context), isFalse);
      },
    );
  });
}
