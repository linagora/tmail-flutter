import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:tmail_ui_user/features/login/domain/repository/authentication_oidc_repository.dart';
import 'package:tmail_ui_user/features/login/domain/state/remove_auth_destination_url_state.dart';

class RemoveAuthDestinationUrlInteractor {
  final AuthenticationOIDCRepository _authenticationOIDCRepository;

  const RemoveAuthDestinationUrlInteractor(this._authenticationOIDCRepository);

  Stream<Either<Failure, Success>> execute() async* {
    try {
      yield Right<Failure, Success>(RemovingAuthDestinationUrl());
      await _authenticationOIDCRepository.removeAuthDestinationUrl();
      yield Right<Failure, Success>(RemoveAuthDestinationUrlSuccess());
    } catch (e) {
      yield Left<Failure, Success>(RemoveAuthDestinationUrlFailure(e));
    }
  }
}
