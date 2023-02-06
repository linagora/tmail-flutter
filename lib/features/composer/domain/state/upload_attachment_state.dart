
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:tmail_ui_user/features/upload/domain/model/upload_attachment.dart';

class UploadAttachmentSuccess extends UIState {

  final UploadAttachment uploadAttachment;
  final bool isInline;

  UploadAttachmentSuccess(this.uploadAttachment, {this.isInline = false});

  @override
  List<Object?> get props => [uploadAttachment, isInline];
}

class UploadAttachmentFailure extends FeatureFailure {
  final dynamic exception;
  final bool isInline;

  UploadAttachmentFailure(this.exception, {this.isInline = false});

  @override
  List<Object> get props => [exception, isInline];
}