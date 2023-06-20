import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:model/email/attachment.dart';
import 'package:model/email/email_content.dart';

class GetEmailContentLoading extends LoadingState {}

class GetEmailContentSuccess extends UIState {
  final String emailContents;
  final List<EmailContent> emailContentsDisplayed;
  final List<Attachment> attachments;
  final Email? emailCurrent;

  GetEmailContentSuccess({
    required this.emailContents,
    required this.emailContentsDisplayed,
    required this.attachments,
    required this.emailCurrent
  });

  @override
  List<Object?> get props => [
    emailContents,
    emailContentsDisplayed,
    attachments,
    emailCurrent
  ];
}

class GetEmailContentFromCacheSuccess extends UIState {
  final String emailContentString;
  final List<Attachment> attachments;
  final Email? emailCurrent;

  GetEmailContentFromCacheSuccess({
    required this.emailContentString,
    required this.attachments,
    this.emailCurrent
  });

  @override
  List<Object?> get props => [
    emailContentString,
    attachments,
    emailCurrent,
  ];
}

class GetEmailContentFailure extends FeatureFailure {

  GetEmailContentFailure(dynamic exception) : super(exception: exception);

  @override
  List<Object?> get props => [exception];
}