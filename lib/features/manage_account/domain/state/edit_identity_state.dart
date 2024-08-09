import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:jmap_dart_client/jmap/identities/identity.dart';
import 'package:tmail_ui_user/features/public_asset/domain/model/public_assets_in_identity_arguments.dart';

class EditIdentityLoading extends UIState {}

class EditIdentitySuccess extends UIState {
  final IdentityId identityId;
  final PublicAssetsInIdentityArguments? publicAssetsInIdentityArguments;

  EditIdentitySuccess(
    this.identityId,
    {this.publicAssetsInIdentityArguments});

  @override
  List<Object?> get props => [identityId, publicAssetsInIdentityArguments];
}

class EditIdentityFailure extends FeatureFailure {

  EditIdentityFailure(dynamic exception) : super(exception: exception);
}