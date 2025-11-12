import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:model/oidc/oidc_configuration.dart';
import 'package:tmail_ui_user/features/login/data/network/oidc_error.dart';
import 'package:tmail_ui_user/features/login/domain/repository/authentication_oidc_repository.dart';
import 'package:tmail_ui_user/features/login/domain/state/get_oidc_user_info_state.dart';

class GetOidcUserInfoInteractor {
  final AuthenticationOIDCRepository _authenticationOIDCRepository;

  GetOidcUserInfoInteractor(this._authenticationOIDCRepository);

  Stream<Either<Failure, Success>> execute(OIDCConfiguration config) async* {
    try {
      yield Right<Failure, Success>(GettingOidcUserInfo());

      final oidcDiscoveryResponse =
          await _authenticationOIDCRepository.discoverOIDC(config);

      final userInfoEndpoint = oidcDiscoveryResponse.userInfoEndpoint;

      if (userInfoEndpoint != null) {
        final oidcUserInfo =
            await _authenticationOIDCRepository.fetchUserInfo(userInfoEndpoint);

        yield Right<Failure, Success>(GetOidcUserInfoSuccess(oidcUserInfo));
      } else {
        yield Left<Failure, Success>(
          GetOidcUserInfoFailure(NotFoundUserInfoEndpointException()),
        );
      }
    } catch (e) {
      yield Left<Failure, Success>(GetOidcUserInfoFailure(e));
    }
  }
}
