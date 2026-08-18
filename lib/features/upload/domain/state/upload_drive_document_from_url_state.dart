import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:model/email/attachment.dart';

class UploadDriveDocumentFromUrlSuccess extends UIState {

  final Attachment attachment;

  UploadDriveDocumentFromUrlSuccess(this.attachment);

  @override
  List<Object?> get props => [attachment];
}

class UploadDriveDocumentFromUrlFailure extends FeatureFailure {

  UploadDriveDocumentFromUrlFailure(dynamic exception) : super(exception: exception);
}

class UploadDriveDocumentFromUrlCancelled extends Failure {

  @override
  List<Object?> get props => [];
}
