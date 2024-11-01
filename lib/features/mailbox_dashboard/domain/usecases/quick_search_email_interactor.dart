
import 'package:core/core.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:model/model.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/filter/filter.dart';
import 'package:jmap_dart_client/jmap/core/properties/properties.dart';
import 'package:jmap_dart_client/jmap/core/unsigned_int.dart';
import 'package:jmap_dart_client/jmap/core/sort/comparator.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/state/quick_search_email_state.dart';
import 'package:tmail_ui_user/features/thread/domain/repository/thread_repository.dart';

class QuickSearchEmailInteractor {

  final ThreadRepository threadRepository;

  QuickSearchEmailInteractor(this.threadRepository);

  Future<Either<Failure, Success>> execute(
    Session session,
    AccountId accountId,
    {
      UnsignedInt? limit,
      Set<Comparator>? sort,
      Filter? filter,
      Properties? properties,
    }
  ) async {
    try {
      final emailList = await threadRepository.searchEmails(
        session,
        accountId,
        limit: limit,
        sort: sort,
        filter: filter,
        properties: properties);

      final presentationEmailList = emailList
        .map((email) => email.toPresentationEmail(
          searchSnippetSubject: email.searchSnippetSubject,
          searchSnippetPreview: email.searchSnippetPreview,
        ))
        .toList();

      return Right(QuickSearchEmailSuccess(presentationEmailList));
    } catch (e) {
      return Left(QuickSearchEmailFailure(e));
    }
  }
}