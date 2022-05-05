import 'package:core/core.dart';
import 'package:jmap_dart_client/jmap/identities/identity.dart';

class CreateNewIdentitySuccess extends UIState {

  final Identity newIdentity;

  CreateNewIdentitySuccess(this.newIdentity);

  @override
  List<Object?> get props => [newIdentity];
}

class CreateNewIdentityFailure extends FeatureFailure {
  final dynamic exception;

  CreateNewIdentityFailure(this.exception);

  @override
  List<Object> get props => [exception];
}