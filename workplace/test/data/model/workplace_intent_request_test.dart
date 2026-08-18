import 'package:flutter_test/flutter_test.dart';
import 'package:workplace/data/model/workplace_intent_request.dart';
import 'package:workplace/domain/entity/workplace_action_config.dart';

void main() {
  group('WorkplaceActionConfigRequest::toJson::', () {
    test('includes maxFileSize and availableSize when both are set', () {
      const request = WorkplaceActionConfigRequest(
        label: 'Attachment',
        maxFileSize: 100,
        availableSize: 100,
      );

      final json = request.toJson();

      expect(json['maxFileSize'], equals(100));
      expect(json['availableSize'], equals(100));
    });

    test('omits maxFileSize and availableSize when both are null', () {
      const request = WorkplaceActionConfigRequest(label: 'Attachment');

      final json = request.toJson();

      expect(json.containsKey('maxFileSize'), isFalse);
      expect(json.containsKey('availableSize'), isFalse);
    });
  });

  group('WorkplaceActionConfigRequest::fromEntity::', () {
    test('copies maxFileSize and availableSize from the domain entity', () {
      const entity = WorkplaceActionConfig(
        label: 'Attachment',
        maxFileSize: 5000,
        availableSize: 5000,
      );

      final request = WorkplaceActionConfigRequest.fromEntity(entity);

      expect(request.label, equals('Attachment'));
      expect(request.maxFileSize, equals(5000));
      expect(request.availableSize, equals(5000));
    });

    test('copies null maxFileSize and availableSize when entity has none', () {
      const entity = WorkplaceActionConfig(label: 'Attachment');

      final request = WorkplaceActionConfigRequest.fromEntity(entity);

      expect(request.maxFileSize, isNull);
      expect(request.availableSize, isNull);
    });
  });
}
