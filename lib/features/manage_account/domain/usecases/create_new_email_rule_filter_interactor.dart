import 'dart:core';

import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/create_new_email_rule_filter_request.dart';
import 'package:tmail_ui_user/features/manage_account/domain/repository/rule_filter_repository.dart';
import 'package:tmail_ui_user/features/manage_account/domain/state/create_new_rule_filter_state.dart';

class CreateNewEmailRuleFilterInteractor {
  final RuleFilterRepository _ruleFilterRepository;

  CreateNewEmailRuleFilterInteractor(this._ruleFilterRepository);

  Stream<Either<Failure, Success>> execute(
      AccountId accountId,
      CreateNewEmailRuleFilterRequest ruleFilterRequest
  ) async* {
    try {
      final newListRules = await _ruleFilterRepository.createNewEmailRuleFilter(
          accountId,
          ruleFilterRequest);
      yield Right(CreateNewRuleFilterSuccess(newListRules));
    } catch (exception) {
      yield Left(CreateNewRuleFilterFailure(exception));
    }
  }
}