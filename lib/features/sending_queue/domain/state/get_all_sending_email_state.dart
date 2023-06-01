
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:tmail_ui_user/features/composer/domain/model/sending_email.dart';

class GetAllSendingEmailLoading extends UIState {}

class GetAllSendingEmailSuccess extends UIState {

  final List<SendingEmail> sendingEmails;

  GetAllSendingEmailSuccess(this.sendingEmails);

  @override
  List<Object?> get props => [sendingEmails];
}

class GetAllSendingEmailFailure extends FeatureFailure {

  GetAllSendingEmailFailure(dynamic exception) : super(exception: exception);

  @override
  List<Object?> get props => [exception];
}