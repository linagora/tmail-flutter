import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:model/oidc/request/oidc_request.dart';
import 'package:tmail_ui_user/features/login/domain/repository/authentication_oidc_repository.dart';
import 'package:tmail_ui_user/features/login/domain/state/check_oidc_is_available_state.dart';

class CheckOIDCIsAvailableInteractor {
  final AuthenticationOIDCRepository _oidcRepository;

  CheckOIDCIsAvailableInteractor(this._oidcRepository);

  Stream<Either<Failure, Success>> execute(OIDCRequest oidcRequest) async* {
    try {
      yield Right<Failure, Success>(CheckOIDCIsAvailableLoading());
      final oidcResponse = await _oidcRepository.checkOIDCIsAvailable(oidcRequest);
      yield Right<Failure, Success>(CheckOIDCIsAvailableSuccess(oidcResponse, oidcRequest.baseUrl));
    } catch (e) {
      yield Left<Failure, Success>(CheckOIDCIsAvailableFailure(e));
    }
  }
}