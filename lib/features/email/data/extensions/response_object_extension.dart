import 'package:collection/collection.dart';
import 'package:jmap_dart_client/jmap/core/request/request_invocation.dart';
import 'package:jmap_dart_client/jmap/core/response/response_object.dart';

/// SetError type reported by `EmailSubmission/set` when the envelope carries at
/// least one address the server cannot send to.
const _invalidRecipientsErrorType = 'invalidRecipients';

extension ResponseObjectExtension on ResponseObject {
  /// Collects the addresses listed by the `invalidRecipients` SetErrors of the
  /// `notCreated` map of the method response identified by [methodCallId].
  ///
  /// The `invalidRecipients` String[] property mandated by RFC 8621 is carried
  /// by the SetError itself, and `SetError.fromJson` drops it, so it is read
  /// back from the raw arguments of the response.
  List<String> parseInvalidRecipients(MethodCallId methodCallId) {
    final arguments = methodResponses
        .firstWhereOrNull(
          (invocation) => invocation.methodCallId == methodCallId,
        )
        ?.arguments
        .value;
    if (arguments is! Map<String, dynamic>) return const [];

    final notCreated = arguments['notCreated'];
    if (notCreated is! Map<String, dynamic>) return const [];

    return notCreated.values
        .whereType<Map<String, dynamic>>()
        .where((setError) => setError['type'] == _invalidRecipientsErrorType)
        .map((setError) => setError[_invalidRecipientsErrorType])
        .whereType<List>()
        .expand((recipients) => recipients.whereType<String>())
        .toSet()
        .toList();
  }
}
