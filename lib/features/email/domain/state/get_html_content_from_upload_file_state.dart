import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:model/email/attachment.dart';

class GettingHtmlContentFromUploadFile extends LoadingState {}

class GetHtmlContentFromUploadFileSuccess extends UIState {
  GetHtmlContentFromUploadFileSuccess({
    required this.sanitizedHtmlContent,
    required this.htmlAttachmentTitle,
    required this.attachment,
  });

  final String sanitizedHtmlContent;
  final String htmlAttachmentTitle;
  final Attachment attachment;

  @override
  List<Object?> get props => [
    sanitizedHtmlContent,
    htmlAttachmentTitle,
    attachment,
  ];
}

class GetHtmlContentFromUploadFileFailure extends FeatureFailure {
  GetHtmlContentFromUploadFileFailure({super.exception});
}