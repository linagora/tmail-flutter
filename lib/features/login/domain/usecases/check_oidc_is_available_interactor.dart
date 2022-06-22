import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/features/login/domain/repository/authentication_oidc_repository.dart';
import 'package:tmail_ui_user/features/login/domain/state/check_oidc_is_available_state.dart';

class CheckOIDCIsAvailableInteractor {
  final AuthenticationOIDCRepository _oidcRepository;

  CheckOIDCIsAvailableInteractor(this._oidcRepository);

  Future<Either<Failure, Success>> execute(OIDCRequest oidcRequest) async {
    try {
      final result = await _oidcRepository.checkOIDCIsAvailable(oidcRequest);
      log('CheckOIDCIsAvailableInteractor::execute(): result: $result');
      return Left<Failure, Success>(CheckOIDCIsAvailableFailure('dddd'));
    } catch (e) {
      log('CheckOIDCIsAvailableInteractor::execute(): ERROR: $e');
      return Left<Failure, Success>(CheckOIDCIsAvailableFailure(e));
    }
  }
}