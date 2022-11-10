import 'dart:core';

import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/delete_email_rule_request.dart';
import 'package:tmail_ui_user/features/manage_account/domain/repository/rule_filter_repository.dart';
import 'package:tmail_ui_user/features/manage_account/domain/state/delete_email_rule_state.dart';

class DeleteEmailRuleInteractor {
  final RuleFilterRepository _ruleFilterRepository;

  DeleteEmailRuleInteractor(this._ruleFilterRepository);

  Stream<Either<Failure, Success>> execute(AccountId accountId, DeleteEmailRuleRequest deleteEmailRuleRequest) async* {
    try {
    final result = await _ruleFilterRepository.deleteTMailRule(accountId, deleteEmailRuleRequest);
      yield Right(DeleteEmailRuleSuccess(result));
    } catch (exception) {
      yield Left(DeleteEmailRuleFailure(exception));
    }
  }
}