import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:model/oidc/token_oidc.dart';

class SignInSaasLoading extends LoadingState {}

class SignInSaasSuccess extends Success {
  final TokenOIDC tokenOIDC;

  SignInSaasSuccess(this.tokenOIDC);

  @override
  List<Object> get props => [tokenOIDC];
}

class SignInSaasFailure extends FeatureFailure {
  SignInSaasFailure(dynamic exception) : super(exception: exception);
}
