
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:model/account/personal_account.dart';

class LogoutCurrentAccountOidcLoading extends LoadingState {}

class LogoutCurrentAccountOidcSuccess extends UIState {
  final PersonalAccount deletedAccount;

  LogoutCurrentAccountOidcSuccess(this.deletedAccount);

  @override
  List<Object?> get props => [deletedAccount];
}

class LogoutCurrentAccountOidcFailure extends FeatureFailure {

  final PersonalAccount deletedAccount;

  LogoutCurrentAccountOidcFailure({dynamic exception, required this.deletedAccount}) : super(exception: exception);

  @override
  List<Object?> get props => [...super.props, deletedAccount];
}