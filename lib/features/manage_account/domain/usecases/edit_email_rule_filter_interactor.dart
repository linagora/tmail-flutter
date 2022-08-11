import 'dart:core';

import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/edit_email_rule_filter_request.dart';
import 'package:tmail_ui_user/features/manage_account/domain/repository/manage_account_repository.dart';
import 'package:tmail_ui_user/features/manage_account/domain/state/edit_email_rule_filter_state.dart';

class EditEmailRuleFilterInteractor {
  final ManageAccountRepository manageAccountRepository;

  EditEmailRuleFilterInteractor(this.manageAccountRepository);

  Stream<Either<Failure, Success>> execute(
      AccountId accountId,
      EditEmailRuleFilterRequest ruleFilterRequest
  ) async* {
    try {
      final newListRules = await manageAccountRepository
          .editEmailRuleFilter(accountId, ruleFilterRequest);
      yield Right(EditEmailRuleFilterSuccess(newListRules));
    } catch (exception) {
      yield Left(EditEmailRuleFilterFailure(exception));
    }
  }
}