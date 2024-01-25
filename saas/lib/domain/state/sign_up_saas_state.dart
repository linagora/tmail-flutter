import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:model/oidc/token_oidc.dart';

class SignUpSaasLoading extends LoadingState {}

class SignUpSaasSuccess extends Success {
  final TokenOIDC tokenOIDC;

  SignUpSaasSuccess(this.tokenOIDC);

  @override
  List<Object> get props => [tokenOIDC];
}

class SignUpSaasFailure extends FeatureFailure {
  SignUpSaasFailure(dynamic exception) : super(exception: exception);
}
