import 'package:core/core.dart';
import 'package:model/email/email_content.dart';

class GetEmailContentSuccess extends UIState {
  final EmailContent? emailContent;

  GetEmailContentSuccess(this.emailContent);

  @override
  List<Object?> get props => [emailContent];
}

class GetEmailContentFailure extends FeatureFailure {
  final exception;

  GetEmailContentFailure(this.exception);

  @override
  List<Object> get props => [exception];
}