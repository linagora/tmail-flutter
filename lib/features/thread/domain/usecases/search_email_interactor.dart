
import 'package:core/core.dart';
import 'package:model/model.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/filter/filter.dart';
import 'package:jmap_dart_client/jmap/core/properties/properties.dart';
import 'package:jmap_dart_client/jmap/core/unsigned_int.dart';
import 'package:jmap_dart_client/jmap/core/sort/comparator.dart';
import 'package:tmail_ui_user/features/thread/domain/repository/thread_repository.dart';
import 'package:tmail_ui_user/features/thread/domain/state/search_email_state.dart';

class SearchEmailInteractor {

  final ThreadRepository threadRepository;

  SearchEmailInteractor(this.threadRepository);

  Stream<Either<Failure, Success>> execute(
    AccountId accountId,
    {
      UnsignedInt? limit,
      Set<Comparator>? sort,
      Filter? filter,
      Properties? properties,
    }
  ) async* {
    try {
      yield Right(SearchingState());

      final emailList = await threadRepository.searchEmails(
        accountId,
        limit: limit,
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