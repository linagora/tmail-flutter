import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:model/email/attachment.dart';

class UpdatingTemplateEmail extends LoadingState {}

class UpdateTemplateEmailSuccess extends UIState {
  final EmailId emailId;
  final List<Attachment> attachments;
  final List<Attachment> htmlBodyAttachments;

  UpdateTemplateEmailSuccess({
    required this.emailId,
    required this.attachments,
    this.htmlBodyAttachments = const [],
  });

  @override
  List<Object?> get props => [emailId, attachments, htmlBodyAttachments, ...super.props];
}

class UpdateTemplateEmailFailure extends FeatureFailure {
  UpdateTemplateEmailFailure({super.exception});
}