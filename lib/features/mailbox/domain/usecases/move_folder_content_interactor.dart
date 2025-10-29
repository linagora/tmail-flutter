import 'dart:async';

import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/move_folder_content_request.dart';
import 'package:tmail_ui_user/features/mailbox/domain/repository/mailbox_repository.dart';
import 'package:tmail_ui_user/features/mailbox/domain/state/move_folder_content_state.dart';

class MoveFolderContentInteractor {
  final MailboxRepository _mailboxRepository;

  MoveFolderContentInteractor(this._mailboxRepository);

  Stream<Either<Failure, Success>> execute({
    required Session session,
    required AccountId accountId,
    required MoveFolderContentRequest request,
    StreamController<Either<Failure, Success>>? onProgressController,
  }) async* {
    try {
      yield Right<Failure, Success>(MovingFolderContent());
      onProgressController?.add(Right(MovingFolderContent()));
      await _mailboxRepository.moveFolderContent(
        session: session,
        accountId: accountId,
        request: request,
        onProgressController: onProgressController,
      );
      yield Right<Failure, Success>(MoveFolderContentSuccess(request));
    } catch (e) {
      yield Left<Failure, Success>(MoveFolderContentFailure(e));
    }
  }
}
