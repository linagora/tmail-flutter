import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:model/email/attachment.dart';

class GettingHtmlContentFromAttachment extends LoadingState {
  GettingHtmlContentFromAttachment({required this.attachment});

  final Attachment attachment;

  @override
  List<Object?> get props => [attachment];
}

class GetHtmlContentFromAttachmentSuccess extends UIState {
  GetHtmlContentFromAttachmentSuccess({
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

class GetHtmlContentFromAttachmentFailure extends FeatureFailure {
  GetHtmlContentFromAttachmentFailure({super.exception, required this.attachment});

  final Attachment attachment;

  @override
  List<Object?> get props => [attachment];
}