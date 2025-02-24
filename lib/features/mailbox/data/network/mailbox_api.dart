import 'dart:async';

import 'package:collection/collection.dart';
import 'package:core/utils/app_logger.dart';
import 'package:flutter/material.dart' hide State;
import 'package:get/get.dart';
import 'package:jmap_dart_client/http/http_client.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/capability/capability_identifier.dart';
import 'package:jmap_dart_client/jmap/core/capability/core_capability.dart';
import 'package:jmap_dart_client/jmap/core/error/method/error_method_response.dart';
import 'package:jmap_dart_client/jmap/core/error/set_error.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/core/patch_object.dart';
import 'package:jmap_dart_client/jmap/core/properties/properties.dart';
import 'package:jmap_dart_client/jmap/core/request/reference_path.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/core/state.dart';
import 'package:jmap_dart_client/jmap/core/unsigned_int.dart';
import 'package:jmap_dart_client/jmap/jmap_request.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/changes/changes_mailbox_method.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/changes/changes_mailbox_response.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/get/get_mailbox_method.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/get/get_mailbox_response.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox_filter_condition.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/query/query_mailbox_method.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/set/set_mailbox_method.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/set/set_mailbox_response.dart';
import 'package:model/error_type_handler/set_method_error_handler_mixin.dart';
import 'package:model/mailbox/mailbox_constants.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/features/base/mixin/handle_error_mixin.dart';
import 'package:tmail_ui_user/features/composer/domain/exceptions/set_method_exception.dart';
import 'package:tmail_ui_user/features/mailbox/data/model/mailbox_change_response.dart';
import 'package:tmail_ui_user/features/mailbox/domain/exceptions/mailbox_exception.dart';
import 'package:tmail_ui_user/features/mailbox/domain/exceptions/set_mailbox_rights_exception.dart';
import 'package:tmail_ui_user/features/mailbox/domain/extensions/list_mailbox_id_extension.dart';
import 'package:tmail_ui_user/features/mailbox/domain/extensions/role_extension.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/create_new_mailbox_request.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/get_mailbox_by_role_response.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/jmap_mailbox_response.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/mailbox_subaddressing_action.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/mailbox_subscribe_state.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/move_mailbox_request.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/rename_mailbox_request.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/mailbox_right_request.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/subscribe_mailbox_request.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/subscribe_multiple_mailbox_request.dart';
import 'package:tmail_ui_user/main/error/capability_validator.dart';
import 'package:uuid/uuid.dart';

class MailboxAPI with HandleSetErrorMixin {

  final HttpClient httpClient;
  final Uuid _uuid;

  MailboxAPI(this.httpClient, this._uuid);

  Future<JmapMailboxResponse> getAllMailbox(Session session, AccountId accountId, {Properties? properties}) async {
    final processingInvocation = ProcessingInvocation();

    final jmapRequestBuilder = JmapRequestBuilder(httpClient, processingInvocation);

    final getMailboxCreated = GetMailboxMethod(accountId);

    if (properties != null) getMailboxCreated.addProperties(properties);

    final queryInvocation = jmapRequestBuilder.invocation(getMailboxCreated);

    final capabilities = getMailboxCreated.requiredCapabilities
      .toCapabilitiesSupportTeamMailboxes(session, accountId);

    final result = await (jmapRequestBuilder
        ..usings(capabilities))
      .build()
      .execute();

    final getMailboxResponse = result.parse<GetMailboxResponse>(
      queryInvocation.methodCallId,
      GetMailboxResponse.deserialize);

    if (getMailboxResponse != null && getMailboxResponse.list.isNotEmpty) {
      return JmapMailboxResponse(
        mailboxes: getMailboxResponse.list,
        state: getMailboxResponse.state);
    } else {
      throw NotFoundMailboxException();
    }
  }

  Future<MailboxChangeResponse> getChanges(Session session, AccountId accountId, State sinceState, {Properties? properties}) async {
    final processingInvocation = ProcessingInvocation();

    final jmapRequestBuilder = JmapRequestBuilder(httpClient, processingInvocation);

    final changesMailboxMethod = ChangesMailboxMethod(accountId, sinceState, maxChanges: UnsignedInt(128));

    final changesMailboxInvocation = jmapRequestBuilder.invocation(changesMailboxMethod);

    final getMailboxUpdated = GetMailboxMethod(accountId)
      ..addReferenceIds(processingInvocation.createResultReference(
          changesMailboxInvocation.methodCallId,
          ReferencePath.updatedPath));

    if (properties == null) {
      getMailboxUpdated
        .addReferenceProperties(processingInvocation.createResultReference(
          changesMailboxInvocation.methodCallId,
          ReferencePath.updatedPropertiesPath
        ));
    } else {
      getMailboxUpdated.addProperties(properties);
    }

    final getMailboxCreated = GetMailboxMethod(accountId)
      ..addReferenceIds(processingInvocation.createResultReference(
          changesMailboxInvocation.methodCallId,
          ReferencePath.createdPath));

    final getMailboxUpdatedInvocation = jmapRequestBuilder.invocation(getMailboxUpdated);
    final getMailboxCreatedInvocation = jmapRequestBuilder.invocation(getMailboxCreated);

    final capabilities = getMailboxUpdated.requiredCapabilities
      .toCapabilitiesSupportTeamMailboxes(session, accountId);

    final result = await (jmapRequestBuilder
        ..usings(capabilities))
      .build()
      .execute();

    final resultChanges = result.parse<ChangesMailboxResponse>(
        changesMailboxInvocation.methodCallId,
        ChangesMailboxResponse.deserialize);

    final resultUpdated = result.parse<GetMailboxResponse>(
        getMailboxUpdatedInvocation.methodCallId,
        GetMailboxResponse.deserialize);

    final resultCreated = result.parse<GetMailboxResponse>(
        getMailboxCreatedInvocation.methodCallId,
        GetMailboxResponse.deserialize);

    final listMailboxIdDestroyed = resultChanges?.destroyed.map((id) => MailboxId(id)).toList() ?? <MailboxId>[];
    log('MailboxAPI::getChanges:resultUpdated: ${resultUpdated?.toJson().toString()}');
    return MailboxChangeResponse(
      updated: resultUpdated?.list,
      created: resultCreated?.list,
      destroyed: listMailboxIdDestroyed,
      newStateMailbox: resultUpdated?.state,
      newStateChanges: resultChanges?.newState,
      hasMoreChanges: resultChanges?.hasMoreChanges ?? false,
      updatedProperties: resultChanges?.updatedProperties);
  }

  Future<Mailbox?> createNewMailbox(Session session, AccountId accountId, CreateNewMailboxRequest request) async {
    final generateCreateId = Id(_uuid.v1());

    final setMailboxMethod = SetMailboxMethod(accountId)
      ..addCreate(
          generateCreateId,
          Mailbox(
            name: request.newName,
            isSubscribed: IsSubscribed(request.isSubscribed),
            parentId: request.parentId
          )
      );

    final requestBuilder = JmapRequestBuilder(httpClient, ProcessingInvocation());

    final setMailboxInvocation = requestBuilder.invocation(setMailboxMethod);

    final capabilities = setMailboxMethod.requiredCapabilities
      .toCapabilitiesSupportTeamMailboxes(session, accountId);

    final response = await (requestBuilder
          ..usings(capabilities))
        .build()
        .execute();

    final setMailboxResponse = response.parse<SetMailboxResponse>(
        setMailboxInvocation.methodCallId,
        SetMailboxResponse.deserialize);

    final mapMailboxCreated = setMailboxResponse?.created;
    if (mapMailboxCreated != null &&
        mapMailboxCreated.containsKey(generateCreateId)) {
      final mailboxCreated = mapMailboxCreated[generateCreateId]!;
      final newMailboxCreated = mailboxCreated.toMailbox(
          request.newName,
          parentId: request.parentId);
      return newMailboxCreated;
    } else {
      throw _parseErrorForSetMailboxResponse(setMailboxResponse, generateCreateId);
    }
  }

  _parseErrorForSetMailboxResponse(SetMailboxResponse? response, Id requestId) {
    final mapError = response?.notCreated ?? response?.notUpdated ?? response?.notDestroyed;
    if (mapError != null && mapError.containsKey(requestId)) {
      final setError = mapError[requestId];
      log('MailboxAPI::_parseErrorForSetMailboxResponse():setError: $setError');
      if (setError?.type == ErrorMethodResponse.invalidArguments) {
        throw InvalidArgumentsMethodResponse(description: setError?.description);
      } else if (setError?.type == ErrorMethodResponse.invalidResultReference) {
        throw InvalidResultReferenceMethodResponse(description: setError?.description);
      } else {
        throw UnknownMethodResponse(description: setError?.description);
      }
    }  else {
      throw UnknownMethodResponse();
    }
  }

  Future<Map<Id, SetError>> deleteMultipleMailbox(Session session, AccountId accountId, List<MailboxId> mailboxIds) async {
    final coreCapability = session.getCapabilityProperties<CoreCapability>(
      accountId,
      CapabilityIdentifier.jmapCore
    );
    int maxMethodCount = coreCapability?.maxCallsInRequest?.value.toInt() ?? CapabilityIdentifierExtension.defaultMaxCallsInRequest;
    log('MailboxAPI::deleteMultipleMailbox:maxMethodCount: $maxMethodCount');

    final Map<Id,SetError> finalDeletedMailboxErrors = {};
    int start = 0;
    int end = 0;
    while (end < mailboxIds.length) {
      start = end;
      if (mailboxIds.length - start >= maxMethodCount) {
        end = maxMethodCount;
      } else {
        end = mailboxIds.length;
      }
      log('MailboxAPI::deleteMultipleMailbox(): delete from $start to $end / ${mailboxIds.length}');
      final currentExecuteList = mailboxIds.sublist(start, end);

      final requestBuilder = JmapRequestBuilder(httpClient, ProcessingInvocation());
      final currentSetMailboxInvocations = currentExecuteList.map((mailboxId) {
          return SetMailboxMethod(accountId)
            ..addDestroy({mailboxId.id})
            ..addOnDestroyRemoveEmails(true);
          })
        .map(requestBuilder.invocation)
        .toList();

      final capabilities = {CapabilityIdentifier.jmapCore, CapabilityIdentifier.jmapMail}
        .toCapabilitiesSupportTeamMailboxes(session, accountId);

      final response = await (requestBuilder
          ..usings(capabilities))
        .build()
        .execute();

      final deleteMailboxErrors = currentSetMailboxInvocations
        .map((currentInvocation) => response.parse(currentInvocation.methodCallId, SetMailboxResponse.deserialize))
        .map(_handleDeleteMailboxResponse)
        .expand((entries) => entries);
      finalDeletedMailboxErrors.addAll(Map.fromEntries(deleteMailboxErrors));
    }

    return finalDeletedMailboxErrors;
  }

  List<MapEntry<Id, SetError>> _handleDeleteMailboxResponse(SetMailboxResponse? response) {
    final List<MapEntry<Id,SetError>> remainedErrors = [];
    if (response != null) {
      handleSetErrors(
          notDestroyedError: response.notDestroyed,
          notUpdatedError: response.notUpdated,
          notCreatedError: response.notCreated,
          notDestroyedHandlers: <SetMethodErrorHandler>{
            (entry) => entry.value.type == SetError.notFound,
          },
          unCatchErrorHandler: (setErrorEntry) {
            remainedErrors.add(setErrorEntry);
            return false;
          }
      );
    }
    return remainedErrors;
  }

  Future<bool> renameMailbox(Session session, AccountId accountId, RenameMailboxRequest request) async {
    final setMailboxMethod = SetMailboxMethod(accountId)
      ..addUpdates({request.mailboxId.id : PatchObject({'name' : request.newName.name})});

    final requestBuilder = JmapRequestBuilder(httpClient, ProcessingInvocation());

    final setMailboxInvocation = requestBuilder.invocation(setMailboxMethod);

    final capabilities = setMailboxMethod.requiredCapabilities
      .toCapabilitiesSupportTeamMailboxes(session, accountId);

    final response = await (requestBuilder
        ..usings(capabilities))
      .build()
      .execute();

    final setMailboxResponse = response.parse<SetMailboxResponse>(
      setMailboxInvocation.methodCallId,
      SetMailboxResponse.deserialize);

    if (setMailboxResponse?.updated?.containsKey(request.mailboxId.id) == true) {
      return true;
    } else {
      final mapErrors = handleSetResponse([setMailboxResponse]);
      throw SetMethodException(mapErrors);
    }
  }

  Future<bool> moveMailbox(Session session, AccountId accountId, MoveMailboxRequest request) async {
    final setMailboxMethod = SetMailboxMethod(accountId)
      ..addUpdates({
        request.mailboxId.id : PatchObject({
          'parentId': request.destinationMailboxId?.id.value
        })
      });

    final requestBuilder = JmapRequestBuilder(httpClient, ProcessingInvocation());

    final setMailboxInvocation = requestBuilder.invocation(setMailboxMethod);

    final capabilities = setMailboxMethod.requiredCapabilities
      .toCapabilitiesSupportTeamMailboxes(session, accountId);

    final response = await (requestBuilder
        ..usings(capabilities))
      .build()
      .execute();

    final setMailboxResponse = response.parse<SetMailboxResponse>(
        setMailboxInvocation.methodCallId,
        SetMailboxResponse.deserialize);

    return Future.sync(() async {
      return setMailboxResponse?.updated?.isNotEmpty == true;
    }).catchError((error) {
      throw error;
    });
  }

  Future<bool> subscribeMailbox(Session session, AccountId accountId, SubscribeMailboxRequest request) async {
    final setMailboxMethod = SetMailboxMethod(accountId)
      ..addUpdates({
        request.mailboxId.id : PatchObject({
          MailboxProperty.isSubscribed: request.subscribeState == MailboxSubscribeState.enabled
        })
      });

    final requestBuilder = JmapRequestBuilder(httpClient, ProcessingInvocation());

    final setMailboxInvocation = requestBuilder.invocation(setMailboxMethod);

    final capabilities = setMailboxMethod.requiredCapabilities
      .toCapabilitiesSupportTeamMailboxes(session, accountId);

    final response = await (requestBuilder
        ..usings(capabilities))
      .build()
      .execute();

    final setMailboxResponse = response.parse<SetMailboxResponse>(
        setMailboxInvocation.methodCallId,
        SetMailboxResponse.deserialize);

    return Future.sync(() async {
      return setMailboxResponse?.updated?.containsKey(request.mailboxId.id) ?? false;
    }).catchError((error) {
      throw error;
    });
  }

  Future<List<MailboxId>> subscribeMultipleMailbox(
    Session session,
    AccountId accountId,
    SubscribeMultipleMailboxRequest subscribeRequest
  ) async {
    final mapMailboxUpdated = subscribeRequest.mailboxIdsSubscribe
      .generateMapUpdateObjectSubscribeMailbox(subscribeRequest.subscribeState);

    final setMailboxMethod = SetMailboxMethod(accountId)
      ..addUpdates(mapMailboxUpdated);

    final requestBuilder = JmapRequestBuilder(httpClient, ProcessingInvocation());

    final setMailboxInvocation = requestBuilder.invocation(setMailboxMethod);

    final capabilities = setMailboxMethod.requiredCapabilities
      .toCapabilitiesSupportTeamMailboxes(session, accountId);

    final response = await (requestBuilder
        ..usings(capabilities))
      .build()
      .execute();

    final setMailboxResponse = response.parse<SetMailboxResponse>(
      setMailboxInvocation.methodCallId,
      SetMailboxResponse.deserialize
    );

    final listMailboxIdSubscribe = setMailboxResponse?.updated?.keys
      .whereNotNull()
      .map((id) => MailboxId(id))
      .toList();

    log('MailboxAPI::subscribeMultipleMailbox():listMailboxIdSubscribe: $listMailboxIdSubscribe');
    return listMailboxIdSubscribe ?? [];
  }

  List<String> _updateRightsForSubaddressing(MailboxSubaddressingAction action, List<String>? currentRights) {
    final updatedRights = List<String>.from(currentRights ?? []);

    if (action == MailboxSubaddressingAction.allow) {
      updatedRights.addIf(!updatedRights.contains(postingRight), postingRight);
    } else {
      updatedRights.remove(postingRight);
    }

    return updatedRights;
  }

  @visibleForTesting
  List<String> updateRightsForSubaddressing(MailboxSubaddressingAction action, List<String>? currentRights)
      => _updateRightsForSubaddressing(action, currentRights);

  Future<bool> handleMailboxRightRequest(Session session, AccountId accountId, MailboxRightRequest request) async {
    final setMailboxMethod = SetMailboxMethod(accountId)
      ..addUpdates({
        request.mailboxId.id : PatchObject({
          'sharedWith/$anyoneIdentifier': _updateRightsForSubaddressing(request.subaddressingAction, request.currentRights?[anyoneIdentifier])
        })
      });

    final requestBuilder = JmapRequestBuilder(httpClient, ProcessingInvocation());

    final setMailboxInvocation = requestBuilder.invocation(setMailboxMethod);

    final capabilities = setMailboxMethod.requiredCapabilities
        .toCapabilitiesSupportTeamMailboxes(session, accountId);

    final response = await (requestBuilder
        ..usings(capabilities))
      .build()
      .execute();

    final setMailboxResponse = response.parse<SetMailboxResponse>(
        setMailboxInvocation.methodCallId,
        SetMailboxResponse.deserialize);

    if (setMailboxResponse?.updated?.containsKey(request.mailboxId.id) ?? false) {
      return true;
    } else {
      throw SetMailboxRightsException();
    }
  }

  Future<(List<Mailbox> mailboxes, Map<Id, SetError> mapErrors)> createDefaultMailbox(
    Session session,
    AccountId accountId,
    Map<Id, Role> mapRoles,
  ) async {
    final mapCreate = {
      for (var id in mapRoles.keys)
        id : Mailbox(name: MailboxName(mapRoles[id]!.mailboxName), isSubscribed: IsSubscribed(true))
    };

    final setMailboxMethodForCreate = SetMailboxMethod(accountId)
      ..addCreates(mapCreate);

    final requestBuilder = JmapRequestBuilder(httpClient, ProcessingInvocation());
    final createInvocation = requestBuilder.invocation(setMailboxMethodForCreate);

    final capabilities = setMailboxMethodForCreate.requiredCapabilities.toCapabilitiesSupportTeamMailboxes(session, accountId);

    final response = await (requestBuilder
        ..usings(capabilities))
      .build()
      .execute();

    final createResponse = response.parse<SetMailboxResponse>(
      createInvocation.methodCallId,
      SetMailboxResponse.deserialize
    );

    final mapErrors = handleSetResponse([createResponse]);
    final mapMailboxCreated = createResponse?.created ?? <Id, Mailbox>{};

    final listMailboxCreated = _convertMapToListMailbox(
      mapRoles: mapRoles,
      mapMailboxName: mapCreate,
      mapMailboxCreated: mapMailboxCreated,
    );

    return (listMailboxCreated, mapErrors);
  }

  List<Mailbox> _convertMapToListMailbox({
    required Map<Id, Role> mapRoles,
    required Map<Id, Mailbox> mapMailboxName,
    required Map<Id, Mailbox> mapMailboxCreated,
  }) {
    return mapMailboxCreated
      .entries
      .map((mailboxEntry) {
        final id = mailboxEntry.key;
        final mailbox = mailboxEntry.value;
        return mailbox.copyWith(
          name: mapMailboxName[id]?.name,
          role: mapRoles[id],
          isSubscribed: IsSubscribed(true),
        );
      })
      .toList();
  }

  Future<(List<Mailbox> mailboxes, Map<Id, SetError> mapErrors)> setRoleDefaultMailbox(
    Session session,
    AccountId accountId,
    List<Mailbox> listMailbox,
  ) async {
    final mapUpdated = {
      for (var mailbox in listMailbox)
        mailbox.id!.id: PatchObject({'role': mailbox.role!.value})
    };

    final setMailboxMethodForUpdate = SetMailboxMethod(accountId)
      ..addUpdates(mapUpdated);

    final requestBuilder = JmapRequestBuilder(httpClient, ProcessingInvocation());
    final updateInvocation = requestBuilder.invocation(setMailboxMethodForUpdate);

    final capabilities = setMailboxMethodForUpdate.requiredCapabilities.toCapabilitiesSupportTeamMailboxes(session, accountId);

    final response = await (requestBuilder
        ..usings(capabilities))
      .build()
      .execute();

    final updateResponse = response.parse<SetMailboxResponse>(
      updateInvocation.methodCallId,
      SetMailboxResponse.deserialize
    );

    final mapErrors = handleSetResponse([updateResponse]);
    final listUpdatedMailboxId = updateResponse?.updated?.keys ?? [];

    if (listUpdatedMailboxId.isEmpty) {
      final listMailboxWithoutRole = listMailbox
        .map((mailbox) => mailbox.toMailboxWithoutRole())
        .toList();

      return (listMailboxWithoutRole, mapErrors);
    }

    final listUpdatedMailbox = listMailbox
      .map((mailbox) {
        if (listUpdatedMailboxId.contains(mailbox.id!.id)) {
          return mailbox;
        } else {
          return mailbox.toMailboxWithoutRole();
        }
      })
      .toList();

    return (listUpdatedMailbox, mapErrors);
  }

  Future<GetMailboxByRoleResponse> getMailboxByRole(
    Session session,
    AccountId accountId,
    Role role,
    {
      UnsignedInt? limit
    }
  ) async {
    const int defaultLimit = 1;
    final processingInvocation = ProcessingInvocation();
    final requestBuilder = JmapRequestBuilder(httpClient, processingInvocation);
    final mailboxQueryMethod = QueryMailboxMethod(accountId)..addLimit(limit ?? UnsignedInt(defaultLimit));

    final mailboxFilterCondition = MailboxFilterCondition(role: role);
    mailboxQueryMethod.addFilters(mailboxFilterCondition);

    final mailboxQueryMethodInvocation = requestBuilder.invocation(mailboxQueryMethod);
    final getMailBoxMethod = GetMailboxMethod(accountId)
        ..addReferenceIds(processingInvocation.createResultReference(
          mailboxQueryMethodInvocation.methodCallId,
          ReferencePath.idsPath,
        ));
    final getMailboxInvocation = requestBuilder.invocation(getMailBoxMethod);

    final capabilities = getMailBoxMethod.requiredCapabilities
      .toCapabilitiesSupportTeamMailboxes(session, accountId);

    final result = await (requestBuilder
        ..usings(capabilities))
      .build()
      .execute();
    
    final mailboxResponse = result.parse<GetMailboxResponse>(
      getMailboxInvocation.methodCallId,
      GetMailboxResponse.deserialize
    );

    if (mailboxResponse?.list.isNotEmpty == true) {
      return GetMailboxByRoleResponse(mailbox: mailboxResponse!.list.first);
    } else {
      throw NotFoundMailboxException();
    }
  }
}