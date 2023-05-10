import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:tmail_ui_user/features/email/domain/model/detailed_email.dart';
import 'package:tmail_ui_user/features/email/domain/repository/email_repository.dart';
import 'package:tmail_ui_user/features/email/domain/state/store_detailed_email_to_cache_state.dart';

class StoreDetailedEmailToCacheInteractor {
  final EmailRepository _emailRepository;

  StoreDetailedEmailToCacheInteractor(this._emailRepository);

  Stream<Either<Failure, Success>> execute(Session session, AccountId accountId, DetailedEmail detailedEmail) async* {
    try {
      yield Right<Failure, Success>(StoreDetailedEmailToCacheLoading());
      await _emailRepository.storeDetailedEmailToCache(session, accountId, detailedEmail);
      yield Right<Failure, Success>(StoreDetailedEmailToCacheSuccess());
    } catch (e) {
      yield Left<Failure, Success>(StoreDetailedEmailToCacheFailure(e));
    }
  }
}