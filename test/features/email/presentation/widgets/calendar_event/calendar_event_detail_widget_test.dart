import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/calendar_event/calendar_event_detail_widget.dart';

void main() {
  group('generateEventDescriptionAsHtml', () {
    test('SHOULD return empty when description and email body are empty', () {
      expect(
        generateEventDescriptionAsHtml(description: '', emailContent: ''),
        isEmpty,
      );
    });

    test('SHOULD return empty when description is null and email body is empty', () {
      expect(
        generateEventDescriptionAsHtml(description: null, emailContent: ''),
        isEmpty,
      );
    });

    test('SHOULD return empty when description is whitespace and email body is empty', () {
      expect(
        generateEventDescriptionAsHtml(description: '   ', emailContent: '  '),
        isEmpty,
      );
    });

    test('SHOULD keep the card when description has text and email body is empty', () {
      final html = generateEventDescriptionAsHtml(
        description: 'Sprint planning',
        emailContent: '',
      );

      expect(html, isNotEmpty);
      expect(html, contains('Sprint planning'));
    });

    test('SHOULD keep the card when description is empty and email body has HTML', () {
      final html = generateEventDescriptionAsHtml(
        description: '',
        emailContent: '<p>Invitation body</p>',
      );

      expect(html, isNotEmpty);
      expect(html, contains('<p>Invitation body</p>'));
    });
  });
}
