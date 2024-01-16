import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:model/account/personal_account.dart';

class DestroyFirebaseRegistrationLoading extends LoadingState {}

class DestroyFirebaseRegistrationSuccess extends UIState {

  final PersonalAccount currentAccount;

  DestroyFirebaseRegistrationSuccess(this.currentAccount);

  @override
  List<Object?> get props => [currentAccount];
}

class DestroyFirebaseRegistrationFailure extends FeatureFailure {
  final PersonalAccount currentAccount;

  DestroyFirebaseRegistrationFailure({dynamic exception, required this.currentAccount}) : super(exception: exception);

  @override
  List<Object?> get props => [...super.props, currentAccount];
}