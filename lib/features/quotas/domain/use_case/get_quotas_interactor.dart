import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:tmail_ui_user/features/quotas/domain/repository/quotas_repository.dart';
import 'package:tmail_ui_user/features/quotas/domain/state/get_quotas_state.dart';

class GetQuotasInteractor {
  final QuotasRepository quotasRepository;

  GetQuotasInteractor(this.quotasRepository);

  Stream<Either<Failure, Success>> execute(AccountId accountId) async* {
    try {
      yield Right<Failure, Success>(GetQuotasLoading());
      final listQuotas = await quotasRepository.getQuotas(accountId);
      yield Right(GetQuotasSuccess(listQuotas));
    } catch (exception) {
      yield Left(GetQuotasFailure(exception));
    }
  }
}