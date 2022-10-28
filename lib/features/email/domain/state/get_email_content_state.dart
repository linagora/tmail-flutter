import 'package:core/core.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:model/model.dart';

class GetEmailContentLoading extends LoadingState {}

class GetEmailContentSuccess extends UIState {
  final List<EmailContent> emailContents;
  final List<EmailContent> emailContentsDisplayed;
  final List<Attachment> attachments;
  final Email? emailCurrent;

  GetEmailContentSuccess(
    this.emailContents,
    this.emailContentsDisplayed,
    this.attachments,
    this.emailCurrent
  );

  @override
  List<Object?> get props => [
    emailContents,
    emailContentsDisplayed,
    attachments,
    emailCurrent
  ];
}

class GetEmailContentFailure extends FeatureFailure {
  final dynamic exception;

  GetEmailContentFailure(this.exception);

  @override
  List<Object> get props => [exception];
}