import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:model/account/personal_account.dart';

class LogoutCurrentAccountBasicAuthLoading extends LoadingState {}

class LogoutCurrentAccountBasicAuthSuccess extends UIState {
  final PersonalAccount deletedAccount;

  LogoutCurrentAccountBasicAuthSuccess(this.deletedAccount);

  @override
  List<Object?> get props => [deletedAccount];
}

class LogoutCurrentAccountBasicAuthFailure extends FeatureFailure {

  final PersonalAccount deletedAccount;

  LogoutCurrentAccountBasicAuthFailure({dynamic exception, required this.deletedAccount}) : super(exception: exception);

  @override
  List<Object?> get props => [...super.props, deletedAccount];
}
