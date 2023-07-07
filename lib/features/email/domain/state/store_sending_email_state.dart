
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:tmail_ui_user/features/sending_queue/domain/model/sending_email.dart';

class StoreSendingEmailLoading extends UIState {}

class StoreSendingEmailSuccess extends UIState {

  final SendingEmail sendingEmail;

  StoreSendingEmailSuccess(this.sendingEmail);

  @override
  List<Object?> get props => [sendingEmail];
}

class StoreSendingEmailFailure extends FeatureFailure {
  StoreSendingEmailFailure(dynamic exception) : super(exception: exception);
}