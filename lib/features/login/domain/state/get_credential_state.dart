import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:jmap_dart_client/jmap/push/state_change.dart';
import 'package:model/account/password.dart';
import 'package:model/account/personal_account.dart';

class GetCredentialViewState extends UIState {
  final Uri baseUrl;
  final UserName userName;
  final Password password;
  final PersonalAccount personalAccount;
  final StateChange? stateChange;

  GetCredentialViewState(
    this.baseUrl,
    this.userName,
    this.password,
    this.personalAccount,
    {this.stateChange});

  @override
  List<Object?> get props => [
    baseUrl,
    userName,
    password,
    personalAccount,
    stateChange];
}

class GetCredentialFailure extends FeatureFailure {

  GetCredentialFailure(dynamic exception) : super(exception: exception);
}