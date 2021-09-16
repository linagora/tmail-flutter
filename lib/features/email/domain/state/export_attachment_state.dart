import 'package:core/core.dart';

class ExportAttachmentSuccess extends UIState {
  final String filePath;

  ExportAttachmentSuccess(this.filePath);

  @override
  List<Object> get props => [filePath];
}

class ExportAttachmentFailure extends FeatureFailure {
  final exception;

  ExportAttachmentFailure(this.exception);

  @override
  List<Object> get props => [exception];
}