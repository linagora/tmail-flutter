
import 'package:core/core.dart';
import 'package:dartz/dartz.dart' as dartz;
import 'package:flutter/foundation.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/filter/filter.dart';
import 'package:jmap_dart_client/jmap/core/properties/properties.dart';
import 'package:jmap_dart_client/jmap/core/sort/comparator.dart';
import 'package:jmap_dart_client/jmap/core/state.dart';
import 'package:jmap_dart_client/jmap/core/unsigned_int.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_comparator.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_comparator_property.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_filter_condition.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/features/email/data/datasource/email_datasource.dart';
import 'package:tmail_ui_user/features/mailbox/data/datasource/state_datasource.dart';
import 'package:tmail_ui_user/features/mailbox/data/extensions/state_extension.dart';
import 'package:tmail_ui_user/features/mailbox/data/model/state_type.dart';
import 'package:tmail_ui_user/features/thread/data/datasource/thread_datasource.dart';
import 'package:tmail_ui_user/features/thread/data/model/email_change_response.dart';
import 'package:tmail_ui_user/features/thread/domain/constants/thread_constants.dart';
import 'package:tmail_ui_user/features/thread/domain/model/email_response.dart';
import 'package:tmail_ui_user/features/thread/domain/model/get_email_request.dart';
import 'package:tmail_ui_user/features/thread/domain/repository/thread_repository.dart';

class ThreadRepositoryImpl extends ThreadRepository {

  final Map<DataSourceType, ThreadDataSource> mapDataSource;
  final StateDataSource stateDataSource;
  final EmailDataSource emailDataSource;

  ThreadRepositoryImpl(this.mapDataSource, this.stateDataSource, this.emailDataSource);

  @override
  Stream<EmailsResponse> getAllEmail(
    AccountId accountId,
    {
      UnsignedInt? limit,
      Set<Comparator>? sort,
      EmailFilter? emailFilter,
      Properties? propertiesCreated,
      Properties? propertiesUpdated,
    }
  ) async* {
    log('ThreadRepositoryImpl::getAllEmail(): filter = ${emailFilter?.mailboxId}');
    final localEmailResponse = await Future.wait([
      mapDataSource[DataSourceType.local]!.getAllEmailCache(
          inMailboxId: emailFilter?.mailboxId,
          sort: sort,
          filterOption: emailFilter?.filterOption),
      stateDataSource.getState(StateType.email)
    ]).then((List response) {
      log('ThreadRepositoryImpl::getAllEmail(): localEmail: ${response.first}');
      return EmailsResponse(emailList: response.first, state: response.last);
    });

    EmailsResponse? networkEmailResponse;

    if (!localEmailResponse.hasEmails()
        || (localEmailResponse.emailList?.length ?? 0) < ThreadConstants.defaultLimit.value) {
      networkEmailResponse = await mapDataSource[DataSourceType.network]!.getAllEmail(
        accountId,
        limit: limit,
        sort: sort,
        filter: emailFilter?.filter,
        properties: propertiesCreated);

      yield networkEmailResponse;
    } else {
      yield localEmailResponse;
    }

    if (localEmailResponse.hasState() && networkEmailResponse == null) {
      log('ThreadRepositoryImpl::getAllEmail(): local has state: ${localEmailResponse.state}');
      EmailChangeResponse? emailChangeResponse;
      bool hasMoreChanges = true;
      State? sinceState = localEmailResponse.state!;

      while(hasMoreChanges && sinceState != null) {
        final changesResponse = await mapDataSource[DataSourceType.network]!.getChanges(
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

      final totalEmails = networkEmailResponse != null
        ? networkEmailResponse.emailList
        : localEmailResponse.emailList;

      final newEmailUpdated = await _combineEmailCache(
        emailUpdated: emailChangeResponse?.updated,
        updatedProperties: emailChangeResponse?.updatedProperties,
        emailCacheList: totalEmails);

      final newEmailCreated = networkEmailResponse != null
        ? networkEmailResponse.emailList
        : emailChangeResponse?.created;

      await _updateEmailCache(
        newCreated: newEmailCreated,
        newUpdated: newEmailUpdated,
        newDestroyed: emailChangeResponse?.destroyed);

      if (emailChangeResponse != null && emailChangeResponse.newStateEmail != null) {
        await _updateState(emailChangeResponse.newStateEmail!);
      }
    } else {
      if (networkEmailResponse != null) {
        await _updateEmailCache(newCreated: networkEmailResponse.emailList);
        if (networkEmailResponse.state != null) {
          await _updateState(networkEmailResponse.state!);
        }
      }
    }

    final newEmailResponse = await Future.wait([
      mapDataSource[DataSourceType.local]!.getAllEmailCache(
          inMailboxId: emailFilter?.mailboxId,
          sort: sort,
          filterOption: emailFilter?.filterOption),
      stateDataSource.getState(StateType.email)
    ]).then((List response) {
      return EmailsResponse(emailList: response.first, state: response.last);
    });

    yield newEmailResponse;
  }

  Future<List<Email>?> _combineEmailCache({
    List<Email>? emailUpdated,
    Properties? updatedProperties,
    List<Email>? emailCacheList
  }) async {
    if (emailUpdated != null && emailUpdated.isNotEmpty) {
      if (updatedProperties == null) {
        return null;
      }
      final newEmailUpdated = emailUpdated
        .map((updatedEmail) => _combineUpdatedWithEmailInCache(updatedEmail, emailCacheList))
        .where((tuple) => tuple.value2 != null)
        .map((tuple) => tuple.value2!.combineEmail(tuple.value1, updatedProperties))
        .toList();

      return newEmailUpdated;
    }
    return emailUpdated;
  }

  dartz.Tuple2<Email, Email?> _combineUpdatedWithEmailInCache(Email updatedEmail, List<Email>? emailCacheList) {
    final emailOld = emailCacheList?.findEmailById(updatedEmail.id);
    if (emailOld != null) {
      return dartz.Tuple2(updatedEmail, emailOld);
    } else {
      return dartz.Tuple2(updatedEmail, null);
    }
  }

  Future<void> _updateEmailCache({
    List<Email>? newUpdated,
    List<Email>? newCreated,
    List<EmailId>? newDestroyed
  }) async {
    await mapDataSource[DataSourceType.local]!.update(
      updated: newUpdated,
      created: newCreated,
      destroyed: newDestroyed);
  }

  Future<void> _updateState(State newState) async {
    await stateDataSource.saveState(newState.toStateCache(StateType.email));
  }

  @override
  Stream<EmailsResponse> refreshChanges(
      AccountId accountId,
      State currentState,
      {
        UnsignedInt? limit,
        Set<Comparator>? sort,
        Properties? propertiesCreated,
        Properties? propertiesUpdated,
        MailboxId? inMailboxId,
        FilterMessageOption? filterOption,
      }
  ) async* {
    log('ThreadRepositoryImpl::refreshChanges(): $currentState');
    final localEmailList = await mapDataSource[DataSourceType.local]!.getAllEmailCache(
      inMailboxId: inMailboxId,
      sort: sort,
      filterOption: filterOption);

    EmailChangeResponse? emailChangeResponse;
    bool hasMoreChanges = true;
    State? sinceState = currentState;

    while(hasMoreChanges && sinceState != null) {
      final changesResponse = await mapDataSource[DataSourceType.network]!.getChanges(
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

      await _updateEmailCache(
        newCreated: emailChangeResponse.created,
        newUpdated: newEmailUpdated,
        newDestroyed: emailChangeResponse.destroyed);

      if (emailChangeResponse.newStateEmail != null) {
        await _updateState(emailChangeResponse.newStateEmail!);
      }
    }

    final newEmailResponse = await Future.wait([
      mapDataSource[DataSourceType.local]!.getAllEmailCache(inMailboxId: inMailboxId, sort: sort, filterOption: filterOption),
      stateDataSource.getState(StateType.email)
    ]).then((List response) {
      return EmailsResponse(emailList: response.first, state: response.last);
    });

    yield newEmailResponse;
  }

  @override
  Stream<EmailsResponse> loadMoreEmails(GetEmailRequest emailRequest) async* {
    bench.start('loadMoreEmails in computed');
    final response = await compute(_getAllEmailsWithoutLastEmailId, emailRequest);
    bench.end('loadMoreEmails in computed');
    await _updateEmailCache(newCreated: response.emailList);
    yield response;
  }

  Future<EmailsResponse> _getAllEmailsWithoutLastEmailId(GetEmailRequest emailRequest) async {
    final emailResponse = await mapDataSource[DataSourceType.network]!
        .getAllEmail(
            emailRequest.accountId,
            limit: emailRequest.limit,
            sort: emailRequest.sort,
            filter: emailRequest.filter,
            properties: emailRequest.properties)
        .then((response) {
            var listEmails = response.emailList;
            if (listEmails != null && listEmails.isNotEmpty) {
              listEmails = listEmails.where((email) => email.id != emailRequest.lastEmailId).toList();
            }
            return EmailsResponse(emailList: listEmails, state: response.state);
        });

    return emailResponse;
  }

  @override
  Future<List<Email>> searchEmails(
    AccountId accountId,
    {
      UnsignedInt? limit,
      Set<Comparator>? sort,
      Filter? filter,
      Properties? properties
    }
  ) async {
    final emailResponse = await mapDataSource[DataSourceType.network]!.getAllEmail(
      accountId,
      limit: limit,
      sort: sort,
      filter: filter,
      properties: properties);

    return emailResponse.emailList ?? List.empty();
  }

  @override
  Future<bool> emptyTrashFolder(AccountId accountId, MailboxId trashMailboxId) async {
    var finalResult = true;
    var hasEmails = true;

    while (hasEmails) {
      Email? lastEmail;

      final emailsResponse = await mapDataSource[DataSourceType.network]!.getAllEmail(
          accountId,
          sort: <Comparator>{}
            ..add(EmailComparator(EmailComparatorProperty.receivedAt)
              ..setIsAscending(false)),
          filter: EmailFilterCondition(inMailbox: trashMailboxId, before: lastEmail?.receivedAt),
          properties: Properties({EmailProperty.id}));

      if (emailsResponse.state != null) {
        await _updateState(emailsResponse.state!);
      }

      var newEmailList =  emailsResponse.emailList ?? <Email>[];
      if (lastEmail != null) {
        newEmailList = newEmailList.where((email) => email.id != lastEmail!.id).toList();
      }

      log('ThreadRepositoryImpl::emptyTrashFolder(): ${newEmailList.length}');

      if (newEmailList.isNotEmpty == true) {
        lastEmail = newEmailList.last;
        hasEmails = true;
        final emailIds = newEmailList.map((email) => email.id).toList();

        final listEmailIdDeleted = await emailDataSource.deleteMultipleEmailsPermanently(accountId, emailIds);

        if (listEmailIdDeleted.isNotEmpty && listEmailIdDeleted.length == emailIds.length) {
          await _updateEmailCache(newDestroyed: listEmailIdDeleted);
          finalResult = true;
        } else {
          finalResult = false;
        }
      } else {
        hasEmails = false;
      }
    }

    return finalResult;
  }
}