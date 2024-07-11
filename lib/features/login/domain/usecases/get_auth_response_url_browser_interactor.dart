import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:tmail_ui_user/features/login/domain/repository/authentication_oidc_repository.dart';
import 'package:tmail_ui_user/features/login/domain/state/get_auth_response_url_browser_state.dart';

class GetAuthResponseUrlBrowserInteractor {
  final AuthenticationOIDCRepository _oidcRepository;

  GetAuthResponseUrlBrowserInteractor(this._oidcRepository);

  Stream<Either<Failure, Success>> execute() async* {
    try {
      yield Right<Failure, Success>(GetAuthResponseUrlBrowserLoading());
      final authResponseUrl = await _oidcRepository.getAuthResponseUrlBrowser();
      yield Right<Failure, Success>(GetAuthResponseUrlBrowserSuccess(authResponseUrl));
    } catch (e) {
      yield Left<Failure, Success>(GetAuthResponseUrlBrowserFailure(e));
    }
  }
}