import 'package:core/core.dart';
import 'package:model/model.dart';

class GetEmailContentSuccess extends UIState {
  final List<EmailContent> emailContents;
  final List<Attachment> attachments;

  GetEmailContentSuccess(this.emailContents, this.attachments);

  @override
  List<Object?> get props => [emailContents, attachments];
}

class GetEmailContentFailure extends FeatureFailure {
  final exception;

  GetEmailContentFailure(this.exception);

  @override
  List<Object> get props => [exception];
}