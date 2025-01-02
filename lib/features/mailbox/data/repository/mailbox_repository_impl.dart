import 'dart:async';

import 'package:core/data/model/source_type/data_source_type.dart';
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/utils/app_logger.dart';
import 'package:dartz/dartz.dart' as dartz;
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/error/set_error.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/core/properties/properties.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/core/state.dart';
import 'package:jmap_dart_client/jmap/core/unsigned_int.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/email/read_actions.dart';
import 'package:model/extensions/list_mailbox_extension.dart';
import 'package:model/extensions/mailbox_extension.dart';
import 'package:tmail_ui_user/features/email/data/datasource/email_datasource.dart';
import 'package:tmail_ui_user/features/mailbox/data/datasource/mailbox_datasource.dart';
import 'package:tmail_ui_user/features/mailbox/data/datasource/state_datasource.dart';
import 'package:tmail_ui_user/features/mailbox/data/extensions/state_extension.dart';
import 'package:tmail_ui_user/features/mailbox/data/model/state_type.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/cache_mailbox_response.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/create_new_mailbox_request.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/get_mailbox_by_role_response.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/jmap_mailbox_response.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/mailbox_response.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/move_mailbox_request.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/rename_mailbox_request.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/subscribe_mailbox_request.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/subscribe_multiple_mailbox_request.dart';
import 'package:tmail_ui_user/features/mailbox/domain/repository/mailbox_repository.dart';

class MailboxRepositoryImpl extends MailboxRepository {

  final Map<DataSourceType, MailboxDataSource> mapDataSource;
  final StateDataSource stateDataSource;
  final EmailDataSource? emailDataSource;

  MailboxRepositoryImpl(
    this.mapDataSource,
    this.stateDataSource,
    [this.emailDataSource,]
  );

  @override
  Stream<MailboxResponse> getAllMailbox(Session session, AccountId accountId, {Properties? properties}) async* {
    CacheMailboxResponse? cacheMailboxResponse = await _getAllMailboxFromCache(accountId, session.username);
    if (cacheMailboxResponse != null) {
      yield cacheMailboxResponse;
    }

    final jmapMailboxResponse = await _getAllMailboxFromJMAP(accountId, session);
    if (jmapMailboxResponse == null) {
      return;
    }

    await _syncNewInCache(
      accountId,
      session.username,
      jmapMailboxResponse.mailboxes,
      jmapMailboxResponse.state!);

    yield jmapMailboxResponse;
  }

  Future<CacheMailboxResponse?> _getAllMailboxFromCache(AccountId accountId, UserName userName) async {
    try {
      final cacheMailboxResponse = await Future.wait([
        mapDataSource[DataSourceType.local]!.getAllMailboxCache(accountId, userName),
        stateDataSource.getState(accountId, userName, StateType.mailbox)
      ], eagerError: true).then((List response) => CacheMailboxResponse(mailboxes: response.first, state: response.last));
      log('MailboxRepositoryImpl::_getAllMailboxFromCache: MAILBOX_CACHED = ${cacheMailboxResponse.mailboxes.length} | STATE_CACHED = ${cacheMailboxResponse.state?.value}');
      return cacheMailboxResponse;
    } catch (e) {
      logError('MailboxRepositoryImpl::_getAllMailboxFromCache: Exception: $e');
      return null;
    }
  }

  Future<JmapMailboxResponse?> _getAllMailboxFromJMAP(
    AccountId accountId,
    Session session,
    {Properties? properties}
  ) async {
    try {
      final jmapMailboxResponse = await mapDataSource[DataSourceType.network]!.getAllMailbox(
        session,
        accountId,
        properties: properties);
      log('MailboxRepositoryImpl::_getAllMailboxFromJMAP: MAILBOX_NETWORK = ${jmapMailboxResponse.mailboxes.length} | STATE_NETWORK = ${jmapMailboxResponse.state}');
      return jmapMailboxResponse;
    } catch (e) {
      logError('MailboxRepositoryImpl::_getAllMailboxFromJMAP: Exception: $e');
      return null;
    }
  }

  Future<void> _syncNewInCache(
    AccountId accountId,
    UserName userName,
    List<Mailbox> newMailboxes,
    State newState,
  ) async {
    try {
      await _syncNewMailboxesInCache(accountId, userName, newMailboxes);
      await _syncNewMailboxStateInCache(accountId, userName, newState);
    } catch (e) {
      logError('MailboxRepositoryImpl::_syncNewInCache: Exception = $e');
    }
  }

  Future<void> _syncNewMailboxesInCache(
    AccountId accountId,
    UserName userName,
    List<Mailbox> newMailboxes
  ) async {
    await mapDataSource[DataSourceType.local]!.clearAllMailboxCache(
      accountId,
      userName);
    await mapDataSource[DataSourceType.local]!.update(
      accountId,
      userName,
      created: newMailboxes);
  }

  Future<void> _syncNewMailboxStateInCache(
    AccountId accountId,
    UserName userName,
    State newState
  ) async {
    await stateDataSource.saveState(
      accountId,
      userName,
      newState.toStateCache(StateType.mailbox));
  }

  Future<List<Mailbox>?> _combineMailboxCache({
    List<Mailbox>? mailboxUpdatedList,
    Properties? updatedProperties,
    List<Mailbox>? mailboxCacheList
  }) async {
    if (mailboxUpdatedList == null || mailboxUpdatedList.isEmpty) {
      return null;
    }
    log('MailboxRepositoryImpl::_combineMailboxCache:mailboxUpdatedList: $mailboxUpdatedList');
    if (updatedProperties == null) {
      log('MailboxRepositoryImpl::_combineMailboxCache:updatedProperties is null');
      return mailboxUpdatedList;
    } else {
      final newMailboxUpdatedList = mailboxUpdatedList.map((mailboxUpdated) {
        final mailboxOld = mailboxCacheList?.findMailbox(mailboxUpdated.id!);
        if (mailboxOld != null) {
          return mailboxOld.combineMailbox(mailboxUpdated, updatedProperties);
        } else {
          return mailboxUpdated;
        }
      }).toList();
      log('MailboxRepositoryImpl::_combineMailboxCache:newMailboxUpdatedList: ${newMailboxUpdatedList.length}');
      return newMailboxUpdatedList;
    }
  }

  @override
  Stream<MailboxResponse> refresh(Session session, AccountId accountId, State currentState, {Properties? properties}) async* {
    final localMailboxList = await mapDataSource[DataSourceType.local]!.getAllMailboxCache(accountId, session.username);

    bool hasMoreChanges = true;
    State? sinceState = currentState;

    while(hasMoreChanges && sinceState != null) {
      final changesResponse = await mapDataSource[DataSourceType.network]!.getChanges(session, accountId, sinceState, properties: properties);

      hasMoreChanges = changesResponse.hasMoreChanges;
      sinceState = changesResponse.newStateChanges;

      final newMailboxUpdated = await _combineMailboxCache(
          mailboxUpdatedList: changesResponse.updated,
          updatedProperties: changesResponse.updatedProperties,
          mailboxCacheList: localMailboxList);

      await Future.wait([
        mapDataSource[DataSourceType.local]!.update(
            accountId,
            session.username,
            updated: newMailboxUpdated,
            created: changesResponse.created,
            destroyed: changesResponse.destroyed),
        if (changesResponse.newStateMailbox != null)
          stateDataSource.saveState(accountId, session.username, changesResponse.newStateMailbox!.toStateCache(StateType.mailbox)),
      ]);
    }

    final newMailboxResponse = await Future.wait([
      mapDataSource[DataSourceType.local]!.getAllMailboxCache(accountId, session.username),
      stateDataSource.getState(accountId, session.username, StateType.mailbox)
    ]).then((List response) {
      return CacheMailboxResponse(mailboxes: response.first, state: response.last);
    });

    yield newMailboxResponse;
  }

  @override
  Future<Mailbox?> createNewMailbox(Session session, AccountId accountId, CreateNewMailboxRequest newMailboxRequest) {
    return mapDataSource[DataSourceType.network]!.createNewMailbox(session, accountId, newMailboxRequest);
  }

  @override
  Future<Map<Id,SetError>> deleteMultipleMailbox(Session session, AccountId accountId, List<MailboxId> mailboxIds) {
    return mapDataSource[DataSourceType.network]!.deleteMultipleMailbox(session, accountId, mailboxIds);
  }

  @override
  Future<bool> renameMailbox(Session session, AccountId accountId, RenameMailboxRequest request) async {
    final result = await mapDataSource[DataSourceType.network]
      !.renameMailbox(session, accountId, request);

    await mapDataSource[DataSourceType.local]
      !.renameMailbox(session, accountId, request);

    return result;
  }

  @override
  Future<List<EmailId>> markAsMailboxRead(
    Session session,
    AccountId accountId,
    MailboxId mailboxId,
    int totalEmailUnread,
    StreamController<dartz.Either<Failure, Success>> onProgressController,
  ) async {
    final result = await mapDataSource[DataSourceType.network]!.markAsMailboxRead(
      session,
      accountId,
      mailboxId,
      totalEmailUnread,
      onProgressController);
    await mapDataSource[DataSourceType.local]!.markAsMailboxRead(
      session,
      accountId,
      mailboxId,
      totalEmailUnread - result.length,
      onProgressController,
    );
    await emailDataSource?.markAsRead(
      session,
      accountId,
      result,
      ReadActions.markAsRead,
    );
    return result;
  }

  @override
  Future<bool> moveMailbox(Session session, AccountId accountId, MoveMailboxRequest request) {
    return mapDataSource[DataSourceType.network]!.moveMailbox(session, accountId, request);
  }

  @override
  Future<State?> getMailboxState(Session session, AccountId accountId) {
    return stateDataSource.getState(accountId, session.username, StateType.mailbox);
  }

  @override
  Future<bool> subscribeMailbox(Session session, AccountId accountId, SubscribeMailboxRequest request) {
    return mapDataSource[DataSourceType.network]!.subscribeMailbox(session, accountId, request);
  }

  @override
  Future<List<MailboxId>> subscribeMultipleMailbox(Session session, AccountId accountId, SubscribeMultipleMailboxRequest subscribeRequest) {
    return mapDataSource[DataSourceType.network]!.subscribeMultipleMailbox(session, accountId, subscribeRequest);
  }

  @override
  Future<List<Mailbox>> createDefaultMailbox(Session session, AccountId accountId, List<Role> listRole) {
    return mapDataSource[DataSourceType.network]!.createDefaultMailbox(session, accountId, listRole);
  }

  @override
  Future<void> setRoleDefaultMailbox(Session session, AccountId accountId, List<Mailbox> listMailbox) {
    return mapDataSource[DataSourceType.network]!.setRoleDefaultMailbox(session, accountId, listMailbox);
  }
  
  @override
  Future<GetMailboxByRoleResponse> getMailboxByRole(Session session, AccountId accountId, Role role, {UnsignedInt? limit}) {
    return mapDataSource[DataSourceType.network]!.getMailboxByRole(session, accountId, role);
  }
}