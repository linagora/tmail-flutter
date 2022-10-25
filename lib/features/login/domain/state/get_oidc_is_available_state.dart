import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:model/oidc/response/oidc_response.dart';

class GetOIDCIsAvailableLoading extends LoadingState {

  GetOIDCIsAvailableLoading();

  @override
  List<Object> get props => [];
}

class GetOIDCIsAvailableSuccess extends UIState {
  final OIDCResponse oidcResponse;

  GetOIDCIsAvailableSuccess(this.oidcResponse);

  @override
  List<Object> get props => [oidcResponse];
}

class GetOIDCIsAvailableFailure extends FeatureFailure {
  final dynamic exception;

  GetOIDCIsAvailableFailure(this.exception);

  @override
  List<Object> get props => [exception];
}