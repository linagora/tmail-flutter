import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:tmail_ui_user/features/login/domain/repository/authentication_oidc_repository.dart';
import 'package:tmail_ui_user/features/login/domain/state/get_oidc_configuration_state.dart';

class GetOIDCConfigurationInteractor {
  final AuthenticationOIDCRepository _oidcRepository;

  GetOIDCConfigurationInteractor(this._oidcRepository);

  Future<Either<Failure, Success>> execute(Uri baseUri) async {
    try {
      final oidcConfiguration = await _oidcRepository.getOIDCConfiguration(baseUri);
      log('GetOIDCConfigurationInteractor::execute(): oidcConfiguration: $oidcConfiguration');
      return Right<Failure, Success>(GetOIDCConfigurationSuccess(oidcConfiguration));
    } catch (e) {
      log('GetOIDCConfigurationInteractor::execute(): ERROR: $e');
      return Left<Failure, Success>(GetOIDCConfigurationFailure(e));
    }
  }
}