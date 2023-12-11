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
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/extensions/list_mailbox_extension.dart';
import 'package:model/extensions/mailbox_extension.dart';
import 'package:tmail_ui_user/features/mailbox/data/datasource/mailbox_datasource.dart';
import 'package:tmail_ui_user/features/mailbox/data/datasource/state_datasource.dart';
import 'package:tmail_ui_user/features/mailbox/data/extensions/state_extension.dart';
import 'package:tmail_ui_user/features/mailbox/data/model/state_type.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/create_new_mailbox_request.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/mailbox_response.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/move_mailbox_request.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/rename_mailbox_request.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/subscribe_mailbox_request.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/subscribe_multiple_mailbox_request.dart';
import 'package:tmail_ui_user/features/mailbox/domain/repository/mailbox_repository.dart';

class MailboxRepositoryImpl extends MailboxRepository {

  final Map<DataSourceType, MailboxDataSource> mapDataSource;
  final StateDataSource stateDataSource;

  MailboxRepositoryImpl(
    this.mapDataSource,
    this.stateDataSource,
  );

  @override
  Stream<MailboxResponse> getAllMailbox(Session session, AccountId accountId, {Properties? properties}) async* {
    final localMailboxResponse = await Future.wait([
      mapDataSource[DataSourceType.local]!.getAllMailboxCache(accountId, session.username),
      stateDataSource.getState(accountId, session.username, StateType.mailbox)
    ]).then((List response) {
      return MailboxResponse(mailboxes: response.first, state: response.last);
    });

    yield localMailboxResponse;

    if (localMailboxResponse.hasData()) {
      bool hasMoreChanges = true;
      State? sinceState = localMailboxResponse.state!;

      while(hasMoreChanges && sinceState != null) {
        final changesResponse = await mapDataSource[DataSourceType.network]!.getChanges(session, accountId, sinceState, properties: properties);

        hasMoreChanges = changesResponse.hasMoreChanges;
        sinceState = changesResponse.newStateChanges;

        final newMailboxUpdated = await _combineMailboxCache(
            mailboxUpdatedList: changesResponse.updated,
            updatedProperties: changesResponse.updatedProperties,
            mailboxCacheList: localMailboxResponse.mailboxes!);

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
    } else {
      final mailboxResponse = await mapDataSource[DataSourceType.network]!.getAllMailbox(session, accountId);

      await Future.wait([
        mapDataSource[DataSourceType.local]!.update(accountId, session.username, created: mailboxResponse.mailboxes),
        if (mailboxResponse.state != null)
          stateDataSource.saveState(accountId, session.username, mailboxResponse.state!.toStateCache(StateType.mailbox)),
      ]);
    }

    final newMailboxResponse = await Future.wait([
      mapDataSource[DataSourceType.local]!.getAllMailboxCache(accountId, session.username),
      stateDataSource.getState(accountId, session.username, StateType.mailbox)
    ]).then((List response) {
      return MailboxResponse(mailboxes: response.first, state: response.last);
    });

    yield newMailboxResponse;
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
      return MailboxResponse(mailboxes: response.first, state: response.last);
    });

    yield newMailboxResponse;
  }

  @override
  Future<Mailbox> createNewMailbox(Session session, AccountId accountId, CreateNewMailboxRequest newMailboxRequest) {
    return mapDataSource[DataSourceType.network]!.createNewMailbox(session, accountId, newMailboxRequest);
  }

  @override
  Future<Map<Id,SetError>> deleteMultipleMailbox(Session session, AccountId accountId, List<MailboxId> mailboxIds) {
    return mapDataSource[DataSourceType.network]!.deleteMultipleMailbox(session, accountId, mailboxIds);
  }

  @override
  Future<bool> renameMailbox(Session session, AccountId accountId, RenameMailboxRequest request) {
    return mapDataSource[DataSourceType.network]!.renameMailbox(session, accountId, request);
  }

  @override
  Future<List<Email>> markAsMailboxRead(
      Session session,
      AccountId accountId,
      MailboxId mailboxId,
      int totalEmailUnread,
      StreamController<dartz.Either<Failure, Success>> onProgressController) async {
    return mapDataSource[DataSourceType.network]!.markAsMailboxRead(
      session,
      accountId,
      mailboxId,
      totalEmailUnread,
      onProgressController);
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
  Future<Mailbox> getMailboxByRole(Session session, AccountId accountId, Role role) {
    return mapDataSource[DataSourceType.network]!.getMailboxByRole(session, accountId, role);
  }

  @override
  Future<Mailbox> getMailboxByName(Session session, AccountId accountId, MailboxName mailboxName) {
    return mapDataSource[DataSourceType.network]!.getMailboxByName(session, accountId, mailboxName);
  }
}