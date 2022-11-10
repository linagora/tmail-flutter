import 'dart:async';

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
import 'package:tmail_ui_user/features/mailbox/data/model/mailbox_change_response.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/create_new_mailbox_request.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/mailbox_response.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/move_mailbox_request.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/rename_mailbox_request.dart';
import 'package:tmail_ui_user/main/error/capability_validator.dart';

class MailboxAPI with HandleSetErrorMixin {

  final HttpClient httpClient;

  MailboxAPI(this.httpClient);

  Future<MailboxResponse> getAllMailbox(AccountId accountId, {Properties? properties}) async {
    final processingInvocation = ProcessingInvocation();

    final jmapRequestBuilder = JmapRequestBuilder(httpClient, processingInvocation);

    final getMailboxCreated = GetMailboxMethod(accountId);

    final queryInvocation = jmapRequestBuilder.invocation(getMailboxCreated);

    final result = await (jmapRequestBuilder
        ..usings(getMailboxCreated.requiredCapabilities))
      .build()
      .execute();

    final resultCreated = result.parse<GetMailboxResponse>(
      queryInvocation.methodCallId,
      GetMailboxResponse.deserialize);

    return MailboxResponse(mailboxes: resultCreated?.list, state: resultCreated?.state);
  }

  Future<MailboxChangeResponse> getChanges(AccountId accountId, State sinceState) async {
    final processingInvocation = ProcessingInvocation();

    final jmapRequestBuilder = JmapRequestBuilder(httpClient, processingInvocation);

    final changesMailboxMethod = ChangesMailboxMethod(accountId, sinceState, maxChanges: UnsignedInt(128));

    final changesMailboxInvocation = jmapRequestBuilder.invocation(changesMailboxMethod);

    final getMailboxUpdated = GetMailboxMethod(accountId)
      ..addReferenceIds(processingInvocation.createResultReference(
          changesMailboxInvocation.methodCallId,
          ReferencePath.updatedPath))
      ..addReferenceProperties(processingInvocation.createResultReference(
          changesMailboxInvocation.methodCallId,
          ReferencePath.updatedPropertiesPath));

    final getMailboxCreated = GetMailboxMethod(accountId)
      ..addReferenceIds(processingInvocation.createResultReference(
          changesMailboxInvocation.methodCallId,
          ReferencePath.createdPath));

    final getMailboxUpdatedInvocation = jmapRequestBuilder.invocation(getMailboxUpdated);
    final getMailboxCreatedInvocation = jmapRequestBuilder.invocation(getMailboxCreated);

    final result = await (jmapRequestBuilder
        ..usings(getMailboxCreated.requiredCapabilities))
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

    return MailboxChangeResponse(
      updated: resultUpdated?.list,
      created: resultCreated?.list,
      destroyed: listMailboxIdDestroyed,
      newStateMailbox: resultUpdated?.state,
      newStateChanges: resultChanges?.newState,
      hasMoreChanges: resultChanges?.hasMoreChanges ?? false,
      updatedProperties: resultChanges?.updatedProperties);
  }

  Future<Mailbox?> createNewMailbox(AccountId accountId, CreateNewMailboxRequest request) async {
    final setMailboxMethod = SetMailboxMethod(accountId)
      ..addCreate(request.creationId, Mailbox(name: request.newName, parentId: request.parentId));

    final requestBuilder = JmapRequestBuilder(httpClient, ProcessingInvocation());

    final setMailboxInvocation = requestBuilder.invocation(setMailboxMethod);

    final response = await (requestBuilder
          ..usings(setMailboxMethod.requiredCapabilities))
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
    requireCapability(session, accountId, [CapabilityIdentifier.jmapCore, CapabilityIdentifier.jmapMail]);

    final coreCapability = session.getCapabilityProperties<CoreCapability>(
        accountId, CapabilityIdentifier.jmapCore);
    final maxMethodCount = coreCapability.maxCallsInRequest.value.toInt();

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

      final response = await (requestBuilder
          ..usings({CapabilityIdentifier.jmapCore, CapabilityIdentifier.jmapMail}))
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

  Future<bool> renameMailbox(AccountId accountId, RenameMailboxRequest request) async {
    final setMailboxMethod = SetMailboxMethod(accountId)
      ..addUpdates({request.mailboxId.id : PatchObject({'name' : request.newName.name})});

    final requestBuilder = JmapRequestBuilder(httpClient, ProcessingInvocation());

    final setMailboxInvocation = requestBuilder.invocation(setMailboxMethod);

    final response = await (requestBuilder
          ..usings(setMailboxMethod.requiredCapabilities))
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

  Future<bool> moveMailbox(AccountId accountId, MoveMailboxRequest request) async {
    final setMailboxMethod = SetMailboxMethod(accountId)
      ..addUpdates({
        request.mailboxId.id : PatchObject({
          'parentId': request.destinationMailboxId?.id.value
        })
      });

    final requestBuilder = JmapRequestBuilder(httpClient, ProcessingInvocation());

    final setMailboxInvocation = requestBuilder.invocation(setMailboxMethod);

    final response = await (requestBuilder
        ..usings(setMailboxMethod.requiredCapabilities))
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
}