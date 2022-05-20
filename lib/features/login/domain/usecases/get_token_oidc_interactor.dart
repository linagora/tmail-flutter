
import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:tmail_ui_user/features/login/domain/repository/authentication_oidc_repository.dart';
import 'package:tmail_ui_user/features/login/domain/state/get_token_oidc_state.dart';

class GetTokenOIDCInteractor {

  final AuthenticationOIDCRepository authenticationOIDCRepository;

  GetTokenOIDCInteractor(this.authenticationOIDCRepository);

  Future<Either<Failure, Success>> execute(String clientId, String redirectUrl,
      String discoveryUrl, List<String> scopes) async {
    try {
      final tokenOIDC = await authenticationOIDCRepository.getTokenOIDC(clientId, redirectUrl, discoveryUrl, scopes);
      return Right<Failure, Success>(GetTokenOIDCSuccess(tokenOIDC));
    } catch (e) {
      return Left<Failure, Success>(GetTokenOIDCFailure(e));
    }
  }
}