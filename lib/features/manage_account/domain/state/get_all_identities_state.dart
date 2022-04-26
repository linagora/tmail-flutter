import 'package:core/core.dart';
import 'package:jmap_dart_client/jmap/core/state.dart';
import 'package:jmap_dart_client/jmap/identities/identity.dart';

class GetAllIdentitiesSuccess extends UIState {
  final List<Identity>? identities;
  final State? state;

  GetAllIdentitiesSuccess(this.identities, this.state);

  @override
  List<Object?> get props => [identities, state];
}

class GetAllIdentitiesFailure extends FeatureFailure {
  final dynamic exception;

  GetAllIdentitiesFailure(this.exception);

  @override
  List<Object> get props => [exception];
}