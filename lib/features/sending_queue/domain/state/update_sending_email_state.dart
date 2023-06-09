
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:tmail_ui_user/features/sending_queue/domain/model/sending_email.dart';

class UpdateSendingEmailLoading extends UIState {}

class UpdateSendingEmailSuccess extends UIState {
  final SendingEmail newSendingEmail;

  UpdateSendingEmailSuccess(this.newSendingEmail);

  @override
  List<Object?> get props => [newSendingEmail];
}

class UpdateSendingEmailFailure extends FeatureFailure {

  UpdateSendingEmailFailure(dynamic exception) : super(exception: exception);

  @override
  List<Object?> get props => [exception];
}