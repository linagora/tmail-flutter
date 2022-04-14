import 'package:core/core.dart';
import 'package:model/model.dart';

class GetEmailContentSuccess extends UIState {
  final List<EmailContent> emailContents;
  final List<EmailContent> emailContentsDisplayed;
  final List<Attachment> attachments;

  GetEmailContentSuccess(this.emailContents, this.emailContentsDisplayed, this.attachments);

  @override
  List<Object?> get props => [emailContents, emailContentsDisplayed, attachments];
}

class GetEmailContentFailure extends FeatureFailure {
  final exception;

  GetEmailContentFailure(this.exception);

  @override
  List<Object> get props => [exception];
}