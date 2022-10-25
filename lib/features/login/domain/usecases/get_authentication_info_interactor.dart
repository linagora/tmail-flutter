import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/utils/app_logger.dart';
import 'package:dartz/dartz.dart';
import 'package:tmail_ui_user/features/login/domain/repository/authentication_oidc_repository.dart';
import 'package:tmail_ui_user/features/login/domain/state/get_authentication_info_state.dart';

class GetAuthenticationInfoInteractor {
  final AuthenticationOIDCRepository _oidcRepository;

  GetAuthenticationInfoInteractor(this._oidcRepository);

  Stream<Either<Failure, Success>> execute() async* {
    try {
      yield Right<Failure, Success>(GetAuthenticationInfoLoading());
      final result = await _oidcRepository.getAuthenticationInfo();
      log('GetAuthenticationInfoInteractor::execute(): result: $result');
      if (result?.isNotEmpty == true) {
        yield Right<Failure, Success>(GetAuthenticationInfoSuccess());
      } else {
        yield Left<Failure, Success>(GetAuthenticationInfoFailure(null));
      }
    } catch (e) {
      log('GetAuthenticationInfoInteractor::execute(): ERROR: $e');
      yield Left<Failure, Success>(GetAuthenticationInfoFailure(e));
    }
  }
}