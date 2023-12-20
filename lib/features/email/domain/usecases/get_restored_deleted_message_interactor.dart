import 'dart:async';

import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:email_recovery/email_recovery/email_recovery_action_id.dart';
import 'package:tmail_ui_user/features/email/domain/repository/email_repository.dart';
import 'package:tmail_ui_user/features/email/domain/state/get_restored_deleted_message_state.dart';

class GetRestoredDeletedMessageInterator {
  final EmailRepository _emailRepository;

  GetRestoredDeletedMessageInterator(this._emailRepository);

  Stream<Either<Failure, Success>> execute(
    EmailRecoveryActionId emailRecoveryActionId,
  ) async* {
    try {
      yield Right<Failure, Success>(GetRestoredDeletedMessageLoading());
      final emailRecovery = await _emailRepository.getRestoredDeletedMessage(emailRecoveryActionId);
      yield Right<Failure, Success>(GetRestoredDeletedMessageSuccess(emailRecovery));
    } catch (e) {
      yield Left<Failure, Success>(GetRestoredDeletedMessageFailure(e));
    }
  }
}