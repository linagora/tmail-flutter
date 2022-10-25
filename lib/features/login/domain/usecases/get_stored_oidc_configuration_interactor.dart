import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/utils/app_logger.dart';
import 'package:dartz/dartz.dart';
import 'package:tmail_ui_user/features/login/domain/repository/authentication_oidc_repository.dart';
import 'package:tmail_ui_user/features/login/domain/state/get_stored_oidc_configuration_state.dart';

class GetStoredOidcConfigurationInteractor {
  final AuthenticationOIDCRepository _authenticationOIDCRepository;

  GetStoredOidcConfigurationInteractor(this._authenticationOIDCRepository);

  Stream<Either<Failure, Success>> execute() async* {
    try {
      yield Right(GetStoredOidcConfigurationLoading());
      final config = await _authenticationOIDCRepository.getStoredOidcConfiguration();
      yield Right(GetStoredOidcConfigurationSuccess(config));
    } catch (e) {
      log('GetStoredOidcConfigurationInteractor::execute(): $e');
      yield Left(GetStoredOidcConfigurationFailure(e));
    }
  }
}