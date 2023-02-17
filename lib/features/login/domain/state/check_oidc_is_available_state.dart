import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:model/oidc/response/oidc_response.dart';

class CheckOIDCIsAvailableLoading extends LoadingState {

  CheckOIDCIsAvailableLoading();

  @override
  List<Object> get props => [];
}

class CheckOIDCIsAvailableSuccess extends UIState {
  final OIDCResponse oidcResponse;

  CheckOIDCIsAvailableSuccess(this.oidcResponse);

  @override
  List<Object> get props => [oidcResponse];
}

class CheckOIDCIsAvailableFailure extends FeatureFailure {
  final dynamic exception;

  CheckOIDCIsAvailableFailure(this.exception);

  @override
  List<Object?> get props => [exception];
}