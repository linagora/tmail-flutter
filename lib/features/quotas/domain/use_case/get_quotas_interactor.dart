import 'dart:core';

import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:tmail_ui_user/features/quotas/domain/repository/quotas_repository.dart';
import 'package:tmail_ui_user/features/quotas/domain/state/get_quotas_state.dart';

class GetQuotasInteractor {
  final QuotasRepository quotasRepository;

  GetQuotasInteractor(this.quotasRepository);

  Stream<Either<Failure, Success>> execute(AccountId accountId) async* {
    try {
      yield Right<Failure, Success>(LoadingState());
      final response = await quotasRepository.getQuotas(accountId);
      yield Right(GetQuotasSuccess(response.quotas, response.state));
    } catch (exception) {
      yield Left(GetQuotasFailure(exception));
    }
  }
}