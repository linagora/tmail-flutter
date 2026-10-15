import 'package:jmap_dart_client/jmap/core/error/error_type.dart';
import 'package:jmap_dart_client/jmap/core/error/set_error.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:tmail_ui_user/features/composer/domain/exceptions/set_method_exception.dart';

/// The domain awaits mail DNS validation, so the account cannot send yet.
/// Thrown by the pre-send check or for a `forbiddenToSend` SetError.
class ForbiddenToSendException extends SetMethodException {
  /// `type` of the SetError `EmailSubmission/set` reports for such an account.
  static final ErrorType errorType = ErrorType('forbiddenToSend');

  /// Created by Email/set before the refusal; deleted so it leaves Outbox.
  final EmailId? createdEmailId;

  ForbiddenToSendException({
    Map<Id, SetError> mapErrors = const {},
    this.createdEmailId,
  }) : super(mapErrors);

  @override
  String get exceptionName => 'ForbiddenToSendException';

  @override
  List<Object?> get props => [...super.props, createdEmailId];
}
