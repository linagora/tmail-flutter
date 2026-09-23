import 'package:collection/collection.dart';
import 'package:jmap_dart_client/jmap/core/request/request_invocation.dart';
import 'package:jmap_dart_client/jmap/core/response/response_object.dart';

/// `type` of the SetError reported by `EmailSubmission/set` when the envelope
/// carries at least one address the server cannot send to.
const _invalidRecipientsErrorType = 'invalidRecipients';

/// String[] property RFC 8621 mandates on that SetError, listing the rejected
/// addresses. Spelled like the error type, but a separate part of the shape.
const _invalidRecipientsProperty = 'invalidRecipients';

const _notCreatedProperty = 'notCreated';
const _setErrorTypeProperty = 'type';

extension EmailSubmissionResponseExtension on ResponseObject {
  /// Addresses listed by the `invalidRecipients` SetErrors in the `notCreated`
  /// map of the method response identified by [methodCallId].
  ///
  /// `SetError.fromJson` drops the property, so it is read back from the raw
  /// arguments. An empty result means the response does not report it, and the
  /// caller falls back to the generic failure path.
  Set<String> parseInvalidRecipients(MethodCallId methodCallId) {
    final notCreated = _rawArgumentsOf(methodCallId)?[_notCreatedProperty];
    if (notCreated is! Map<String, dynamic>) return const {};

    return notCreated.values
        .whereType<Map<String, dynamic>>()
        .where((setError) =>
            setError[_setErrorTypeProperty] == _invalidRecipientsErrorType)
        .map((setError) => setError[_invalidRecipientsProperty])
        .whereType<List>()
        .expand((addresses) => addresses.whereType<String>())
        .toSet();
  }

  /// Undeserialized arguments of the method response [methodCallId], or null
  /// when there is no such response or its arguments are not a JSON object.
  Map<String, dynamic>? _rawArgumentsOf(MethodCallId methodCallId) {
    final arguments = methodResponses
        .firstWhereOrNull(
          (invocation) => invocation.methodCallId == methodCallId,
        )
        ?.arguments
        .value;
    return arguments is Map<String, dynamic> ? arguments : null;
  }
}
