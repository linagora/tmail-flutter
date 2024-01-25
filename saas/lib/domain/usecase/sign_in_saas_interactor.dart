import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:saas/domain/repository/saas_authentication_repository.dart';
import 'package:saas/domain/state/sign_in_saas_state.dart';

class SignInSaasInteractor {
  final SaasAuthenticationRepository _saasRepository;

  SignInSaasInteractor(this._saasRepository);

  Stream<Either<Failure, Success>> execute({
    required Uri registrationSiteUrl,
    required String clientId,
    required String redirectQueryParameter,
  }) async* {
    try {
      yield Right<Failure, Success>(SignInSaasLoading());
      final token = await _saasRepository.signIn(
        registrationSiteUrl,
        clientId,
        redirectQueryParameter,
      );
      yield Right<Failure, Success>(SignInSaasSuccess(token));
    } catch (e) {
      yield Left<Failure, Success>(SignInSaasFailure(e));
    }
  }
}
