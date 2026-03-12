import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/mail/email/keyword_identifier.dart';
import 'package:labels/model/hex_color.dart';
import 'package:labels/model/label.dart';

void main() {
  group('Label', () {
    group('fromJson', () {
      test('should deserialize all fields correctly', () {
        final json = {
          "id": "123",
          "keyword": "important",
          "displayName": "Important",
          "color": "#ff0000",
          "description": "Important emails"
        };

        final label = Label.fromJson(json);

        expect(label.id, equals(Id('123')));
        expect(label.keyword, equals(KeyWordIdentifier('important')));
        expect(label.displayName, equals('Important'));
        expect(label.color, equals(HexColor('#ff0000')));
        expect(label.description, equals('Important emails'));
      });

      test('should handle missing optional fields', () {
        final json = {
          "displayName": "Simple label",
        };

        final label = Label.fromJson(json);

        expect(label.id, isNull);
        expect(label.keyword, isNull);
        expect(label.color, isNull);
        expect(label.description, isNull);
      });
    });

    group('toJson', () {
      test('should serialize all fields correctly', () {
        final label = Label(
          id: Id('123'),
          keyword: KeyWordIdentifier('important'),
          displayName: 'Important',
          color: HexColor('#ff0000'),
          description: 'Important emails',
        );

        final json = label.toJson();

        expect(json['id'], equals('123'));
        expect(json['keyword'], equals('important'));
        expect(json['displayName'], equals('Important'));
        expect(json['color'], equals('#ff0000'));
        expect(json['description'], equals('Important emails'));
      });

      test('should not include null fields', () {
        final label = Label(
          displayName: 'Label',
        );

        final json = label.toJson();

        expect(json.containsKey('id'), isFalse);
        expect(json.containsKey('keyword'), isFalse);
        expect(json.containsKey('color'), isFalse);
        expect(json.containsKey('description'), isFalse);
      });
    });

    group('equatable', () {
      test('should support value equality', () {
        final label1 = Label(
          displayName: 'Test',
          description: 'desc',
        );

        final label2 = Label(
          displayName: 'Test',
          description: 'desc',
        );

        expect(label1, equals(label2));
      });
    });
  });
}
