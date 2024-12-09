import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';

class GettingHtmlContentFromAttachment extends LoadingState {}

class GetHtmlContentFromAttachmentSuccess extends UIState {
  GetHtmlContentFromAttachmentSuccess({
    required this.sanitizedHtmlContent,
    required this.htmlAttachmentTitle,
  });

  final String sanitizedHtmlContent;
  final String htmlAttachmentTitle;

  @override
  List<Object?> get props => [sanitizedHtmlContent, htmlAttachmentTitle];
}

class GetHtmlContentFromAttachmentFailure extends FeatureFailure {
  GetHtmlContentFromAttachmentFailure({super.exception});
}