
import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/filter/filter.dart';
import 'package:jmap_dart_client/jmap/core/properties/properties.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/core/sort/comparator.dart';
import 'package:jmap_dart_client/jmap/core/unsigned_int.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/features/thread/domain/repository/thread_repository.dart';
import 'package:tmail_ui_user/features/thread/domain/state/search_email_state.dart';

class SearchEmailInteractor {

  final ThreadRepository threadRepository;

  SearchEmailInteractor(this.threadRepository);

  Stream<Either<Failure, Success>> execute(
    Session session,
    AccountId accountId,
    {
      UnsignedInt? limit,
      int? position,
      Set<Comparator>? sort,
      Filter? filter,
      Properties? properties,
      bool isRefreshChange = false,
    }
  ) async* {
    try {
      if (isRefreshChange) {
        yield Right(RefreshingSearchState());
      } else {
        yield Right(SearchingState());
      }

      final emailList = await threadRepository.searchEmails(
        session,
        accountId,
        limit: limit,
        position: position,
        sort: sort,
        filter: filter,
        properties: properties);

      final presentationEmailList = emailList
        .map((email) => email.toPresentationEmail())
        .toList();

      yield Right(SearchEmailSuccess(presentationEmailList));
    } catch (e) {
      yield Left(SearchEmailFailure(e));
    }
  }
}