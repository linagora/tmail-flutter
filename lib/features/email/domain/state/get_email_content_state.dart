import 'package:core/core.dart';
import 'package:model/model.dart';

class GetEmailContentSuccess extends UIState {
  final EmailContent emailContent;
  final List<Attachment> attachments;

  GetEmailContentSuccess(this.emailContent, this.attachments);

  @override
  List<Object?> get props => [emailContent, attachments];
}

class GetEmailContentFailure extends FeatureFailure {
  final exception;

  GetEmailContentFailure(this.exception);

  @override
  List<Object> get props => [exception];
}