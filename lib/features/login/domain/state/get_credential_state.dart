import 'package:core/core.dart';
import 'package:core/presentation/state/failure.dart';
import 'package:model/account/password.dart';
import 'package:model/account/user_name.dart';

class GetCredentialViewState extends ViewState {
  final Uri baseUrl;
  final UserName userName;
  final Password password;

  GetCredentialViewState(this.baseUrl, this.userName, this.password);

  @override
  List<Object> get props => [baseUrl, this.userName, this.password];
}

class GetCredentialFailure extends FeatureFailure {
  final exception;

  GetCredentialFailure(this.exception);

  @override
  List<Object> get props => [exception];
}