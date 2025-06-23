import 'dart:async';
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/utils/app_logger.dart';
import 'package:dartz/dartz.dart';
import 'package:model/oidc/request/oidc_request.dart';
import 'package:model/oidc/response/oidc_response.dart';
import 'package:tmail_ui_user/features/login/domain/repository/authentication_oidc_repository.dart';
import 'package:tmail_ui_user/features/login/domain/state/try_guessing_web_finger_state.dart';

class TryGuessingWebFingerInteractor {
  const TryGuessingWebFingerInteractor(this._authenticationOIDCRepository);

  final AuthenticationOIDCRepository _authenticationOIDCRepository;

  Stream<Either<Failure, Success>> execute(
    List<OIDCRequest> oidcRequests,
  ) async* {
    try {
      yield Right(TryingGuessingWebFinger());
      final futures = oidcRequests.map(_checkOIDCAvailableFromOidcRequest).toList();
      final completer = Completer<OIDCResponse?>();
      
      for (final future in futures) {
        future.then((response) {
          if (response != null && !completer.isCompleted) {
            completer.complete(response);
          }
        });
      }
      
      Future.wait(futures).then((_) {
        if (!completer.isCompleted) {
          completer.complete(null);
        }
      });
      
      final firstNonNullResponse = await completer.future;
      
      if (firstNonNullResponse == null) {
        yield Left(TryGuessingWebFingerFailure());
      } else {
        yield Right(TryGuessingWebFingerSuccess(firstNonNullResponse));
      }
    } catch (e) {
      logError('$runtimeType::execute(): Exception = $e');
      yield Left(TryGuessingWebFingerFailure(exception: e));
    }
  }

  Future<OIDCResponse?> _checkOIDCAvailableFromOidcRequest(
    OIDCRequest oidcRequest,
  ) async {
    try {
      return await _authenticationOIDCRepository.checkOIDCIsAvailable(
        oidcRequest,
      );
    } catch (_) {
      return null;
    }
  }
}
