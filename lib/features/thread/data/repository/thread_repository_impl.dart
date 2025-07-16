import 'dart:async';

import 'package:core/data/model/source_type/data_source_type.dart';
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/utils/app_logger.dart';
import 'package:dartz/dartz.dart' as dartz;
import 'package:flutter/cupertino.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/filter/filter.dart';
import 'package:jmap_dart_client/jmap/core/properties/properties.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/core/sort/comparator.dart';
import 'package:jmap_dart_client/jmap/core/state.dart' as jmap;
import 'package:jmap_dart_client/jmap/core/unsigned_int.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_filter_condition.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/features/mailbox/data/datasource/state_datasource.dart';
import 'package:tmail_ui_user/features/mailbox/data/extensions/state_extension.dart';
import 'package:tmail_ui_user/features/mailbox/data/model/state_type.dart';
import 'package:tmail_ui_user/features/thread/data/datasource/thread_datasource.dart';
import 'package:tmail_ui_user/features/thread/data/model/email_change_response.dart';
import 'package:tmail_ui_user/features/thread/domain/constants/thread_constants.dart';
import 'package:tmail_ui_user/features/thread/domain/model/email_filter.dart';
import 'package:tmail_ui_user/features/thread/domain/model/email_response.dart';
import 'package:tmail_ui_user/features/thread/domain/model/filter_message_option.dart';
import 'package:tmail_ui_user/features/thread/domain/model/get_email_request.dart';
import 'package:tmail_ui_user/features/thread/domain/model/search_email.dart';
import 'package:tmail_ui_user/features/thread/domain/repository/thread_repository.dart';

class ThreadRepositoryImpl extends ThreadRepository {

  final Map<DataSourceType, ThreadDataSource> mapDataSource;
  final StateDataSource stateDataSource;

  ThreadRepositoryImpl(this.mapDataSource, this.stateDataSource);

  @override
  Stream<EmailsResponse> getAllEmail(
    Session session,
    AccountId accountId,
    {
      UnsignedInt? limit,
      int? position,
      Set<Comparator>? sort,
      EmailFilter? emailFilter,
      Properties? propertiesCreated,
      Properties? propertiesUpdated,
      bool getLatestChanges = true,
    }
  ) async* {
    log('ThreadRepositoryImpl::getAllEmail(): filter = ${emailFilter?.mailboxId}');
    final localEmailResponse = await Future.wait([
      mapDataSource[DataSourceType.local]!.getAllEmailCache(
        accountId,
        session.username,
        inMailboxId: emailFilter?.mailboxId,
        sort: sort,
        limit: limit,
        filterOption: emailFilter?.filterOption),
      stateDataSource.getState(accountId, session.username, StateType.email)
    ]).then((List response) {
      return EmailsResponse(emailList: response.first, state: response.last);
    });

    EmailsResponse? networkEmailResponse;

    if (!localEmailResponse.hasEmails()
        || (localEmailResponse.emailList?.length ?? 0) < ThreadConstants.defaultLimit.value) {
      networkEmailResponse = await mapDataSource[DataSourceType.network]!.getAllEmail(
        session,
        accountId,
        limit: limit,
        position: position,
        sort: sort,
        filter: emailFilter?.filter,
        properties: propertiesCreated);
      if (_isApproveFilterOption(emailFilter?.filterOption, networkEmailResponse.emailList)) {
        _getFirstPage(
          session,
          accountId,
          sort: sort,
          position: position,
          mailboxId: emailFilter?.mailboxId,
          propertiesCreated: propertiesCreated,
        );
      }
      yield networkEmailResponse;
    } else {
      yield localEmailResponse;
    }

    if (networkEmailResponse != null) {
      await _updateEmailCache(
        accountId,
        session.username,
        newCreated: networkEmailResponse.emailList,
        newDestroyed: networkEmailResponse.notFoundEmailIds,
      );
    }

    if (localEmailResponse.hasState()) {
      log('ThreadRepositoryImpl::getAllEmail(): filter = ${emailFilter?.mailboxId} local has state: ${localEmailResponse.state}');
      if (getLatestChanges) {
        await _synchronizeCacheWithChanges(
          session,
          accountId,
          localEmailResponse.state!,
          propertiesCreated: propertiesCreated,
          propertiesUpdated: propertiesUpdated
        );
      }
    } else {
      if (networkEmailResponse != null) {
        log('ThreadRepositoryImpl::getAllEmail(): filter = ${emailFilter?.mailboxId} no local state -> update from network: ${networkEmailResponse.state}');
        if (networkEmailResponse.state != null) {
          await _updateState(accountId, session.username, networkEmailResponse.state!);
        }
      }
    }

    final newEmailResponse = await Future.wait([
      mapDataSource[DataSourceType.local]!.getAllEmailCache(
        accountId,
        session.username,
        inMailboxId: emailFilter?.mailboxId,
        sort: sort,
        limit: limit,
        filterOption: emailFilter?.filterOption),
      stateDataSource.getState(accountId, session.username, StateType.email)
    ]).then((List response) {
      return EmailsResponse(emailList: response.first, state: response.last);
    });

    yield newEmailResponse;
  }

  bool _isApproveFilterOption(FilterMessageOption? filterOption, List<Email>? listEmailResponse) {
    return filterOption != FilterMessageOption.all && listEmailResponse!.isNotEmpty;
  }

  Future<EmailsResponse> _getFirstPage(
    Session session,
    AccountId accountId,
    {
      Set<Comparator>? sort,
      int? position,
      MailboxId? mailboxId,
      Properties? propertiesCreated,
      Filter? filter,
    }
  ) async {
      final networkEmailResponse = await mapDataSource[DataSourceType.network]!.getAllEmail(
        session,
        accountId,
        limit: ThreadConstants.defaultLimit,
        position: position,
        sort: sort,
        filter: filter ?? EmailFilterCondition(inMailbox: mailboxId),
        properties: propertiesCreated,
      );
      await _updateEmailCache(
        accountId,
        session.username,
        newCreated: networkEmailResponse.emailList,
        newDestroyed: networkEmailResponse.notFoundEmailIds,
      );

      return networkEmailResponse;
  }

  @visibleForTesting
  Future<List<Email>?> combineEmailCache({
    List<Email>? emailUpdated,
    Properties? updatedProperties,
    List<Email>? emailCacheList,
  }) =>
      _combineEmailCache(
        emailUpdated: emailUpdated,
        updatedProperties: updatedProperties,
        emailCacheList: emailCacheList,
      );

  Future<List<Email>?> _combineEmailCache({
    List<Email>? emailUpdated,
    Properties? updatedProperties,
    List<Email>? emailCacheList
  }) async {
    if (emailUpdated == null || emailUpdated.isEmpty) return emailUpdated;

    if (updatedProperties == null) return null;

    if (updatedProperties.value.containsAll(ThreadConstants.propertiesDefault.value)) {
      log('ThreadRepositoryImpl::_combineEmailCache(): Update use properties default');
      return emailUpdated;
    }

    final combinedEmails = emailUpdated
        .map((email) => _combineUpdatedWithEmailInCache(email, emailCacheList))
        .where((record) => record.oldEmail != null)
        .map((record) => record.oldEmail!.combineEmail(
          record.updatedEmail,
          updatedProperties,
        ))
        .toList();

    return combinedEmails;
  }

  @visibleForTesting
  ({Email updatedEmail, Email? oldEmail}) combineUpdatedWithEmailInCache(
    Email updatedEmail,
    List<Email>? emailCacheList,
  ) =>
      _combineUpdatedWithEmailInCache(updatedEmail, emailCacheList);

  ({Email updatedEmail, Email? oldEmail}) _combineUpdatedWithEmailInCache(
    Email updatedEmail,
    List<Email>? emailCacheList,
  ) {
    final oldEmail = updatedEmail.id != null
        ? emailCacheList?.findEmailById(updatedEmail.id!)
        : null;
    if (oldEmail != null) {
      log('ThredRepositoryImpl::_combineUpdatedWithEmailInCache(): cache hit for this email -> ${oldEmail.id} - ${oldEmail.subject} - ${oldEmail.keywords} - ${oldEmail.mailboxIds} - new update in $updatedEmail');
    } else {
      log('ThreadRepositoryImpl::_combineUpdatedWithEmailInCache(): cache miss for emailId ${updatedEmail.id}');
    }
    return (oldEmail: oldEmail, updatedEmail: updatedEmail);
  }

  Future<void> _updateEmailCache(
    AccountId accountId,
    UserName userName, {
    List<Email>? newUpdated,
    List<Email>? newCreated,
    List<EmailId>? newDestroyed
  }) async {
    await mapDataSource[DataSourceType.local]!.update(
      accountId,
      userName,
      updated: newUpdated,
      created: newCreated,
      destroyed: newDestroyed);
  }

  Future<void> _updateState(
    AccountId accountId,
    UserName userName,
    jmap.State newState,
  ) async {
    log('ThreadRepositoryImpl::_updateState(): [MAIL] $newState');
    await stateDataSource.saveState(
      accountId,
      userName,
      newState.toStateCache(StateType.email),
    );
  }

  @override
  Stream<EmailsResponse> refreshChanges(
    Session session,
    AccountId accountId,
    jmap.State currentState,
    {
      Set<Comparator>? sort,
      EmailFilter? emailFilter,
      Properties? propertiesCreated,
      Properties? propertiesUpdated,
    }
  ) async* {
    log('ThreadRepositoryImpl::refreshChanges(): $currentState');
    final emailChangeResponse = await _synchronizeCacheWithChanges(
      session,
      accountId,
      currentState,
      propertiesCreated: propertiesCreated,
      propertiesUpdated: propertiesUpdated
    );

    final newEmailResponse = await Future.wait([
      mapDataSource[DataSourceType.local]!.getAllEmailCache(
        accountId,
        session.username,
        inMailboxId: emailFilter?.mailboxId,
        sort: sort,
        filterOption: emailFilter?.filterOption
      ),
      stateDataSource.getState(accountId, session.username, StateType.email)
    ]).then((List response) {
      return EmailsResponse(emailList: response.first, state: response.last);
    });

    if (!newEmailResponse.hasEmails()
        || (newEmailResponse.emailList?.length ?? 0) < ThreadConstants.defaultLimit.value) {
      final networkEmailResponse = await _getFirstPage(
        session,
        accountId,
        sort: sort,
        filter: emailFilter?.filter,
        mailboxId: emailFilter?.mailboxId,
        propertiesCreated: propertiesCreated,
      );

      yield networkEmailResponse.copyWith(emailChangeResponse: emailChangeResponse);
    } else {
      yield newEmailResponse.copyWith(emailChangeResponse: emailChangeResponse);
    }
  }

  @override
  Stream<EmailsResponse> loadMoreEmails(GetEmailRequest emailRequest) async* {
    final response = await _getAllEmailsWithoutLastEmailId(emailRequest);
    await _updateEmailCache(
      emailRequest.accountId,
      emailRequest.session.username,
      newCreated: response.emailList,
      newDestroyed: response.notFoundEmailIds,
    );
    yield response;
  }

  Future<EmailsResponse> _getAllEmailsWithoutLastEmailId(GetEmailRequest emailRequest) async {
    final emailResponse = await mapDataSource[DataSourceType.network]!
        .getAllEmail(
          emailRequest.session,
          emailRequest.accountId,
          limit: emailRequest.limit,
          position: emailRequest.position,
          sort: emailRequest.sort,
          filter: emailRequest.filter,
          properties: emailRequest.properties)
        .then((response) {
          final listEmails = response.emailList;
          if (emailRequest.lastEmailId != null && listEmails?.isNotEmpty == true) {
            listEmails?.removeWhere((email) => email.id == emailRequest.lastEmailId);
          }
          return EmailsResponse(
            emailList: listEmails,
            state: response.state,
            notFoundEmailIds: response.notFoundEmailIds,
          );
        });

    return emailResponse;
  }

  @override
  Future<List<SearchEmail>> searchEmails(
    Session session,
    AccountId accountId,
    {
      UnsignedInt? limit,
      int? position,
      Set<Comparator>? sort,
      Filter? filter,
      Properties? properties
    }
  ) async {
    final searchEmailsResponse = await mapDataSource[DataSourceType.network]!.searchEmails(
      session,
      accountId,
      limit: limit,
      position: position,
      sort: sort,
      filter: filter,
      properties: properties);

    return searchEmailsResponse.toSearchEmails ?? [];
  }

  @override
  Future<List<EmailId>> emptyTrashFolder(
    Session session, 
    AccountId accountId, 
    MailboxId trashMailboxId,
    int totalEmails,
    StreamController<dartz.Either<Failure, Success>> onProgressController
  ) async {
    final listEmailIdDeleted = await mapDataSource[DataSourceType.network]!.emptyMailboxFolder(
      session,
      accountId,
      trashMailboxId,
      totalEmails,
      onProgressController
    );

    await _updateEmailCache(
      accountId,
      session.username,
      newDestroyed: listEmailIdDeleted);

    return listEmailIdDeleted;
  }

  Future<EmailChangeResponse?> _synchronizeCacheWithChanges(
    Session session,
    AccountId accountId,
    jmap.State currentState,
    {
      Properties? propertiesCreated,
      Properties? propertiesUpdated,
    }
  ) async {
    final localEmailList = await mapDataSource[DataSourceType.local]!.getAllEmailCache(accountId, session.username);

    EmailChangeResponse? emailChangeResponse;
    bool hasMoreChanges = true;
    jmap.State? sinceState = currentState;

    while(hasMoreChanges && sinceState != null) {
      log('ThreadRepositoryImpl::_synchronizeCacheWithChanges(): sinceState = $sinceState');
      final changesResponse = await mapDataSource[DataSourceType.network]!.getChanges(
        session,
        accountId,
        sinceState,
        propertiesCreated: propertiesCreated,
        propertiesUpdated: propertiesUpdated);

      hasMoreChanges = changesResponse.hasMoreChanges;
      sinceState = changesResponse.newStateChanges;

      if (emailChangeResponse != null) {
        emailChangeResponse.union(changesResponse);
      } else {
        emailChangeResponse = changesResponse;
      }
    }

    if (emailChangeResponse != null) {
      final newEmailUpdated = await _combineEmailCache(
          emailUpdated: emailChangeResponse.updated,
          updatedProperties: emailChangeResponse.updatedProperties,
          emailCacheList: localEmailList);

      log('ThreadRepositoryImpl::_synchronizeCacheWithChanges(): [Changes]: '
          'created = ${emailChangeResponse.created?.length} - '
          'updated = ${newEmailUpdated?.length} - '
          'destroyed = ${emailChangeResponse.destroyed?.length}');

      await _updateEmailCache(
          accountId,
          session.username,
          newCreated: emailChangeResponse.created,
          newUpdated: newEmailUpdated,
          newDestroyed: emailChangeResponse.destroyed);

      if (emailChangeResponse.newStateEmail != null) {
        await _updateState(accountId, session.username, emailChangeResponse.newStateEmail!);
      }
    }

    return emailChangeResponse;
  }

  @override
  Future<PresentationEmail> getEmailById(
    Session session,
    AccountId accountId,
    EmailId emailId,
    {Properties? properties}
  ) {
    return mapDataSource[DataSourceType.network]!.getEmailById(session, accountId, emailId, properties: properties);
  }

  @override
  Future<List<EmailId>> emptySpamFolder(
    Session session, 
    AccountId accountId, 
    MailboxId spamMailboxId,
    int totalEmails,
    StreamController<dartz.Either<Failure, Success>> onProgressController
  ) async {
    final listEmailIdDeleted = await mapDataSource[DataSourceType.network]!.emptyMailboxFolder(
      session,
      accountId,
      spamMailboxId,
      totalEmails,
      onProgressController
    );

    await _updateEmailCache(
      accountId,
      session.username,
      newDestroyed: listEmailIdDeleted);

    return listEmailIdDeleted;
  }

  @override
  Future<void> clearEmailCacheAndStateCache(
    AccountId accountId,
    Session session,
  ) => mapDataSource[DataSourceType.local]!.clearEmailCacheAndStateCache(
    accountId,
    session,
  );
}