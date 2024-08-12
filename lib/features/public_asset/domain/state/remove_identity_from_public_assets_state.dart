import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:jmap_dart_client/jmap/identities/identity.dart';

class RemovingIdentityFromPublicAssetsState extends LoadingState {}

class RemoveIdentityFromPublicAssetsSuccessState extends UIState {
  RemoveIdentityFromPublicAssetsSuccessState({required this.identityId});

  final IdentityId identityId;

  @override
  List<Object?> get props => [identityId];
}

class RemoveIdentityFromPublicAssetsFailureState extends FeatureFailure {
  RemoveIdentityFromPublicAssetsFailureState({super.exception, required this.identityId});

  final IdentityId identityId;

  @override
  List<Object?> get props => [...super.props, identityId];
}

class NotFoundAnyPublicAssetsFailureState extends FeatureFailure {
  NotFoundAnyPublicAssetsFailureState({super.exception, required this.identityId});

  final IdentityId identityId;

  @override
  List<Object?> get props => [...super.props, identityId];
}