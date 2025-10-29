import 'dart:async';

import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/move_folder_content_request.dart';
import 'package:tmail_ui_user/features/mailbox/domain/usecases/move_folder_content_interactor.dart';

class MailboxActionReactor {
  MailboxActionReactor(this._moveFolderContentInteractor);

  final MoveFolderContentInteractor _moveFolderContentInteractor;

  Stream<Either<Failure, Success>> moveFolderContent({
    required Session session,
    required AccountId accountId,
    required MoveFolderContentRequest moveRequest,
    StreamController<Either<Failure, Success>>? onProgressController,
  }) {
    return _moveFolderContentInteractor.execute(
      session: session,
      accountId: accountId,
      request: moveRequest,
      onProgressController: onProgressController,
    );
  }
}
