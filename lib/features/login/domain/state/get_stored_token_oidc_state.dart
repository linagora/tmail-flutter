import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:jmap_dart_client/jmap/push/state_change.dart';
import 'package:model/account/personal_account.dart';
import 'package:model/oidc/oidc_configuration.dart';
import 'package:model/oidc/token_oidc.dart';

class GetStoredTokenOidcSuccess extends UIState {
  final Uri baseUrl;
  final TokenOIDC tokenOidc;
  final OIDCConfiguration oidcConfiguration;
  final PersonalAccount personalAccount;
  final StateChange? stateChange;

  GetStoredTokenOidcSuccess(
    this.baseUrl,
    this.tokenOidc,
    this.oidcConfiguration,
    this.personalAccount,
    {this.stateChange}
  );

  @override
  List<Object?> get props => [
    baseUrl,
    tokenOidc,
    oidcConfiguration,
    personalAccount,
    stateChange];
}

class GetStoredTokenOidcFailure extends FeatureFailure {

  GetStoredTokenOidcFailure(dynamic exception) : super(exception: exception);
}