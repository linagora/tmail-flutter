
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:tmail_ui_user/features/composer/domain/model/sending_email.dart';

class StoreSendingEmailLoading extends UIState {}

class StoreSendingEmailSuccess extends UIState {

  final SendingEmail sendingEmail;
  final bool isUpdateSendingEmail;

  StoreSendingEmailSuccess(this.sendingEmail, this.isUpdateSendingEmail);

  @override
  List<Object?> get props => [sendingEmail];
}

class StoreSendingEmailFailure extends FeatureFailure {
  StoreSendingEmailFailure(dynamic exception) : super(exception: exception);

  @override
  List<Object?> get props => [exception];
}