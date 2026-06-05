import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import '../repository/workplace_repository.dart';
import '../state/workplace_intent_state.dart';

class ExchangeDriveTokenInteractor {
  final WorkplaceRepository _repository;

  ExchangeDriveTokenInteractor(this._repository);

  Stream<Either<Failure, Success>> execute(Uri platformUrl, String oidcIdToken) async* {
    try {
      yield Right(ExchangingWorkplaceToken());
      final token = await _repository.exchangeToken(platformUrl, oidcIdToken);
      yield Right(ExchangeWorkplaceTokenSuccess(token));
    } catch (e) {
      yield Left(ExchangeWorkplaceTokenFailure(exception: e));
    }
  }
}
