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

  void expectParsedRecipients(
    String description,
    Map<String, dynamic> submissionArguments,
    Object expected, {
    MethodCallId? methodCallId,
  }) {
    test(description, () {
      final responseObject = responseObjectWith(submissionArguments);
      expect(
        responseObject.parseInvalidRecipients(methodCallId ?? submissionMethodCallId),
        expected,
      );
    });
  }

  group('EmailSubmissionResponseExtension::parseInvalidRecipients', () {
    expectParsedRecipients(
      'should return the addresses listed by an invalidRecipients SetError',
      <String, dynamic>{
        'notCreated': <String, dynamic>{
          'create-1': <String, dynamic>{
            'type': 'invalidRecipients',
            'description': 'Invalid recipients',
            'invalidRecipients': ['alice@invalid', 'bob@invalid'],
          },
        },
      },
      {'alice@invalid', 'bob@invalid'},
    );

    expectParsedRecipients(
      'should deduplicate addresses reported by several SetErrors',
      <String, dynamic>{
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
      },
      {'alice@invalid', 'bob@invalid'},
    );

    expectParsedRecipients(
      'should return empty when the SetError is of another type',
      <String, dynamic>{
        'notCreated': <String, dynamic>{
          'create-1': <String, dynamic>{
            'type': 'overQuota',
            'description': 'Over quota',
          },
        },
      },
      isEmpty,
    );

    expectParsedRecipients(
      'should return empty when the SetError omits the invalidRecipients property',
      <String, dynamic>{
        'notCreated': <String, dynamic>{
          'create-1': <String, dynamic>{'type': 'invalidRecipients'},
        },
      },
      isEmpty,
    );

    expectParsedRecipients(
      'should return empty when the response has no notCreated map',
      <String, dynamic>{
        'created': <String, dynamic>{'create-1': <String, dynamic>{}},
      },
      isEmpty,
    );

    expectParsedRecipients(
      'should return empty when no response matches the method call id',
      <String, dynamic>{
        'notCreated': <String, dynamic>{
          'create-1': <String, dynamic>{
            'type': 'invalidRecipients',
            'invalidRecipients': ['alice@invalid'],
          },
        },
      },
      isEmpty,
      methodCallId: MethodCallId('unknown'),
    );
  });
}
