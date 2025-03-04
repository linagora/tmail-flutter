import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/utils/app_logger.dart';
import 'package:dartz/dartz.dart';
import 'package:model/oidc/response/oidc_response.dart';
import 'package:tmail_ui_user/features/login/domain/model/base_url_oidc_response.dart';
import 'package:tmail_ui_user/features/login/domain/repository/authentication_oidc_repository.dart';
import 'package:tmail_ui_user/features/login/domain/state/get_oidc_configuration_state.dart';

class GetOIDCConfigurationInteractor {
  final AuthenticationOIDCRepository _oidcRepository;

  GetOIDCConfigurationInteractor(this._oidcRepository);

  Stream<Either<Failure, Success>> execute(OIDCResponse oidcResponse) async* {
    try {
      yield Right<Failure, Success>(GetOIDCConfigurationLoading());
      final oidcConfiguration = await _oidcRepository.getOIDCConfiguration(oidcResponse);
      await _oidcRepository.persistOidcConfiguration(oidcConfiguration);
      yield Right<Failure, Success>(GetOIDCConfigurationSuccess(oidcConfiguration));
    } catch (e) {
      logError('$runtimeType::execute():oidcResponse = ${oidcResponse.runtimeType} | Exception = $e');
      if (oidcResponse is BaseUrlOidcResponse) {
        yield Left<Failure, Success>(GetOIDCConfigurationFromBaseUrlFailure(e));
      } else {
        yield Left<Failure, Success>(GetOIDCConfigurationFailure(e));
      }
    }
  }
}