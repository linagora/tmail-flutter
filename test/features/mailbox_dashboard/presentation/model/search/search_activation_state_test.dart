import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/search_activation_state.dart';

void main() {
  group('SearchActivationState', () {
    test('initial is inactive for both simple and advanced', () {
      final state = SearchActivationState.initial();

      expect(state.simpleIsActivated, isFalse);
      expect(state.advancedIsActivated, isFalse);
      expect(state.isRunning, isFalse);
    });

    test('isRunning is true when simple search is activated', () {
      final state = SearchActivationState.initial().copyWith(
        simpleIsActivated: true,
      );

      expect(state.isRunning, isTrue);
    });

    test('isRunning is true when advanced search is activated', () {
      final state = SearchActivationState.initial().copyWith(
        advancedIsActivated: true,
      );

      expect(state.isRunning, isTrue);
    });

    test('copyWith preserves the untouched flag', () {
      final state = SearchActivationState.initial()
          .copyWith(simpleIsActivated: true)
          .copyWith(advancedIsActivated: true);

      expect(state.simpleIsActivated, isTrue);
      expect(state.advancedIsActivated, isTrue);
    });
  });
}
