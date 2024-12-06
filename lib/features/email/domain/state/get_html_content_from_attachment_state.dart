import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';

class GettingHtmlContentFromAttachment extends LoadingState {}

class GetHtmlContentFromAttachmentSuccess extends UIState {
  GetHtmlContentFromAttachmentSuccess({required this.sanitizedHtmlContent});

  final String sanitizedHtmlContent;

  @override
  List<Object?> get props => [sanitizedHtmlContent];
}

class GetHtmlContentFromAttachmentFailure extends FeatureFailure {
  GetHtmlContentFromAttachmentFailure({super.exception});
}