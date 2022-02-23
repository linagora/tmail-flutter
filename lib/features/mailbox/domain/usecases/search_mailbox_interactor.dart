
import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/features/mailbox/domain/state/search_mailbox_state.dart';
import 'package:tmail_ui_user/features/thread/domain/model/search_query.dart';

class SearchMailboxInteractor {

  Stream<Either<Failure, Success>> execute(List<PresentationMailbox> mailboxes, SearchQuery searchQuery) async* {
    try {
      final resultList = mailboxes
        .where((mailbox) => mailbox.name?.name.toLowerCase().contains(searchQuery.value.toLowerCase()) == true)
        .toList();

      yield Right<Failure, Success>(SearchMailboxSuccess(resultList));
    } catch (exception) {
      yield Left<Failure, Success>(SearchMailboxFailure(exception));
    }
  }
}