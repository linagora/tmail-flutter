import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:model/email/attachment.dart';

class GetEmailContentLoading extends LoadingState {}

class GetEmailContentSuccess extends UIState {
  final String emailContent;
  final String emailContentDisplayed;
  final List<Attachment> attachments;
  final Email? emailCurrent;

  GetEmailContentSuccess({
    required this.emailContent,
    required this.emailContentDisplayed,
    required this.attachments,
    required this.emailCurrent
  });

  @override
  List<Object?> get props => [
    emailContent,
    emailContentDisplayed,
    attachments,
    emailCurrent
  ];
}

class GetEmailContentFromCacheSuccess extends UIState {
  final String emailContent;
  final List<Attachment> attachments;
  final Email? emailCurrent;

  GetEmailContentFromCacheSuccess({
    required this.emailContent,
    required this.attachments,
    this.emailCurrent
  });

  @override
  List<Object?> get props => [
    emailContent,
    attachments,
    emailCurrent,
  ];
}

class GetEmailContentFailure extends FeatureFailure {

  GetEmailContentFailure(dynamic exception) : super(exception: exception);

  @override
  List<Object?> get props => [exception];
}