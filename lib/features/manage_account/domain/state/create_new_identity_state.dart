import 'package:core/core.dart';
import 'package:jmap_dart_client/jmap/identities/identity.dart';
import 'package:tmail_ui_user/features/public_asset/domain/model/public_assets_in_identity_arguments.dart';

class CreateNewIdentityLoading extends UIState {}

class CreateNewIdentitySuccess extends UIState {

  final Identity newIdentity;
  final PublicAssetsInIdentityArguments? publicAssetsInIdentityArguments;

  CreateNewIdentitySuccess(
    this.newIdentity,
    {this.publicAssetsInIdentityArguments});

  @override
  List<Object?> get props => [newIdentity, publicAssetsInIdentityArguments];
}

class CreateNewIdentityFailure extends FeatureFailure {

  CreateNewIdentityFailure(dynamic exception) : super(exception: exception);
}