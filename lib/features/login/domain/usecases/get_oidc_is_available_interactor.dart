import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:model/oidc/request/oidc_request.dart';
import 'package:tmail_ui_user/features/login/domain/repository/authentication_oidc_repository.dart';
import 'package:tmail_ui_user/features/login/domain/state/get_oidc_is_available_state.dart';

class GetOIDCIsAvailableInteractor {
  final AuthenticationOIDCRepository _oidcRepository;

  GetOIDCIsAvailableInteractor(this._oidcRepository);

  Stream<Either<Failure, Success>> execute(OIDCRequest oidcRequest) async* {
    try {
      yield Right<Failure, Success>(GetOIDCIsAvailableLoading());
      final result = await _oidcRepository.checkOIDCIsAvailable(oidcRequest);
      yield Right<Failure, Success>(GetOIDCIsAvailableSuccess(result));
    } catch (e) {
      yield Left<Failure, Success>(GetOIDCIsAvailableFailure(e));
    }
  }
}