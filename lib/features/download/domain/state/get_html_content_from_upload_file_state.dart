import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:model/email/attachment.dart';

class GettingHtmlContentFromUploadFile extends LoadingState {}

class GetHtmlContentFromUploadFileSuccess extends UIState {
  GetHtmlContentFromUploadFileSuccess({
    required this.sanitizedHtmlContent,
    required this.htmlAttachmentTitle,
    required this.attachment,
    required this.accountId,
    required this.session,
  });

  final String sanitizedHtmlContent;
  final String htmlAttachmentTitle;
  final Attachment attachment;
  final AccountId? accountId;
  final Session? session;

  @override
  List<Object?> get props => [
    sanitizedHtmlContent,
    htmlAttachmentTitle,
    attachment,
    accountId,
    session,
  ];
}

class GetHtmlContentFromUploadFileFailure extends FeatureFailure {
  GetHtmlContentFromUploadFileFailure({super.exception});
}