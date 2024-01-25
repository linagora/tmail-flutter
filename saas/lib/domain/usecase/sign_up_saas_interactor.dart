import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:saas/domain/repository/saas_authentication_repository.dart';
import 'package:saas/domain/state/sign_up_saas_state.dart';

class SignUpSaasInteractor {
  final SaasAuthenticationRepository _saasRepository;

  SignUpSaasInteractor(this._saasRepository);

  Stream<Either<Failure, Success>> execute({
    required Uri registrationSiteUrl,
    required String clientId,
    required String redirectQueryParameter,
  }) async* {
    try {
      yield Right<Failure, Success>(SignUpSaasLoading());
      final token = await _saasRepository.signUp(
        registrationSiteUrl,
        clientId,
        redirectQueryParameter,
      );
      yield Right<Failure, Success>(SignUpSaasSuccess(token));
    } catch (e) {
      yield Left<Failure, Success>(SignUpSaasFailure(e));
    }
  }
}
