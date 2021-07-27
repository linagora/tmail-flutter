import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/properties/properties.dart';
import 'package:tmail_ui_user/features/mailbox/domain/repository/mailbox_repository.dart';
import 'package:tmail_ui_user/features/mailbox/domain/state/get_all_mailboxes_state.dart';
import 'package:tmail_ui_user/features/mailbox/domain/extensions/list_mailbox_extension.dart';
import 'package:tmail_ui_user/features/mailbox/domain/extensions/mailbox_extension.dart';

class GetAllMailboxInteractor {
  final MailboxRepository mailboxRepository;

  GetAllMailboxInteractor(this.mailboxRepository);

  Stream<Either<Failure, Success>> execute(AccountId accountId, {Properties? properties}) async* {
    try {
      yield Right<Failure, Success>(UIState.loading);
      final mailboxList = await mailboxRepository.getAllMailbox(accountId, properties: properties);
      final tupleList = mailboxList.splitMailboxList((mailbox) => mailbox.hasRole());
      yield Right<Failure, Success>(GetAllMailboxSuccess(defaultMailboxList: tupleList.value1, folderMailboxList: tupleList.value2));
    } catch (e) {
      yield Left(GetAllMailboxFailure(e));
    }
  }
}