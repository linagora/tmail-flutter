import 'package:flutter_test/flutter_test.dart';
import 'package:server_settings/server_settings/tmail_server_settings.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/preferences/preferences_setting.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/preferences/thread_detail_config.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/preferences/model/preference_option_registry.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/preferences/model/preference_options.dart';
import 'package:tmail_ui_user/features/server_settings/domain/state/update_server_setting_state.dart';

import '../../../../../fixtures/preference_option_fixtures.dart';

void main() {
  late FakeUpdateLocalSettingsInteractor fakeLocal;
  late FakeUpdateServerSettingInteractor fakeServer;
  late PreferenceOptionRegistry registry;

  setUp(() {
    fakeLocal = FakeUpdateLocalSettingsInteractor();
    fakeServer = FakeUpdateServerSettingInteractor();
    registry = PreferenceOptionRegistry([
      ReadReceiptPreferenceOption(fakeServer),
      SenderPriorityPreferenceOption(fakeServer),
      ThreadPreferenceOption(fakeLocal),
      SpamReportPreferenceOption(fakeLocal),
      AIScribePreferenceOption(fakeLocal),
      AILabelCategorizationPreferenceOption(fakeServer),
      LabelPreferenceOption(fakeLocal),
    ]);
  });

  group('registry order', () {
    test('exposes every option in display order', () {
      expect(
        registry.all.map((option) => option.id),
        [
          'read-receipt',
          'sender-priority',
          'thread',
          'spam-report',
          'ai-scribe',
          'ai-label-categorization',
          'label',
        ],
      );
    });
  });

  group('availability', () {
    test('server options need a non-null server settings snapshot', () {
      final visible = registry.available(preferencesContext()).map((o) => o.id);
      expect(visible, isNot(contains('read-receipt')));
      expect(visible, isNot(contains('sender-priority')));
    });

    test('read-receipt & sender-priority show once server settings exist', () {
      final visible = registry
          .available(preferencesContext(serverOptions: TMailServerSettingOptions()))
          .map((o) => o.id);
      expect(visible, containsAll(['read-receipt', 'sender-priority']));
    });

    test('thread & spam-report need local configs', () {
      final hidden =
          registry.available(preferencesContext(localSettings: PreferencesSetting([])));
      expect(hidden.map((o) => o.id), isNot(contains('thread')));

      final shown = registry
          .available(preferencesContext(localSettings: PreferencesSetting.initial()))
          .map((o) => o.id);
      expect(shown, containsAll(['thread', 'spam-report']));
    });

    test('ai-scribe needs the scribe capability on top of local configs', () {
      final local = PreferencesSetting.initial();
      expect(
        registry.available(preferencesContext(localSettings: local)).map((o) => o.id),
        isNot(contains('ai-scribe')),
      );
      expect(
        registry
            .available(preferencesContext(localSettings: local, isAIScribeAvailable: true))
            .map((o) => o.id),
        contains('ai-scribe'),
      );
    });

    test('ai-label-categorization needs server settings AND the AI capability', () {
      final server = TMailServerSettingOptions();
      expect(
        registry.available(preferencesContext(serverOptions: server)).map((o) => o.id),
        isNot(contains('ai-label-categorization')),
      );
      expect(
        registry
            .available(preferencesContext(
              serverOptions: server,
              isAICapabilitySupported: true,
            ))
            .map((o) => o.id),
        contains('ai-label-categorization'),
      );
    });

    test('label is gated only on label visibility', () {
      expect(
        registry.available(preferencesContext()).map((o) => o.id),
        isNot(contains('label')),
      );
      expect(
        registry
            .available(preferencesContext(isLabelVisibilityEnabled: true))
            .map((o) => o.id),
        contains('label'),
      );
    });
  });

  group('write behaviour', () {
    test('local toggle persists the negation of the current value', () {
      ThreadPreferenceOption(fakeLocal)
          .toggle(currentValue: false, context: preferencesContext());

      expect(fakeLocal.captured, isA<ThreadDetailConfig>());
      expect((fakeLocal.captured as ThreadDetailConfig).isEnabled, isTrue);
    });

    test('server applyTo maps the option onto the settings payload', () {
      final updated = ReadReceiptPreferenceOption(fakeServer)
          .applyTo(TMailServerSettingOptions(), enabled: true);

      expect(updated.alwaysReadReceipts, isTrue);
    });

    test('server toggle fails fast when session/account are missing', () async {
      final result = await ReadReceiptPreferenceOption(fakeServer)
          .toggle(currentValue: false, context: preferencesContext(
            serverOptions: TMailServerSettingOptions(),
          ))
          .first;

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<UpdateServerSettingFailure>()),
        (_) => fail('expected a failure'),
      );
      expect(fakeServer.captured, isNull);
    });
  });
}
