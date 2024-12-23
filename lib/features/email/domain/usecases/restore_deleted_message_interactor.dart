import 'dart:async';

import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:tmail_ui_user/features/email/domain/model/restore_deleted_message_request.dart';
import 'package:tmail_ui_user/features/email/domain/repository/email_repository.dart';
import 'package:tmail_ui_user/features/email/domain/state/restore_deleted_message_state.dart';

class RestoredDeletedMessageInteractor {
  final EmailRepository _emailRepository;

  RestoredDeletedMessageInteractor(this._emailRepository);

  Stream<Either<Failure, Success>> execute(
    Session session,
    AccountId accountId,
    RestoredDeletedMessageRequest newRecoveryRequest,
  ) async* {
    try {
      yield Right<Failure, Success>(RestoreDeletedMessageLoading());
      final emailRecovery = await _emailRepository.restoreDeletedMessage(newRecoveryRequest);
      yield Right<Failure, Success>(RestoreDeletedMessageSuccess(emailRecovery));
    } catch (e) {
      yield Left<Failure, Success>(RestoreDeletedMessageFailure(e));
    }
  }
}