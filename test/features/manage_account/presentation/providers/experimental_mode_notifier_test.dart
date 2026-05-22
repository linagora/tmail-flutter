import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/providers/experimental_mode_notifier.dart';
import 'package:tmail_ui_user/main/providers/shared_preferences_provider.dart';

void main() {
  group('ExperimentalModeNotifier', () {
    late SharedPreferences prefs;
    late ProviderContainer container;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('initial state is false', () async {
      await container.read(experimentalModeNotifierProvider.notifier).ensureLoaded;
      expect(container.read(experimentalModeNotifierProvider), isFalse);
    });

    test('enable sets state to true', () async {
      await container.read(experimentalModeNotifierProvider.notifier).enable();
      expect(container.read(experimentalModeNotifierProvider), isTrue);
    });

    test('enable is idempotent — second call has no effect', () async {
      await container.read(experimentalModeNotifierProvider.notifier).enable();
      await container.read(experimentalModeNotifierProvider.notifier).enable();
      expect(container.read(experimentalModeNotifierProvider), isTrue);
    });

    test('state persists across notifier restarts', () async {
      await container.read(experimentalModeNotifierProvider.notifier).enable();

      final container2 = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
      );
      addTearDown(container2.dispose);

      await container2.read(experimentalModeNotifierProvider.notifier).ensureLoaded;
      expect(container2.read(experimentalModeNotifierProvider), isTrue);
    });

    test('activationTapCount is 7', () {
      expect(ExperimentalModeNotifier.activationTapCount, 7);
    });
  });
}
