import 'package:core/core.dart';
import 'package:model/model.dart';

class GetEmailContentLoading extends UIState {

  GetEmailContentLoading();

  @override
  List<Object> get props => [];
}

class GetEmailContentSuccess extends UIState {
  final List<EmailContent> emailContents;
  final List<EmailContent> emailContentsDisplayed;
  final List<Attachment> attachments;
  final bool readReceiptRequested;

  GetEmailContentSuccess(
    this.emailContents,
    this.emailContentsDisplayed,
    this.attachments,
    this.readReceiptRequested
  );

  @override
  List<Object?> get props => [
    emailContents,
    emailContentsDisplayed,
    attachments,
    readReceiptRequested
  ];
}

class GetEmailContentFailure extends FeatureFailure {
  final dynamic exception;

  GetEmailContentFailure(this.exception);

  @override
  List<Object> get props => [exception];
}