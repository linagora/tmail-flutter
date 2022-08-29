import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/properties/properties.dart';
import 'package:jmap_dart_client/jmap/core/sort/comparator.dart';
import 'package:jmap_dart_client/jmap/core/unsigned_int.dart';
import 'package:model/extensions/email_extension.dart';
import 'package:tmail_ui_user/features/thread/domain/model/email_filter.dart';
import 'package:tmail_ui_user/features/thread/domain/model/email_response.dart';
import 'package:tmail_ui_user/features/thread/domain/repository/thread_repository.dart';
import 'package:tmail_ui_user/features/thread/domain/state/re_sync_thread_state.dart';

class ReSyncThreadInteractor {
  final ThreadRepository _threadRepository;

  ReSyncThreadInteractor(this._threadRepository);

  Stream<Either<Failure, Success>> execute(
    AccountId accountId,
    {
      UnsignedInt? limit,
      Set<Comparator>? sort,
      EmailFilter? emailFilter,
      Properties? propertiesCreated,
      Properties? propertiesUpdated,
    }
  ) async* {
    try {
      yield Right<Failure, Success>(LoadingState());

      yield* _threadRepository
        .reSyncEmails(
          accountId,
          limit: limit,
          sort: sort,
          emailFilter: emailFilter,
          propertiesCreated: propertiesCreated,
          propertiesUpdated: propertiesUpdated)
        .map(_toGetEmailState);

    } catch(e) {
      yield Left(ReSyncThreadFailure(e));
    }
  }

  Either<Failure, Success> _toGetEmailState(EmailsResponse emailResponse) {
    final presentationEmailList = emailResponse.emailList
      ?.map((email) => email.toPresentationEmail()).toList() ?? List.empty();

    return Right<Failure, Success>(
      ReSyncThreadSuccess(presentationEmailList, emailResponse.state)
    );
  }
}