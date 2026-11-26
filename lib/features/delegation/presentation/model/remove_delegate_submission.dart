import 'package:tmail_ui_user/features/delegation/domain/model/remove_delegate_result.dart';

/// What a tap on Remove access led to.
sealed class RemoveDelegateSubmission {
  const RemoveDelegateSubmission();
}

/// A repeat tap while the request runs.
class RemoveDelegateIgnored extends RemoveDelegateSubmission {
  const RemoveDelegateIgnored();
}

/// The request failed, so its outcome on the server is unknown.
class RemoveDelegateFailed extends RemoveDelegateSubmission {
  /// The urgent handler already showed the error, so the caller shows nothing more.
  final bool wasRoutedAsUrgent;

  const RemoveDelegateFailed({this.wasRoutedAsUrgent = false});
}

class RemoveDelegateSucceeded extends RemoveDelegateSubmission {
  final RemoveDelegateResult result;

  const RemoveDelegateSucceeded(this.result);
}
