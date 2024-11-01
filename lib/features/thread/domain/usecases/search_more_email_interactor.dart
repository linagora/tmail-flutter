
import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/filter/filter.dart';
import 'package:jmap_dart_client/jmap/core/properties/properties.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/core/sort/comparator.dart';
import 'package:jmap_dart_client/jmap/core/unsigned_int.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/features/thread/domain/repository/thread_repository.dart';
import 'package:tmail_ui_user/features/thread/domain/state/search_more_email_state.dart';

class SearchMoreEmailInteractor {

  final ThreadRepository threadRepository;

  SearchMoreEmailInteractor(this.threadRepository);

  Stream<Either<Failure, Success>> execute(
    Session session,
    AccountId accountId,
    {
      UnsignedInt? limit,
      Set<Comparator>? sort,
      int? position,
      Filter? filter,
      Properties? properties,
      EmailId? lastEmailId
    }
  ) async* {
    try {
      yield Right(SearchingMoreState());

      final emailList = await threadRepository.searchEmails(
        session,
        accountId,
        limit: limit,
        position: position,
        sort: sort,
        filter: filter,
        properties: properties);

      final presentationEmailList = emailList
        .where((email) => email.id != lastEmailId)
        .map((email) => email.toPresentationEmail(
          searchSnippetSubject: email.searchSnippetSubject,
          searchSnippetPreview: email.searchSnippetPreview,
        ))
        .toList();

      yield Right(SearchMoreEmailSuccess(presentationEmailList));
    } catch (e) {
      yield Left(SearchMoreEmailFailure(e));
    }
  }
}