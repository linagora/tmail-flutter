import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:tmail_ui_user/features/manage_account/domain/state/edit_identity_state.dart';

class EditDefaultIdentityLoading extends LoadingState {
  final bool isSetAsDefault;

  EditDefaultIdentityLoading({this.isSetAsDefault = false});

  @override
  List<Object?> get props => [isSetAsDefault];
}

class EditDefaultIdentitySuccess extends EditIdentitySuccess {
  EditDefaultIdentitySuccess(
    super.identityId,
    {super.publicAssetsInIdentityArguments, super.isSetAsDefault = false});
}

class EditDefaultIdentityFailure extends FeatureFailure {

  EditDefaultIdentityFailure(dynamic exception) : super(exception: exception);
}