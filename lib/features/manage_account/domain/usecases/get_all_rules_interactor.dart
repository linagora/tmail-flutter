import 'dart:core';

import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:tmail_ui_user/features/manage_account/domain/repository/manage_account_repository.dart';
import 'package:tmail_ui_user/features/manage_account/domain/state/get_all_rules_state.dart';

class GetAllRulesInteractor {
  final ManageAccountRepository manageAccountRepository;

  GetAllRulesInteractor(this.manageAccountRepository);

  Stream<Either<Failure, Success>> execute(AccountId accountId) async* {
    try {
      yield Right<Failure, Success>(LoadingState());
      final rulesResponse = await manageAccountRepository.getAllTMailRule(accountId);
      yield Right(GetAllRulesSuccess(rulesResponse));
    } catch (exception) {
      yield Left(GetAllRulesFailure(exception));
    }
  }
}