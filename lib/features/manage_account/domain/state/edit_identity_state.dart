import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:jmap_dart_client/jmap/identities/identity.dart';

class EditIdentityLoading extends UIState {}

class EditIdentitySuccess extends UIState {
  final IdentityId identityId;

  EditIdentitySuccess(this.identityId);

  @override
  List<Object?> get props => [identityId];
}

class EditIdentityFailure extends FeatureFailure {

  EditIdentityFailure(dynamic exception) : super(exception: exception);
}