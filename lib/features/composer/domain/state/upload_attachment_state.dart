
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
  final bool isInline;

  UploadAttachmentFailure(dynamic exception, {this.isInline = false}) : super(exception: exception);

  @override
  List<Object?> get props => [isInline, ...super.props];
}