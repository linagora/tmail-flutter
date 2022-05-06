import 'package:core/core.dart';
import 'package:jmap_dart_client/jmap/identities/identity.dart';

class EditIdentitySuccess extends UIState {

  final Identity newIdentity;

  EditIdentitySuccess(this.newIdentity);

  @override
  List<Object?> get props => [newIdentity];
}

class EditIdentityFailure extends FeatureFailure {
  final dynamic exception;

  EditIdentityFailure(this.exception);

  @override
  List<Object> get props => [exception];
}