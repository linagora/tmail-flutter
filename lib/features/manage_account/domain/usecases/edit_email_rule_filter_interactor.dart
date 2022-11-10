import 'dart:core';

import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/edit_email_rule_filter_request.dart';
import 'package:tmail_ui_user/features/manage_account/domain/repository/rule_filter_repository.dart';
import 'package:tmail_ui_user/features/manage_account/domain/state/edit_email_rule_filter_state.dart';

class EditEmailRuleFilterInteractor {
  final RuleFilterRepository _ruleFilterRepository;

  EditEmailRuleFilterInteractor(this._ruleFilterRepository);

  Stream<Either<Failure, Success>> execute(
      AccountId accountId,
      EditEmailRuleFilterRequest ruleFilterRequest
  ) async* {
    try {
      final newListRules = await _ruleFilterRepository
          .editEmailRuleFilter(accountId, ruleFilterRequest);
      yield Right(EditEmailRuleFilterSuccess(newListRules));
    } catch (exception) {
      yield Left(EditEmailRuleFilterFailure(exception));
    }
  }
}