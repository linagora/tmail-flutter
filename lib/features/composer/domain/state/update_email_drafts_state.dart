import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:model/email/attachment.dart';

class UpdatingEmailDrafts extends LoadingState {}

class UpdateEmailDraftsSuccess extends UIState {

  final EmailId emailId;
  final List<Attachment> attachments;
  final List<Attachment> htmlBodyAttachments;

  UpdateEmailDraftsSuccess({
    required this.emailId,
    required this.attachments,
    this.htmlBodyAttachments = const [],
  });

  @override
  List<Object?> get props => [emailId, attachments, htmlBodyAttachments, ...super.props];
}

class UpdateEmailDraftsFailure extends FeatureFailure {

  UpdateEmailDraftsFailure(dynamic exception) : super(exception: exception);
}
