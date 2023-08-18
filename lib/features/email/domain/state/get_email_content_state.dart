import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:model/email/attachment.dart';

class GetEmailContentLoading extends LoadingState {}

class GetEmailContentSuccess extends UIState {
  final String htmlEmailContent;
  final List<Attachment> attachments;
  final Email? emailCurrent;

  GetEmailContentSuccess({
    required this.htmlEmailContent,
    required this.attachments,
    this.emailCurrent
  });

  @override
  List<Object?> get props => [
    htmlEmailContent,
    attachments,
    emailCurrent
  ];
}

class GetEmailContentFromCacheSuccess extends UIState {
  final String htmlEmailContent;
  final List<Attachment> attachments;
  final Email? emailCurrent;

  GetEmailContentFromCacheSuccess({
    required this.htmlEmailContent,
    required this.attachments,
    this.emailCurrent
  });

  @override
  List<Object?> get props => [
    htmlEmailContent,
    attachments,
    emailCurrent,
  ];
}

class GetEmailContentFailure extends FeatureFailure {

  GetEmailContentFailure(dynamic exception) : super(exception: exception);
}