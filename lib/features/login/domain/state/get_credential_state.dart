import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:model/account/password.dart';

class GetCredentialViewState extends UIState {
  final Uri baseUrl;
  final UserName userName;
  final Password password;

  GetCredentialViewState(this.baseUrl, this.userName, this.password);

  @override
  List<Object> get props => [baseUrl, userName, password];
}

class GetCredentialFailure extends FeatureFailure {

  GetCredentialFailure(dynamic exception) : super(exception: exception);

  @override
  List<Object?> get props => [exception];
}