import 'package:core/core.dart';
import 'package:tmail_ui_user/features/manage_account/domain/state/edit_identity_state.dart';

class EditDefaultIdentityLoading extends UIState {}

class EditDefaultIdentitySuccess extends EditIdentitySuccess {

  EditDefaultIdentitySuccess();

  @override
  List<Object?> get props => [];
}

class EditDefaultIdentityFailure extends FeatureFailure {
  final dynamic exception;

  EditDefaultIdentityFailure(this.exception);

  @override
  List<Object> get props => [exception];
}