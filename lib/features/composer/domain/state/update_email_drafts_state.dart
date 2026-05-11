import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';

class UpdatingEmailDrafts extends LoadingState {}

/// Represents successful update of an email draft.
/// Contains the email ID along with the old and new blob IDs
/// to track the attachment/content changes.
class UpdateEmailDraftsSuccess extends UIState {

  final EmailId emailId;
  /// The blob ID before the update
  final Id oldBlobId;
  /// The blob ID after the update
  final Id newBlobId;

  UpdateEmailDraftsSuccess({
    required this.emailId,
    required this.oldBlobId,
    required this.newBlobId,
  });

  @override
  List<Object?> get props => [emailId, oldBlobId, newBlobId, ...super.props];
}

class UpdateEmailDraftsFailure extends FeatureFailure {

  UpdateEmailDraftsFailure(dynamic exception) : super(exception: exception);
}