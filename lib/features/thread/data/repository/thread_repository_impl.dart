
import 'package:core/core.dart';
import 'package:model/model.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/filter/filter.dart';
import 'package:jmap_dart_client/jmap/core/properties/properties.dart';
import 'package:jmap_dart_client/jmap/core/sort/comparator.dart';
import 'package:jmap_dart_client/jmap/core/state.dart';
import 'package:jmap_dart_client/jmap/core/unsigned_int.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:tmail_ui_user/features/mailbox/data/datasource/state_datasource.dart';
import 'package:tmail_ui_user/features/mailbox/data/model/state_type.dart';
import 'package:tmail_ui_user/features/thread/data/datasource/thread_datasource.dart';
import 'package:tmail_ui_user/features/thread/data/model/email_change_response.dart';
import 'package:tmail_ui_user/features/thread/domain/model/email_response.dart';
import 'package:tmail_ui_user/features/thread/domain/repository/thread_repository.dart';
import 'package:tmail_ui_user/features/mailbox/data/extensions/state_extension.dart';

class ThreadRepositoryImpl extends ThreadRepository {

  final Map<DataSourceType, ThreadDataSource> mapDataSource;
  final StateDataSource stateDataSource;

  ThreadRepositoryImpl(this.mapDataSource, this.stateDataSource);

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
    final localEmailResponse = await Future.wait([
      mapDataSource[DataSourceType.local]!.getAllEmailCache(
          inMailboxId: emailFilter?.mailboxId,
          sort: sort,
          filterOption: emailFilter?.filterOption),
      stateDataSource.getState(StateType.email)
    ]).then((List response) {
      return EmailsResponse(emailList: response.first, state: response.last);
    });

    EmailsResponse? networkEmailResponse;

    if (!localEmailResponse.hasEmails()) {
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

    if (localEmailResponse.hasState()) {
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
      final newEmailUpdated = emailUpdated.map((email) {
        if (updatedProperties == null) {
          return email;
        } else {
          final emailOld = emailCacheList?.findEmailById(email.id);
          if (emailOld != null) {
            return emailOld.combineEmail(email, updatedProperties);
          } else {
            return email;
          }
        }
      }).toList();

      return newEmailUpdated;
    }
    return emailUpdated;
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
  Stream<EmailsResponse> loadMoreEmails(
    AccountId accountId,
    {
      int? position,
      UnsignedInt? limit,
      Set<Comparator>? sort,
      Filter? filter,
      Properties? properties,
      EmailId? lastEmailId,
    }
  ) async* {
    final emailResponse = await mapDataSource[DataSourceType.network]!.getAllEmail(
      accountId,
      limit: limit,
      sort: sort,
      filter: filter,
      properties: properties);

    final newEmailList = emailResponse.emailList != null && emailResponse.emailList!.isNotEmpty
      ? emailResponse.emailList!.where((email) => email.id != lastEmailId).toList()
      : <Email>[];

    if (newEmailList.isNotEmpty) {
      await _updateEmailCache(newCreated: newEmailList);
    }

    yield EmailsResponse(emailList: newEmailList, state: emailResponse.state);
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
  Stream<EmailsResponse> refreshAll(
      AccountId accountId,
      {
        UnsignedInt? limit,
        Set<Comparator>? sort,
        EmailFilter? emailFilter,
        Properties? propertiesCreated,
        Properties? propertiesUpdated,
      }
  ) async* {
    EmailsResponse? networkEmailResponse = await mapDataSource[DataSourceType.network]!.getAllEmail(
        accountId,
        limit: limit,
        sort: sort,
        filter: emailFilter?.filter,
        properties: propertiesCreated);

    await _updateEmailCache(newCreated: networkEmailResponse.emailList);
    if (networkEmailResponse.state != null) {
      await _updateState(networkEmailResponse.state!);
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
}