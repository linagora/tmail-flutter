import 'package:core/presentation/state/failure.dart';
import 'package:tmail_ui_user/features/thread/domain/state/get_all_email_state.dart';

class ReSyncThreadSuccess extends GetAllEmailSuccess {

  ReSyncThreadSuccess(
    emailList,
    currentEmailState
  ) : super(emailList: emailList, currentEmailState: currentEmailState);

  @override
  List<Object?> get props => [emailList, currentEmailState];
}

class ReSyncThreadFailure extends FeatureFailure {
  final dynamic exception;

  ReSyncThreadFailure(this.exception);

  @override
  List<Object?> get props => [exception];
}