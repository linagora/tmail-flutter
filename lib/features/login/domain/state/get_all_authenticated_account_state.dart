import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:model/account/personal_account.dart';

class GetAllAuthenticatedAccountSuccess extends UIState {
  final List<PersonalAccount> listAccount;

  GetAllAuthenticatedAccountSuccess(this.listAccount);

  @override
  List<Object> get props => [listAccount];
}

class GetAllAuthenticatedAccountFailure extends FeatureFailure {

  GetAllAuthenticatedAccountFailure(dynamic exception) : super(exception: exception);
}
