
import 'package:core/core.dart';
import 'package:dartz/dartz.dart' as dartz;
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/filter/filter.dart';
import 'package:jmap_dart_client/jmap/core/properties/properties.dart';
import 'package:jmap_dart_client/jmap/core/sort/comparator.dart';
import 'package:jmap_dart_client/jmap/core/state.dart';
import 'package:jmap_dart_client/jmap/core/unsigned_int.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
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
import 'package:tmail_ui_user/features/thread/domain/model/email_filter.dart';
import 'package:tmail_ui_user/features/thread/domain/model/email_response.dart';
import 'package:tmail_ui_user/features/thread/domain/model/filter_message_option.dart';
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
          limit: limit,
          filterOption: emailFilter?.filterOption),
      stateDataSource.getState(StateType.email)
    ]).then((List response) {
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
      if (_isApproveFilterOption(emailFilter?.filterOption, networkEmailResponse.emailList)) {
        _getFirstPage(
          accountId,
          sort: sort,
          mailboxId: emailFilter?.mailboxId,
          propertiesCreated: propertiesCreated,
        );
      }
      yield networkEmailResponse;
    } else {
      yield localEmailResponse;
    }

    if (networkEmailResponse != null) {
      await _updateEmailCache(newCreated: networkEmailResponse.emailList);
    }

    if (localEmailResponse.hasState()) {
      log('ThreadRepositoryImpl::getAllEmail(): filter = ${emailFilter?.mailboxId} local has state: ${localEmailResponse.state}');
      await _synchronizeCacheWithChanges(
        accountId,
        localEmailResponse.state!,
        propertiesCreated: propertiesCreated,
        propertiesUpdated: propertiesUpdated
      );
    } else {
      if (networkEmailResponse != null) {
        log('ThreadRepositoryImpl::getAllEmail(): filter = ${emailFilter?.mailboxId} no local state -> update from network: ${networkEmailResponse.state}');
        if (networkEmailResponse.state != null) {
          await _updateState(networkEmailResponse.state!);
        }
      }
    }

    final newEmailResponse = await Future.wait([
      mapDataSource[DataSourceType.local]!.getAllEmailCache(
          inMailboxId: emailFilter?.mailboxId,
          sort: sort,
          limit: limit,
          filterOption: emailFilter?.filterOption),
      stateDataSource.getState(StateType.email)
    ]).then((List response) {
      return EmailsResponse(emailList: response.first, state: response.last);
    });

    yield newEmailResponse;
  }

  bool _isApproveFilterOption(FilterMessageOption? filterOption, List<Email>? listEmailResponse) {
    return filterOption != FilterMessageOption.all && listEmailResponse!.isNotEmpty;
  }

  Future<EmailsResponse> _getFirstPage(
    AccountId accountId,
    {
      Set<Comparator>? sort,
      MailboxId? mailboxId,
      Properties? propertiesCreated,
      Filter? filter,
    }
  ) async {
      final networkEmailResponse = await mapDataSource[DataSourceType.network]!.getAllEmail(
        accountId,
        limit: ThreadConstants.defaultLimit,
        sort: sort,
        filter: filter ?? EmailFilterCondition(inMailbox: mailboxId),
        properties: propertiesCreated,
      );
      await _updateEmailCache(newCreated: networkEmailResponse.emailList);

      return networkEmailResponse;
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
      log('ThreadRepositoryImpl::_combineUpdatedWithEmailInCache(): cache hit');
      return dartz.Tuple2(updatedEmail, emailOld);
    } else {
      log('ThreadRepositoryImpl::_combineUpdatedWithEmailInCache(): cache miss');
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
    log('ThreadRepositoryImpl::_updateState(): [MAIL] $newState');
    await stateDataSource.saveState(newState.toStateCache(StateType.email));
  }

  @override
  Stream<EmailsResponse> refreshChanges(
      AccountId accountId,
      State currentState,
      {
        Set<Comparator>? sort,
        EmailFilter? emailFilter,
        Properties? propertiesCreated,
        Properties? propertiesUpdated,
      }
  ) async* {
    log('ThreadRepositoryImpl::refreshChanges(): $currentState');
    await _synchronizeCacheWithChanges(
      accountId,
      currentState,
      propertiesCreated: propertiesCreated,
      propertiesUpdated: propertiesUpdated
    );

    final newEmailResponse = await Future.wait([
      mapDataSource[DataSourceType.local]!.getAllEmailCache(inMailboxId: emailFilter?.mailboxId, sort: sort, filterOption: emailFilter?.filterOption),
      stateDataSource.getState(StateType.email)
    ]).then((List response) {
      return EmailsResponse(emailList: response.first, state: response.last);
    });

    if (!newEmailResponse.hasEmails()
        || (newEmailResponse.emailList?.length ?? 0) < ThreadConstants.defaultLimit.value) {
      final networkEmailResponse = await _getFirstPage(
        accountId,
        sort: sort,
        filter: emailFilter?.filter,
        mailboxId: emailFilter?.mailboxId,
        propertiesCreated: propertiesCreated,
      );

      yield networkEmailResponse;
    } else {
      yield newEmailResponse;
    }
  }

  @override
  Stream<EmailsResponse> loadMoreEmails(GetEmailRequest emailRequest) async* {
    final response = await _getAllEmailsWithoutLastEmailId(emailRequest);
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
  Future<List<EmailId>> emptyTrashFolder(AccountId accountId, MailboxId trashMailboxId) async {
    return mapDataSource[DataSourceType.network]!.emptyTrashFolder(
      accountId,
      trashMailboxId,
      (listEmailIdDeleted) async {
        await _updateEmailCache(newDestroyed: listEmailIdDeleted);
      },
    );
  }

  Future<void> _synchronizeCacheWithChanges(
    AccountId accountId,
    State currentState,
    {
      Properties? propertiesCreated,
      Properties? propertiesUpdated,
    }
  ) async {
    final localEmailList = await mapDataSource[DataSourceType.local]!
        .getAllEmailCache();

    EmailChangeResponse? emailChangeResponse;
    bool hasMoreChanges = true;
    State? sinceState = currentState;

    while(hasMoreChanges && sinceState != null) {
      log('ThreadRepositoryImpl::_synchronizeCacheWithChanges(): sinceState = $sinceState');
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

      log('ThreadRepositoryImpl::_synchronizeCacheWithChanges(): [Changes]: '
          'created = ${emailChangeResponse.created?.length} - '
          'updated = ${newEmailUpdated?.length} - '
          'destroyed = ${emailChangeResponse.destroyed?.length}');

      await _updateEmailCache(
          newCreated: emailChangeResponse.created,
          newUpdated: newEmailUpdated,
          newDestroyed: emailChangeResponse.destroyed);

      if (emailChangeResponse.newStateEmail != null) {
        await _updateState(emailChangeResponse.newStateEmail!);
      }
    }
  }
}