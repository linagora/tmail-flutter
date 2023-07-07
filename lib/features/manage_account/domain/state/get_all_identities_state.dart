import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:jmap_dart_client/jmap/core/state.dart';
import 'package:jmap_dart_client/jmap/identities/identity.dart';

class GetAllIdentitiesLoading extends LoadingState {}

class GetAllIdentitiesSuccess extends UIState {
  final List<Identity>? identities;
  final State? state;

  GetAllIdentitiesSuccess(this.identities, this.state);

  @override
  List<Object?> get props => [identities, state];
}

class GetAllIdentitiesFailure extends FeatureFailure {

  GetAllIdentitiesFailure(dynamic exception) : super(exception: exception);
}