import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:model/account/personal_account.dart';

class LogoutCurrentAccountLoading extends LoadingState {}

class LogoutCurrentAccountFailure extends FeatureFailure {

  final PersonalAccount? deletedAccount;

  LogoutCurrentAccountFailure({dynamic exception, this.deletedAccount}) : super(exception: exception);

  @override
  List<Object?> get props => [...super.props, deletedAccount];
}
