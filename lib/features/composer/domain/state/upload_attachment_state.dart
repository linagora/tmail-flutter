import 'package:core/core.dart';
import 'package:model/model.dart';

class UploadAttachmentLoadingState extends UIState {
  UploadAttachmentLoadingState();

  @override
  List<Object?> get props => [];
}

class UploadAttachmentSuccess extends UIState {
  final Attachment attachment;

  UploadAttachmentSuccess(this.attachment);

  @override
  List<Object?> get props => [attachment];
}

class UploadAttachmentFailure extends FeatureFailure {
  final exception;

  UploadAttachmentFailure(this.exception);

  @override
  List<Object> get props => [exception];
}