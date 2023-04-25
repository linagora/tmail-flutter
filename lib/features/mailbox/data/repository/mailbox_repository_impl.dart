import 'dart:async';

import 'package:core/data/model/source_type/data_source_type.dart';
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
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
      mapDataSource[DataSourceType.local]!.getAllMailboxCache(accountId),
      stateDataSource.getState(StateType.mailbox)
    ]).then((List response) {
      return MailboxResponse(mailboxes: response.first, state: response.last);
    });

    yield localMailboxResponse;

    if (localMailboxResponse.hasData()) {
      bool hasMoreChanges = true;
      State? sinceState = localMailboxResponse.state!;

      while(hasMoreChanges && sinceState != null) {
        final changesResponse = await mapDataSource[DataSourceType.network]!.getChanges(session, accountId, sinceState);

        hasMoreChanges = changesResponse.hasMoreChanges;
        sinceState = changesResponse.newStateChanges;

        final newMailboxUpdated = await _combineMailboxCache(
            mailboxUpdated: changesResponse.updated,
            updatedProperties: changesResponse.updatedProperties,
            mailboxCacheList: localMailboxResponse.mailboxes!);

        await Future.wait([
          mapDataSource[DataSourceType.local]!.update(
              accountId,
              updated: newMailboxUpdated,
              created: changesResponse.created,
              destroyed: changesResponse.destroyed),
          if (changesResponse.newStateMailbox != null)
            stateDataSource.saveState(accountId, changesResponse.newStateMailbox!.toStateCache(StateType.mailbox)),
        ]);
      }
    } else {
      final mailboxResponse = await mapDataSource[DataSourceType.network]!.getAllMailbox(session, accountId);

      await Future.wait([
        mapDataSource[DataSourceType.local]!.update(accountId, created: mailboxResponse.mailboxes),
        if (mailboxResponse.state != null)
          stateDataSource.saveState(accountId, mailboxResponse.state!.toStateCache(StateType.mailbox)),
      ]);
    }

    final newMailboxResponse = await Future.wait([
      mapDataSource[DataSourceType.local]!.getAllMailboxCache(accountId),
      stateDataSource.getState(StateType.mailbox)
    ]).then((List response) {
      return MailboxResponse(mailboxes: response.first, state: response.last);
    });

    yield newMailboxResponse;
  }

  Future<List<Mailbox>?> _combineMailboxCache({
    List<Mailbox>? mailboxUpdated,
    Properties? updatedProperties,
    List<Mailbox>? mailboxCacheList
  }) async {
    if (mailboxUpdated != null && mailboxUpdated.isNotEmpty) {
      final newMailboxUpdated = mailboxUpdated.map((mailboxUpdated) {
        if (updatedProperties == null) {
          return mailboxUpdated;
        } else {
          final mailboxOld = mailboxCacheList?.findMailbox(mailboxUpdated.id!);
          if (mailboxOld != null) {
            return mailboxOld.combineMailbox(mailboxUpdated, updatedProperties);
          } else {
            return mailboxUpdated;
          }
        }
      }).toList();

      return newMailboxUpdated;
    }
    return mailboxUpdated;
  }

  @override
  Stream<MailboxResponse> refresh(Session session, AccountId accountId, State currentState) async* {
    final localMailboxList = await mapDataSource[DataSourceType.local]!.getAllMailboxCache(accountId);

    bool hasMoreChanges = true;
    State? sinceState = currentState;

    while(hasMoreChanges && sinceState != null) {
      final changesResponse = await mapDataSource[DataSourceType.network]!.getChanges(session, accountId, sinceState);

      hasMoreChanges = changesResponse.hasMoreChanges;
      sinceState = changesResponse.newStateChanges;

      final newMailboxUpdated = await _combineMailboxCache(
          mailboxUpdated: changesResponse.updated,
          updatedProperties: changesResponse.updatedProperties,
          mailboxCacheList: localMailboxList);

      await Future.wait([
        mapDataSource[DataSourceType.local]!.update(
            accountId,
            updated: newMailboxUpdated,
            created: changesResponse.created,
            destroyed: changesResponse.destroyed),
        if (changesResponse.newStateMailbox != null)
          stateDataSource.saveState(accountId, changesResponse.newStateMailbox!.toStateCache(StateType.mailbox)),
      ]);
    }

    final newMailboxResponse = await Future.wait([
      mapDataSource[DataSourceType.local]!.getAllMailboxCache(accountId),
      stateDataSource.getState(StateType.mailbox)
    ]).then((List response) {
      return MailboxResponse(mailboxes: response.first, state: response.last);
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
  Future<State?> getMailboxState() {
    return stateDataSource.getState(StateType.mailbox);
  }

  @override
  Future<bool> subscribeMailbox(Session session, AccountId accountId, SubscribeMailboxRequest request) {
    return mapDataSource[DataSourceType.network]!.subscribeMailbox(session, accountId, request);
  }

  @override
  Future<List<MailboxId>> subscribeMultipleMailbox(Session session, AccountId accountId, SubscribeMultipleMailboxRequest subscribeRequest) {
    return mapDataSource[DataSourceType.network]!.subscribeMultipleMailbox(session, accountId, subscribeRequest);
  }
}