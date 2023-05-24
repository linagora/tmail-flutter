import 'dart:io';

import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/utils/build_utils.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/properties/properties.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:model/extensions/email_extension.dart';
import 'package:tmail_ui_user/features/email/domain/repository/email_repository.dart';
import 'package:tmail_ui_user/features/thread/domain/repository/thread_repository.dart';
import 'package:tmail_ui_user/features/thread/domain/state/get_email_by_id_state.dart';

class GetEmailByIdInteractor {
  final ThreadRepository _threadRepository;
  final EmailRepository _emailRepository;

  GetEmailByIdInteractor(this._threadRepository, this._emailRepository);

  Stream<Either<Failure, Success>> execute(
    Session session,
    AccountId accountId,
    EmailId emailId,
    {
      Properties? properties,
    }
  ) async* {
    try {
      yield Right<Failure, Success>(GetEmailByIdLoading());
      if (!BuildUtils.isWeb) {
        yield* _tryToGetEmailFromCache(session, accountId, emailId, properties: properties);
      } else {
        yield* _getEmailByIdFromServer(session, accountId, emailId, properties: properties);
      }
    } catch (e) {
      yield Left<Failure, Success>(GetEmailByIdFailure(e));
    }
  }

  Stream<Either<Failure, Success>> _getEmailByIdFromServer(
    Session session,
    AccountId accountId,
    EmailId emailId,
    {
      Properties? properties,
    }
  ) async* {
    try {
      final email = await _threadRepository.getEmailById(session, accountId, emailId, properties: properties);
      yield Right<Failure, Success>(GetEmailByIdSuccess(email));
    } catch (e) {
      yield Left<Failure, Success>(GetEmailByIdFailure(e));
    }

  }

  Stream<Either<Failure, Success>> _tryToGetEmailFromCache(
    Session session,
    AccountId accountId,
    EmailId emailId,
    {
      Properties? properties,
    }
  ) async* {
    try {

      final email = await _emailRepository.getEmailStored(session, accountId, emailId);

      if (email != null) {
        yield Right<Failure, Success>(GetEmailByIdSuccess(email.toPresentationEmail()));
      } else {
        yield* _getEmailByIdFromServer(session, accountId, emailId, properties: properties);
      }
    } catch (e) {
      if (e is PathNotFoundException) {
        yield* _getEmailByIdFromServer(session, accountId, emailId, properties: properties);
      } else {
        yield Left<Failure, Success>(GetEmailByIdFailure(e));
      }
    }
  }
}