import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/core/request/request_invocation.dart';
import 'package:jmap_dart_client/jmap/core/response/response_invocation.dart';
import 'package:jmap_dart_client/jmap/core/response/response_object.dart';
import 'package:jmap_dart_client/jmap/core/state.dart' as jmap;
import 'package:tmail_ui_user/features/email/data/extensions/response_object_extension.dart';

void main() {
  final submissionMethodCallId = MethodCallId('c1');
  final otherMethodCallId = MethodCallId('c0');

  ResponseObject responseObjectWith(Map<String, dynamic> submissionArguments) {
    return ResponseObject(
      [
        ResponseInvocation(
          MethodName('Email/set'),
          ResponseArguments(<String, dynamic>{'created': <String, dynamic>{}}),
          otherMethodCallId,
        ),
        ResponseInvocation(
          MethodName('EmailSubmission/set'),
          ResponseArguments(submissionArguments),
          submissionMethodCallId,
        ),
      ],
      jmap.State('state-1'),
    );
  }

  group('ResponseObjectExtension::parseInvalidRecipients', () {
    test('should return the addresses listed by an invalidRecipients SetError', () {
      final responseObject = responseObjectWith(<String, dynamic>{
        'notCreated': <String, dynamic>{
          'create-1': <String, dynamic>{
            'type': 'invalidRecipients',
            'description': 'Invalid recipients',
            'invalidRecipients': ['alice@invalid', 'bob@invalid'],
          },
        },
      });

      expect(
        responseObject.parseInvalidRecipients(submissionMethodCallId),
        ['alice@invalid', 'bob@invalid'],
      );
    });

    test('should deduplicate addresses reported by several SetErrors', () {
      final responseObject = responseObjectWith(<String, dynamic>{
        'notCreated': <String, dynamic>{
          'create-1': <String, dynamic>{
            'type': 'invalidRecipients',
            'invalidRecipients': ['alice@invalid'],
          },
          'create-2': <String, dynamic>{
            'type': 'invalidRecipients',
            'invalidRecipients': ['alice@invalid', 'bob@invalid'],
          },
        },
      });

      expect(
        responseObject.parseInvalidRecipients(submissionMethodCallId),
        ['alice@invalid', 'bob@invalid'],
      );
    });

    test('should return empty when the SetError is of another type', () {
      final responseObject = responseObjectWith(<String, dynamic>{
        'notCreated': <String, dynamic>{
          'create-1': <String, dynamic>{
            'type': 'overQuota',
            'description': 'Over quota',
          },
        },
      });

      expect(
        responseObject.parseInvalidRecipients(submissionMethodCallId),
        isEmpty,
      );
    });

    test('should return empty when the SetError omits the invalidRecipients property', () {
      final responseObject = responseObjectWith(<String, dynamic>{
        'notCreated': <String, dynamic>{
          'create-1': <String, dynamic>{'type': 'invalidRecipients'},
        },
      });

      expect(
        responseObject.parseInvalidRecipients(submissionMethodCallId),
        isEmpty,
      );
    });

    test('should return empty when the response has no notCreated map', () {
      final responseObject = responseObjectWith(<String, dynamic>{
        'created': <String, dynamic>{'create-1': <String, dynamic>{}},
      });

      expect(
        responseObject.parseInvalidRecipients(submissionMethodCallId),
        isEmpty,
      );
    });

    test('should return empty when no response matches the method call id', () {
      final responseObject = responseObjectWith(<String, dynamic>{
        'notCreated': <String, dynamic>{
          'create-1': <String, dynamic>{
            'type': 'invalidRecipients',
            'invalidRecipients': ['alice@invalid'],
          },
        },
      });

      expect(
        responseObject.parseInvalidRecipients(MethodCallId('unknown')),
        isEmpty,
      );
    });
  });
}
