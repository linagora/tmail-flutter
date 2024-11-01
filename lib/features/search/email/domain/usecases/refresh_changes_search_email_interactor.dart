
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/filter/filter.dart';
import 'package:jmap_dart_client/jmap/core/properties/properties.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/core/sort/comparator.dart';
import 'package:jmap_dart_client/jmap/core/unsigned_int.dart';
import 'package:model/extensions/email_extension.dart';
import 'package:tmail_ui_user/features/search/email/domain/state/refresh_changes_search_email_state.dart';
import 'package:tmail_ui_user/features/thread/domain/repository/thread_repository.dart';

class RefreshChangesSearchEmailInteractor {

  final ThreadRepository threadRepository;

  RefreshChangesSearchEmailInteractor(this.threadRepository);

  Stream<Either<Failure, Success>> execute(
    Session session,
    AccountId accountId,
    {
      UnsignedInt? limit,
      int? position,
      Set<Comparator>? sort,
      Filter? filter,
      Properties? properties,
    }
  ) async* {
    try {
      yield Right(RefreshingChangeSearchEmailState());

      final emailList = await threadRepository.searchEmails(
        session,
        accountId,
        limit: limit,
        position: position,
        sort: sort,
        filter: filter,
        properties: properties);

      final presentationEmailList = emailList
          .map((email) => email.toPresentationEmail(
            searchSnippetSubject: email.searchSnippetSubject,
            searchSnippetPreview: email.searchSnippetPreview,
          ))
          .toList();

      yield Right(RefreshChangesSearchEmailSuccess(presentationEmailList));
    } catch (e) {
      yield Left(RefreshChangesSearchEmailFailure(e));
    }
  }
}