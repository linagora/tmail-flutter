import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/thread/domain/constants/thread_constants.dart';

void main() {
  const asTextUnsubscribe = 'header:List-Unsubscribe:asText';

  group('ThreadConstants list headers (RFC 8621 4.1.2.3):', () {
    test('propertiesDefault has no asText List-Unsubscribe', () {
      final props = ThreadConstants.propertiesDefault.value;
      expect(props, isNot(contains(asTextUnsubscribe)));
      expect(props, contains('header:List-Unsubscribe'));
      expect(ThreadConstants.propertiesUpdatedDefault.value,
          isNot(contains(asTextUnsubscribe)));
    });

    test('propertiesCalendarEvent has no asText List-Unsubscribe', () {
      expect(ThreadConstants.propertiesCalendarEvent.value,
          isNot(contains(asTextUnsubscribe)));
    });

    test('propertiesDefault keeps asText for non RFC 2369 headers', () {
      final props = ThreadConstants.propertiesDefault.value;
      expect(props, containsAll([
        'header:X-Priority:asText',
        'header:Importance:asText',
        'header:Priority:asText',
      ]));
    });

    test('propertiesThreadDetailAdditional requests raw List-Post', () {
      expect(
        ThreadConstants.propertiesThreadDetailAdditional.value,
        {'header:List-Post', 'references', 'messageId'},
      );
    });
  });
}
