
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:tmail_ui_user/features/upload/domain/model/upload_attachment.dart';

class UploadAttachmentSuccess extends UIState {

  final UploadAttachment uploadAttachment;
  final bool isInline;
  final bool fromFileShared;

  UploadAttachmentSuccess(
    this.uploadAttachment,
    {
      this.isInline = false,
      this.fromFileShared = false,
    }
  );

  @override
  List<Object?> get props => [
    uploadAttachment,
    isInline,
    fromFileShared,
  ];
}

class UploadAttachmentFailure extends FeatureFailure {
  final bool isInline;
  final bool fromFileShared;

  UploadAttachmentFailure(
    dynamic exception,
    {
      this.isInline = false,
      this.fromFileShared = false,
    }
  ) : super(exception: exception);

  @override
  List<Object?> get props => [
    isInline,
    fromFileShared,
    ...super.props
  ];
}