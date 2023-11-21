import 'dart:async';

import 'package:collection/collection.dart';
import 'package:core/utils/app_logger.dart';
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
import 'package:jmap_dart_client/jmap/mail/mailbox/set/set_mailbox_method.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/set/set_mailbox_response.dart';
import 'package:model/error_type_handler/set_method_error_handler_mixin.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/features/base/mixin/handle_error_mixin.dart';
import 'package:tmail_ui_user/features/composer/domain/exceptions/set_method_exception.dart';
import 'package:tmail_ui_user/features/mailbox/data/model/mailbox_change_response.dart';
import 'package:tmail_ui_user/features/mailbox/domain/exceptions/set_mailbox_method_exception.dart';
import 'package:tmail_ui_user/features/mailbox/domain/extensions/list_mailbox_id_extension.dart';
import 'package:tmail_ui_user/features/mailbox/domain/extensions/role_extension.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/create_new_mailbox_request.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/mailbox_response.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/mailbox_subscribe_state.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/move_mailbox_request.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/rename_mailbox_request.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/subscribe_mailbox_request.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/subscribe_multiple_mailbox_request.dart';
import 'package:tmail_ui_user/main/error/capability_validator.dart';
import 'package:uuid/uuid.dart';

class MailboxAPI with HandleSetErrorMixin {

  final HttpClient httpClient;
  final Uuid _uuid;

  MailboxAPI(this.httpClient, this._uuid);

  Future<MailboxResponse> getAllMailbox(Session session, AccountId accountId, {Properties? properties}) async {
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

    final resultCreated = result.parse<GetMailboxResponse>(
      queryInvocation.methodCallId,
      GetMailboxResponse.deserialize);

    return MailboxResponse(mailboxes: resultCreated?.list, state: resultCreated?.state);
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
    final setMailboxMethod = SetMailboxMethod(accountId)
      ..addCreate(
          request.creationId,
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
        mapMailboxCreated.containsKey(request.creationId)) {
      final mailboxCreated = mapMailboxCreated[request.creationId]!;
      final newMailboxCreated = mailboxCreated.toMailbox(
          request.newName,
          parentId: request.parentId);
      return newMailboxCreated;
    } else {
      throw _parseErrorForSetMailboxResponse(setMailboxResponse, request.creationId);
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
        accountId, CapabilityIdentifier.jmapCore);
    final maxMethodCount = coreCapability?.maxCallsInRequest?.value.toInt() ?? 0;

    final Map<Id,SetError> finalDeletedMailboxErrors = {};
    var start = 0;
    var end = 0;
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
      final listEntriesErrors = handleSetResponse([
        setMailboxResponse,
      ]);
      final mapErrors = Map.fromEntries(listEntriesErrors);
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

  Future<List<Mailbox>> createDefaultMailbox(
    Session session,
    AccountId accountId,
    List<Role> listRole
  ) async {
    final mapId = {
      for (var role in listRole)
        Id(_uuid.v1()) : role
    };

    final mapCreate = {
      for (var id in mapId.keys)
        id : Mailbox(name: MailboxName(mapId[id]!.mailboxName), isSubscribed: IsSubscribed(true))
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

    final listEntriesErrors = handleSetResponse([createResponse]);
    final mapErrors = Map.fromEntries(listEntriesErrors);

    if (mapErrors.isNotEmpty) {
      throw SetMailboxMethodException(mapErrors);
    } else {
      final mapMailboxCreated = createResponse?.created ?? <Id, Mailbox>{};
      log('MailboxAPI::createDefaultMailbox:mapMailboxCreated: $mapMailboxCreated');
      final listMailboxCreated = _convertMapToListMailbox(
        mapRoles: mapId,
        mapMailboxName: mapCreate,
        mapMailboxCreated: mapMailboxCreated
      );
      log('MailboxAPI::createDefaultMailbox:listMailboxCreated: ${listMailboxCreated.length}');
      if (listMailboxCreated.isEmpty) {
        throw NotFoundMailboxCreatedException();
      } else {
        return listMailboxCreated;
      }
    }
  }

  List<Mailbox> _convertMapToListMailbox({
    required Map<Id, Role> mapRoles,
    required Map<Id, Mailbox> mapMailboxName,
    required Map<Id, Mailbox> mapMailboxCreated
  }) {
    return mapRoles.keys
      .where((key) => mapMailboxCreated.containsKey(key))
      .map((key) {
        final mailboxName = mapMailboxName[key]?.name;
        final mailboxRole = mapRoles[key];
        if (mailboxName != null && mailboxRole != null) {
          return mapMailboxCreated[key]?.toMailbox(
            mailboxName,
            mailboxRole: mailboxRole
          );
        } else {
          return null;
        }
      })
      .whereNotNull()
      .toList();
  }

  Future<void> setRoleDefaultMailbox(
    Session session,
    AccountId accountId,
    List<Mailbox> listMailbox
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

    final listEntriesErrors = handleSetResponse([updateResponse]);
    final mapErrors = Map.fromEntries(listEntriesErrors);

    if (mapErrors.isNotEmpty) {
      throw SetMailboxMethodException(mapErrors);
    }
  }
}