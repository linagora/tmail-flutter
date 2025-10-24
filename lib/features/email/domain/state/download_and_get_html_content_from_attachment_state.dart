import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:model/email/attachment.dart';

class DownloadAndGettingHtmlContentFromAttachment extends LoadingState {
  DownloadAndGettingHtmlContentFromAttachment({required this.attachment});

  final Attachment attachment;

  @override
  List<Object?> get props => [attachment];
}

class DownloadAndGetHtmlContentFromAttachmentSuccess extends UIState {
  DownloadAndGetHtmlContentFromAttachmentSuccess({
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

class DownloadAndGetHtmlContentFromAttachmentFailure extends FeatureFailure {
  DownloadAndGetHtmlContentFromAttachmentFailure({
    super.exception,
    required this.attachment,
  });

  final Attachment attachment;

  @override
  List<Object?> get props => [attachment];
}