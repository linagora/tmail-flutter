import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/preferences_option_type.dart';

void main() {
  group('PreferencesOptionType map exhaustiveness', () {
    test(
      'WHEN a new enum value is added\n'
      'THEN _stringBuilders must have an entry for it',
      () {
        expect(
          PreferencesOptionType.missingFromStringBuilders,
          isEmpty,
          reason: 'Add entries to _stringBuilders for: '
              '${PreferencesOptionType.missingFromStringBuilders}',
        );
      },
    );

    test(
      'WHEN a new enum value is added\n'
      'THEN _enabledResolvers must have an entry for it',
      () {
        expect(
          PreferencesOptionType.missingFromEnabledResolvers,
          isEmpty,
          reason: 'Add entries to _enabledResolvers for: '
              '${PreferencesOptionType.missingFromEnabledResolvers}',
        );
      },
    );
  });
}
