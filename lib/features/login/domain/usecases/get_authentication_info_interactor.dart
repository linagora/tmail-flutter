import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/utils/app_logger.dart';
import 'package:dartz/dartz.dart';
import 'package:tmail_ui_user/features/login/domain/repository/authentication_oidc_repository.dart';
import 'package:tmail_ui_user/features/login/domain/state/get_authentication_info_state.dart';

class GetAuthenticationInfoInteractor {
  final AuthenticationOIDCRepository _oidcRepository;

  GetAuthenticationInfoInteractor(this._oidcRepository);

  Future<Either<Failure, Success>> execute() async {
    try {
      final result = await _oidcRepository.getAuthenticationInfo();
      log('GetAuthenticationInfoInteractor::execute(): result: $result');
      if (result?.isNotEmpty == true) {
        return Right<Failure, Success>(GetAuthenticationInfoSuccess());
      } else {
        return Left<Failure, Success>(GetAuthenticationInfoFailure(null));
      }
    } catch (e) {
      log('GetAuthenticationInfoInteractor::execute(): ERROR: $e');
      return Left<Failure, Success>(GetAuthenticationInfoFailure(e));
    }
  }
}