import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:tmail_ui_user/features/manage_account/domain/state/edit_identity_state.dart';

class EditDefaultIdentityLoading extends UIState {}

class EditDefaultIdentitySuccess extends EditIdentitySuccess {
  EditDefaultIdentitySuccess(
    super.identityId,
    {super.publicAssetsInIdentityArguments});
}

class EditDefaultIdentityFailure extends FeatureFailure {

  EditDefaultIdentityFailure(dynamic exception) : super(exception: exception);
}