import 'package:core/core.dart';
import 'package:jmap_dart_client/jmap/identities/identity.dart';

class CreateNewDefaultIdentityLoading extends UIState {}

class CreateNewDefaultIdentitySuccess extends UIState {

  final Identity newIdentity;

  CreateNewDefaultIdentitySuccess(this.newIdentity);

  @override
  List<Object?> get props => [newIdentity];
}

class CreateNewDefaultIdentityFailure extends FeatureFailure {

  CreateNewDefaultIdentityFailure(dynamic exception) : super(exception: exception);
}