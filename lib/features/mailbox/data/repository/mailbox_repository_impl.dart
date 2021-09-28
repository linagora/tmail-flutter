import 'package:core/core.dart';
import 'package:model/model.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/properties/properties.dart';
import 'package:jmap_dart_client/jmap/core/state.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:tmail_ui_user/features/mailbox/data/datasource/mailbox_datasource.dart';
import 'package:tmail_ui_user/features/mailbox/data/model/mailbox_change_response.dart';
import 'package:tmail_ui_user/features/mailbox/domain/repository/mailbox_repository.dart';

class MailboxRepositoryImpl extends MailboxRepository {

  final Map<DataSourceType, MailboxDataSource> mapDataSource;

  MailboxRepositoryImpl(this.mapDataSource);

  @override
  Stream<List<Mailbox>> getAllMailbox(AccountId accountId, {Properties? properties}) async* {
    final mailboxCacheResponse = await mapDataSource[DataSourceType.local]!.getAllMailboxCache();

    final mailboxList = mailboxCacheResponse.mailboxCaches != null
        ? mailboxCacheResponse.mailboxCaches!.toMailboxList()
        : <Mailbox>[];
    final oldState = mailboxCacheResponse.oldState?.state;

    yield mailboxList;

    if (mailboxList.isNotEmpty && oldState != null) {
      final changesResponse = await mapDataSource[DataSourceType.network]!.getChanges(accountId, State(oldState));

      final newChangesResponse = await mapDataSource[DataSourceType.local]!.combineMailboxCache(changesResponse, mailboxList);

      await mapDataSource[DataSourceType.local]!.asyncUpdateCache(newChangesResponse);
    } else {
      final getMailboxResponse = await mapDataSource[DataSourceType.network]!.getAllMailbox(accountId);

      await mapDataSource[DataSourceType.local]!.asyncUpdateCache(MailboxChangeResponse(
          created: getMailboxResponse?.list,
          newState: getMailboxResponse?.state));
    }

    final newMailboxCacheResponse = await mapDataSource[DataSourceType.local]!.getAllMailboxCache();

    final newMailboxList = newMailboxCacheResponse.mailboxCaches != null
        ? newMailboxCacheResponse.mailboxCaches!.toMailboxList()
        : <Mailbox>[];

    yield newMailboxList;
  }

  @override
  Stream<List<Mailbox>> refresh(AccountId accountId, State currentState) async* {
    final changesResponse = await mapDataSource[DataSourceType.network]!.getChanges(accountId, currentState);

    await mapDataSource[DataSourceType.local]!.asyncUpdateCache(changesResponse);

    final newMailboxCacheResponse = await mapDataSource[DataSourceType.local]!.getAllMailboxCache();

    final newMailboxList = newMailboxCacheResponse.mailboxCaches != null
        ? newMailboxCacheResponse.mailboxCaches!.toMailboxList()
        : <Mailbox>[];

    yield newMailboxList;
  }
}