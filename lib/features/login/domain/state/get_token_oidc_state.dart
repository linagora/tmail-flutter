import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:model/account/personal_account.dart';

class GetTokenOIDCLoading extends LoadingState {}

class GetTokenOIDCSuccess extends UIState {

  final PersonalAccount personalAccount;

  GetTokenOIDCSuccess(this.personalAccount);

  @override
  List<Object> get props => [personalAccount];
}

class GetTokenOIDCFailure extends FeatureFailure {

  GetTokenOIDCFailure(dynamic exception) : super(exception: exception);
}