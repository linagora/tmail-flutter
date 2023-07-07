import 'package:core/core.dart';
import 'package:jmap_dart_client/jmap/identities/identity.dart';

class CreateNewIdentityLoading extends UIState {}

class CreateNewIdentitySuccess extends UIState {

  final Identity newIdentity;

  CreateNewIdentitySuccess(this.newIdentity);

  @override
  List<Object?> get props => [newIdentity];
}

class CreateNewIdentityFailure extends FeatureFailure {

  CreateNewIdentityFailure(dynamic exception) : super(exception: exception);
}