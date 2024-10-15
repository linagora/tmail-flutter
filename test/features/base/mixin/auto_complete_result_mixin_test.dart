import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:tmail_ui_user/features/base/mixin/auto_complete_result_mixin.dart';
import 'package:tmail_ui_user/features/composer/domain/state/get_autocomplete_state.dart';
import 'package:tmail_ui_user/features/composer/domain/state/get_device_contact_suggestions_state.dart';

class AutoCompleteResult with AutoCompleteResultMixin {}

void main() {
  late AutoCompleteResult autoCompleteResult;

  setUp(() {
    autoCompleteResult = AutoCompleteResult();
  });

  group('handleAutoCompleteSuccess::test', () {
    test('SHOULD return list of EmailAddress from GetAutoCompleteSuccess', () {
      final mockEmailAddress = EmailAddress('Test User', 'test@example.com');
      final success = GetAutoCompleteSuccess([mockEmailAddress]);
      final result = autoCompleteResult.handleAutoCompleteSuccess(success, 'query');

      expect(result, [mockEmailAddress]);
    });

    test('SHOULD return list of EmailAddress from GetDeviceContactSuggestionsSuccess', () {
      final mockEmailAddress = EmailAddress('Contact User', 'contact@example.com');
      final success = GetDeviceContactSuggestionsSuccess([mockEmailAddress]);
      final result = autoCompleteResult.handleAutoCompleteSuccess(success, 'query');

      expect(result, [mockEmailAddress]);
    });

    test('SHOULD return query email address if list is empty and query is a valid email', () {
      final success = GetAutoCompleteSuccess([]);
      final result = autoCompleteResult.handleAutoCompleteSuccess(success, 'newemail@example.com');

      expect(result, [EmailAddress('newemail@example.com', 'newemail@example.com')]);
    });

    test('SHOULD add query email address to the start if not present and is a valid email', () {
      final mockEmailAddress = EmailAddress('Existing User', 'existing@example.com');
      final success = GetAutoCompleteSuccess([mockEmailAddress]);
      final result = autoCompleteResult.handleAutoCompleteSuccess(success, 'newemail@example.com');

      expect(result, [
        EmailAddress('newemail@example.com', 'newemail@example.com'),
        mockEmailAddress
      ]);
    });

    test('SHOULD not add query email address if already present', () {
      final mockEmailAddress = EmailAddress('Existing User', 'existing@example.com');
      final success = GetAutoCompleteSuccess([mockEmailAddress]);
      final result = autoCompleteResult.handleAutoCompleteSuccess(success, 'existing@example.com');

      expect(result, [mockEmailAddress]);
    });
  });
}
