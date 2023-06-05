
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:tmail_ui_user/features/composer/domain/model/sending_email.dart';

class UpdateSendingEmailLoading extends UIState {}

class UpdateSendingEmailSuccess extends UIState {

  final SendingEmail sendingEmail;

  UpdateSendingEmailSuccess(this.sendingEmail);

  @override
  List<Object?> get props => [sendingEmail];
}

class UpdateSendingEmailFailure extends FeatureFailure {
  UpdateSendingEmailFailure(dynamic exception) : super(exception: exception);

  @override
  List<Object?> get props => [exception];
}